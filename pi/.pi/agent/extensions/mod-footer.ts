/**
 * Token footer - same as the built-in footer, but shows context tokens
 * (e.g. `33.6k/1.0M`) instead of a percentage (`3.4%/1.0M`).
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
 */
import { type FSWatcher, watch } from "node:fs";
import { isAbsolute, join, relative, resolve, sep } from "node:path";
import { type ExtensionAPI, getAgentDir, SettingsManager } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

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
					const contextWindow = usage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
					const contextPercentValue = usage?.percent ?? 0;

					let pwd = formatCwd(ctx.sessionManager.getCwd(), process.env.HOME || process.env.USERPROFILE);
					const branch = footerData.getGitBranch();
					if (branch) pwd = `${pwd} (${branch})`;
					const sessionName = ctx.sessionManager.getSessionName();
					if (sessionName) pwd = `${pwd} • ${sessionName}`;

					const statsParts: string[] = [];
					if (input) statsParts.push(`↑${formatTokens(input)}`);
					if (output) statsParts.push(`↓${formatTokens(output)}`);
					if (cacheRead) statsParts.push(`R${formatTokens(cacheRead)}`);
					if (cacheWrite) statsParts.push(`W${formatTokens(cacheWrite)}`);
					if ((cacheRead > 0 || cacheWrite > 0) && latestCacheHitRate !== undefined) {
						statsParts.push(`CH${latestCacheHitRate.toFixed(1)}%`);
					}
					if (cost) statsParts.push(`$${cost.toFixed(3)}`);

					// The only change: tokens instead of percentage.
					const autoIndicator = autoCompactEnabled ? " (auto)" : "";
					const tokens = usage?.tokens;
					const contextDisplay =
						tokens == null
							? `?/${formatTokens(contextWindow)}${autoIndicator}`
							: `${formatTokens(tokens)}/${formatTokens(contextWindow)}${autoIndicator}`;
					let contextStr: string;
					if (contextPercentValue > 90) contextStr = theme.fg("error", contextDisplay);
					else if (contextPercentValue > 70) contextStr = theme.fg("warning", contextDisplay);
					else contextStr = contextDisplay;
					statsParts.push(contextStr);

					let statsLeft = statsParts.join(" ");
					let statsLeftWidth = visibleWidth(statsLeft);
					if (statsLeftWidth > width) {
						statsLeft = truncateToWidth(statsLeft, width, "...");
						statsLeftWidth = visibleWidth(statsLeft);
					}

					const minPadding = 2;
					const modelName = ctx.model?.id || "no-model";
					let rightSide = modelName;
					if (ctx.model?.reasoning) {
						const level = ctx.thinkingLevel || "off";
						rightSide = level === "off" ? `${modelName} • thinking off` : `${modelName} • ${level}`;
					}
					if (footerData.getAvailableProviderCount() > 1 && ctx.model) {
						const withProvider = `(${ctx.model.provider}) ${rightSide}`;
						if (statsLeftWidth + minPadding + visibleWidth(withProvider) <= width) rightSide = withProvider;
					}

					const rightSideWidth = visibleWidth(rightSide);
					let statsLine: string;
					if (statsLeftWidth + minPadding + rightSideWidth <= width) {
						const padding = " ".repeat(width - statsLeftWidth - rightSideWidth);
						statsLine = statsLeft + padding + rightSide;
					} else {
						const availableForRight = width - statsLeftWidth - minPadding;
						if (availableForRight > 0) {
							const truncatedRight = truncateToWidth(rightSide, availableForRight, "");
							const padding = " ".repeat(Math.max(0, width - statsLeftWidth - visibleWidth(truncatedRight)));
							statsLine = statsLeft + padding + truncatedRight;
						} else {
							statsLine = statsLeft;
						}
					}

					const dimStatsLeft = theme.fg("dim", statsLeft);
					const remainder = statsLine.slice(statsLeft.length);
					const dimRemainder = theme.fg("dim", remainder);
					const pwdLine = truncateToWidth(theme.fg("dim", pwd), width, theme.fg("dim", "..."));
					const lines = [pwdLine, dimStatsLeft + dimRemainder];

					const extensionStatuses = footerData.getExtensionStatuses();
					if (extensionStatuses.size > 0) {
						const statusLine = Array.from(extensionStatuses.entries())
							.sort(([a], [b]) => a.localeCompare(b))
							.map(([, text]) => sanitizeStatusText(text))
							.join(" ");
						lines.push(truncateToWidth(statusLine, width, theme.fg("dim", "...")));
					}
					return lines;
				},
			};
		});
	});
}
