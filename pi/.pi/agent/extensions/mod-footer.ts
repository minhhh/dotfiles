/**
 * Token footer - same as the built-in footer, but shows context tokens
 * (e.g. `33.6k (3.4%)`) instead of the window size (`33.6k/1.0M`).
 *
 * Install at ~/.pi/agent/extensions/token-footer.ts and run /reload.
 *
 * Reproduces the built-in footer: cwd with ~ substitution, git branch,
 * session name, cumulative ↑/↓/R/W/CH/cost, context usage, model with
 * thinking level, provider prefix, and extension statuses.
 *
 * Gaps vs the built-in footer, because the data is not exposed to extensions:
 * - the `(sub)` suffix for subscription-backed providers
 * - the `xp` experimental-features badge
 *
 * Colors for each part (path, bandwidth, context, model, thinking) live in
 * FOOTER_COLORS below. Each value accepts a theme role name ("dim", "accent"),
 * a hex color ("#89b4fa"), a 256-color index (0-255), or "" for the terminal
 * default. The full list of theme role names sits above FOOTER_COLORS. Edit the
 * block and run /reload.
 */
import { type FSWatcher, watch } from "node:fs";
import { isAbsolute, join, relative, resolve, sep } from "node:path";
import {
	type ExtensionAPI,
	getAgentDir,
	SettingsManager,
	type Theme,
	type ThemeColor,
} from "@earendil-works/pi-coding-agent";
import { getCapabilities, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

/** A footer color: theme role name, hex string, 0-255 ANSI index, or "" for the terminal default. */
type FooterColor = ThemeColor | `#${string}` | number | "";

/**
 * Theme role names accepted by `FooterColor`, taken from pi's `ThemeColor`:
 *   accent, border, borderAccent, borderMuted, success, error, warning, muted,
 *   dim, text, thinkingText, scrollbarTrack, scrollbarThumb, searchMatchText,
 *   userMessageText, customMessageText, customMessageLabel, toolTitle, toolOutput,
 *   mdHeading, mdLink, mdLinkUrl, mdCode, mdCodeBlock, mdCodeBlockBorder, mdQuote,
 *   mdQuoteBorder, mdHr, mdListBullet, toolDiffAdded, toolDiffRemoved,
 *   toolDiffContext, syntaxComment, syntaxKeyword, syntaxFunction, syntaxVariable,
 *   syntaxString, syntaxNumber, syntaxType, syntaxOperator, syntaxPunctuation,
 *   thinkingOff, thinkingMinimal, thinkingLow, thinkingMedium, thinkingHigh,
 *   thinkingXhigh, thinkingMax, bashMode
 *
 * Other accepted forms: a 3- or 6-digit hex color ("#89b4fa", "#fff"), an ANSI
 * 256-color index (0-255), or "" for the terminal default.
 */

/** Per-part footer colors. Edit and run /reload. */
const FOOTER_COLORS = {
	/** Working directory. */
	path: 5,
	/** Git branch shown after the path. */
	branch: 2,
	/** Session name shown after the path. */
	session: "muted",
	/** ↑input ↓output RcacheRead WcacheWrite CHhitRate. */
	bandwidth: "muted",
	/** Context tokens used, percent of the window, and the (auto) marker. */
	context: 4,
	/** Context display above 70% used. */
	contextWarning: "warning",
	/** Context display above 90% used. */
	contextCritical: "error",
	/** Model id and provider prefix. */
	model: "#cba6f7",
	/** Thinking level next to the model. */
	thinking: "accent",
	/** Separators, padding, and truncation ellipses. */
	separator: "dim",
} satisfies Record<string, FooterColor>;

/** Draw the path in bold as well as its color. */
const PATH_BOLD = true;

/** Draw the context display in bold as well as its color. */
const CONTEXT_BOLD = true;

const CUBE_VALUES = [0, 95, 135, 175, 215, 255];

function hexToRgb(hex: string): { r: number; g: number; b: number } {
	let h = hex.replace("#", "");
	if (h.length === 3) h = h.split("").map((c) => c + c).join("");
	const n = Number.parseInt(h, 16);
	return { r: (n >> 16) & 0xff, g: (n >> 8) & 0xff, b: n & 0xff };
}

/** Nearest 256-color index, used when the terminal lacks truecolor. */
function rgbTo256(r: number, g: number, b: number): number {
	const closestCube = (v: number) =>
		CUBE_VALUES.reduce((best, c, i) => (Math.abs(c - v) < Math.abs(CUBE_VALUES[best] - v) ? i : best), 0);
	const gray = Math.round(0.299 * r + 0.587 * g + 0.114 * b);
	const grayIdx = Math.max(0, Math.min(23, Math.round((gray - 8) / 10)));
	const grayDist = Math.abs(gray - (8 + grayIdx * 10));
	const cubeDist = Math.abs(gray - CUBE_VALUES[closestCube(gray)]);
	if (Math.max(r, g, b) - Math.min(r, g, b) < 10 && grayDist < cubeDist) return 232 + grayIdx;
	return 16 + 36 * closestCube(r) + 6 * closestCube(g) + closestCube(b);
}

function isDirectColor(color: FooterColor): color is number | `#${string}` {
	return typeof color === "number" || color.startsWith("#");
}

function ansiForeground(color: number | `#${string}`): string {
	if (typeof color === "number") return `\x1b[38;5;${color}m`;
	const { r, g, b } = hexToRgb(color);
	if (getCapabilities().trueColor) return `\x1b[38;2;${r};${g};${b}m`;
	return `\x1b[38;5;${rgbTo256(r, g, b)}m`;
}

/** Wrap text in bold without touching its color. */
function emphasize(text: string, bold: boolean): string {
	return bold ? `\x1b[1m${text}\x1b[22m` : text;
}

/** Paint text with a footer color, falling back to plain text if a theme role is unknown. */
function colorize(theme: Theme, color: FooterColor, text: string): string {
	if (text === "" || color === "") return text;
	if (isDirectColor(color)) return `${ansiForeground(color)}${text}\x1b[39m`;
	try {
		return theme.fg(color as ThemeColor, text);
	} catch {
		return text;
	}
}

function formatTokens(count: number): string {
	if (count < 1000) return count.toString();
	if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
	if (count < 1000000) return `${Math.round(count / 1000)}k`;
	if (count < 10000000) return `${(count / 1000000).toFixed(1)}M`;
	return `${Math.round(count / 1000000)}M`;
}

function formatCwd(cwd: string, home: string | undefined): string {
	if (!home) return cwd;
	const resolvedCwd = resolve(cwd);
	const resolvedHome = resolve(home);
	const rel = relative(resolvedHome, resolvedCwd);
	const inside = rel === "" || (rel !== ".." && !rel.startsWith(`..${sep}`) && !isAbsolute(rel));
	if (!inside) return cwd;
	return rel === "" ? "~" : `~${sep}${rel}`;
}

function sanitizeStatusText(text: string): string {
	return text
		.replace(/[\r\n\t]/g, " ")
		.replace(/ +/g, " ")
		.trim();
}

export default function (pi: ExtensionAPI) {
	// Auto-compaction state is not on ctx, so read it from settings and refresh
	// when the settings files change (the toggle writes there).
	let autoCompactEnabled = true;
	let watchers: FSWatcher[] = [];

	const refreshCompaction = (cwd: string, trusted: boolean) => {
		try {
			const settings = SettingsManager.create(cwd, getAgentDir(), { projectTrusted: trusted });
			autoCompactEnabled = settings.getCompactionEnabled();
		} catch {
			// keep the previous value
		}
	};

	pi.on("session_start", async (_event, ctx) => {
		if (ctx.mode !== "tui") return;

		refreshCompaction(ctx.cwd, ctx.isProjectTrusted());

		for (const w of watchers) w.close();
		watchers = [];
		for (const p of [join(getAgentDir(), "settings.json"), join(ctx.cwd, ".pi", "settings.json")]) {
			try {
				const w = watch(p, () => refreshCompaction(ctx.cwd, ctx.isProjectTrusted()));
				w.on("error", () => {});
				watchers.push(w);
			} catch {
				// settings file may not exist yet
			}
		}

		ctx.ui.setFooter((tui, theme, footerData) => {
			const unsubBranch = footerData.onBranchChange(() => tui.requestRender());

			return {
				dispose() {
					unsubBranch();
					for (const w of watchers) w.close();
					watchers = [];
				},
				invalidate() {},
				render(width: number): string[] {
					// Cumulative usage over every session entry.
					let input = 0;
					let output = 0;
					let cacheRead = 0;
					let cacheWrite = 0;
					let cost = 0;
					let latestCacheHitRate: number | undefined;

					for (const entry of ctx.sessionManager.getEntries()) {
						const usages: { input: number; output: number; cacheRead: number; cacheWrite: number; cost: { total: number } }[] = [];
						if (entry.type === "usage") {
							usages.push(entry.usage);
						} else if (entry.type === "message" && entry.message.role === "assistant") {
							usages.push(entry.message.usage);
							const u = entry.message.usage;
							const prompt = u.input + u.cacheRead + u.cacheWrite;
							latestCacheHitRate = prompt > 0 ? (u.cacheRead / prompt) * 100 : undefined;
						} else if (entry.type === "message" && entry.message.role === "toolResult" && entry.message.usage) {
							usages.push(entry.message.usage);
						} else if ((entry.type === "branch_summary" || entry.type === "compaction") && entry.usage) {
							usages.push(entry.usage);
						}
						for (const u of usages) {
							input += u.input;
							output += u.output;
							cacheRead += u.cacheRead;
							cacheWrite += u.cacheWrite;
							cost += u.cost.total;
						}
					}

					// Context usage. Same color thresholds as the built-in footer.
					const usage = ctx.getContextUsage();
					const contextPercentValue = usage?.percent ?? 0;

					const paint = (color: FooterColor, text: string) => colorize(theme, color, text);

					const cwd = formatCwd(ctx.sessionManager.getCwd(), process.env.HOME || process.env.USERPROFILE);
					const branch = footerData.getGitBranch();
					const sessionName = ctx.sessionManager.getSessionName();
					let pwdText = emphasize(paint(FOOTER_COLORS.path, cwd), PATH_BOLD);
					if (branch) {
						pwdText += `${paint(FOOTER_COLORS.separator, " (")}${paint(FOOTER_COLORS.branch, branch)}${paint(FOOTER_COLORS.separator, ")")}`;
					}
					if (sessionName) {
						pwdText += `${paint(FOOTER_COLORS.separator, " • ")}${paint(FOOTER_COLORS.session, sessionName)}`;
					}
					const pwdLine = truncateToWidth(pwdText, width, paint(FOOTER_COLORS.separator, "..."));

					const statsParts: string[] = [];
					if (input) statsParts.push(paint(FOOTER_COLORS.bandwidth, `↑${formatTokens(input)}`));
					if (output) statsParts.push(paint(FOOTER_COLORS.bandwidth, `↓${formatTokens(output)}`));
					if (cacheRead) statsParts.push(paint(FOOTER_COLORS.bandwidth, `R${formatTokens(cacheRead)}`));
					if (cacheWrite) statsParts.push(paint(FOOTER_COLORS.bandwidth, `W${formatTokens(cacheWrite)}`));
					if ((cacheRead > 0 || cacheWrite > 0) && latestCacheHitRate !== undefined) {
						statsParts.push(paint(FOOTER_COLORS.bandwidth, `CH${latestCacheHitRate.toFixed(1)}%`));
					}

					// The only change: tokens plus percent instead of tokens / window.
					const autoIndicator = autoCompactEnabled ? " (auto)" : "";
					const tokens = usage?.tokens;
					const percentText = usage?.percent == null ? "?" : `${contextPercentValue.toFixed(1)}%`;
					const contextDisplay =
						tokens == null
							? `? (${percentText})${autoIndicator}`
							: `· ${formatTokens(tokens)} (${percentText})${autoIndicator}`;
					const contextColor =
						contextPercentValue > 90
							? FOOTER_COLORS.contextCritical
							: contextPercentValue > 70
								? FOOTER_COLORS.contextWarning
								: FOOTER_COLORS.context;
					statsParts.push(emphasize(paint(contextColor, contextDisplay), CONTEXT_BOLD));
					if (cost) statsParts.push(paint(FOOTER_COLORS.bandwidth, `· $${cost.toFixed(3)}`));

					let statsLeft = statsParts.join(paint(FOOTER_COLORS.separator, " "));
					let statsLeftWidth = visibleWidth(statsLeft);
					if (statsLeftWidth > width) {
						statsLeft = truncateToWidth(statsLeft, width, paint(FOOTER_COLORS.separator, "..."));
						statsLeftWidth = visibleWidth(statsLeft);
					}

					const minPadding = 2;
					const modelName = ctx.model?.id || "no-model";
					const rightSideParts = [paint(FOOTER_COLORS.model, modelName)];
					if (ctx.model?.reasoning) {
						const level = ctx.thinkingLevel || "off";
						const label = level === "off" ? "thinking off" : level;
						rightSideParts.push(paint(FOOTER_COLORS.separator, " • "), paint(FOOTER_COLORS.thinking, label));
					}
					let rightSide = rightSideParts.join("");
					if (footerData.getAvailableProviderCount() > 1 && ctx.model) {
						const withProvider = paint(FOOTER_COLORS.model, `(${ctx.model.provider}) `) + rightSide;
						if (statsLeftWidth + minPadding + visibleWidth(withProvider) <= width) rightSide = withProvider;
					}

					const spaces = (count: number) => paint(FOOTER_COLORS.separator, " ".repeat(Math.max(0, count)));
					const rightSideWidth = visibleWidth(rightSide);
					let statsLine: string;
					if (statsLeftWidth + minPadding + rightSideWidth <= width) {
						statsLine = statsLeft + spaces(width - statsLeftWidth - rightSideWidth) + rightSide;
					} else {
						const availableForRight = width - statsLeftWidth - minPadding;
						if (availableForRight > 0) {
							const truncatedRight = truncateToWidth(rightSide, availableForRight, "");
							statsLine = statsLeft + spaces(width - statsLeftWidth - visibleWidth(truncatedRight)) + truncatedRight;
						} else {
							statsLine = statsLeft;
						}
					}

					const lines = [pwdLine, statsLine];

					const extensionStatuses = footerData.getExtensionStatuses();
					if (extensionStatuses.size > 0) {
						const statusLine = Array.from(extensionStatuses.entries())
							.sort(([a], [b]) => a.localeCompare(b))
							.map(([, text]) => sanitizeStatusText(text))
							.join(" ");
						lines.push(truncateToWidth(statusLine, width, paint(FOOTER_COLORS.separator, "...")));
					}
					return lines;
				},
			};
		});
	});
}
