/**
 * Mod Compact - auto-compaction at an absolute token threshold.
 *
 * Pi's built-in auto-compaction triggers at `contextWindow - reserveTokens`, so
 * the effective token number moves with the model. This extension triggers at a
 * fixed token count instead, which is easier to reason about when you switch
 * between models of different window sizes.
 *
 * Threshold source, in order:
 *   1. `~/.pi/agent/mod-compact.json` (created by `/mod-compact save`, reloaded
 *      automatically when the file changes):
 *        { "enabled": true, "thresholdTokens": 150000 }
 *   2. The DEFAULT_* constants below.
 *
 * Commands:
 *   /mod-compact                 show threshold and current context usage
 *   /mod-compact 150000          set the threshold for this session
 *   /mod-compact 150k            same, k/m suffixes accepted
 *   /mod-compact save [tokens]   persist the current (or given) threshold
 *   /mod-compact on|off          enable or disable for this session
 *   /mod-compact reset           back to the file/default values
 *
 * The built-in `"compaction": { "enabled": false }` setting also silences this
 * extension, so the usual global off switch keeps working.
 *
 * Place in ~/.pi/agent/extensions/ and run /reload.
 */

import * as fs from "node:fs";
import { basename, join } from "node:path";
import { type ExtensionAPI, type ExtensionContext, getAgentDir } from "@earendil-works/pi-coding-agent";

/** Fallback threshold when no config file exists. */
const DEFAULT_THRESHOLD_TOKENS = 200_000;

/** Fallback enabled state when no config file exists. */
const DEFAULT_ENABLED = true;

const CONFIG_FILE = "mod-compact.json";

interface CompactConfig {
	enabled: boolean;
	thresholdTokens: number;
}

function formatTokens(count: number): string {
	if (count < 1000) return count.toString();
	if (count < 10_000) return `${(count / 1000).toFixed(1)}k`;
	if (count < 1_000_000) return `${Math.round(count / 1000)}k`;
	return `${(count / 1_000_000).toFixed(1)}M`;
}

/** Accept `150000`, `150k`, `1.5m`, and `150_000`. Returns null when unparsable. */
function parseTokenCount(raw: string): number | null {
	const text = raw.trim().toLowerCase().replace(/[_,]/g, "");
	const match = /^(\d+(?:\.\d+)?)([km])?$/.exec(text);
	if (!match) return null;
	const value = Number.parseFloat(match[1]);
	const scale = match[2] === "k" ? 1_000 : match[2] === "m" ? 1_000_000 : 1;
	const tokens = Math.round(value * scale);
	return Number.isSafeInteger(tokens) && tokens > 0 ? tokens : null;
}

function readConfig(path: string): CompactConfig {
	const config: CompactConfig = { enabled: DEFAULT_ENABLED, thresholdTokens: DEFAULT_THRESHOLD_TOKENS };
	try {
		const parsed = JSON.parse(fs.readFileSync(path, "utf-8")) as Partial<CompactConfig>;
		if (typeof parsed.enabled === "boolean") config.enabled = parsed.enabled;
		if (typeof parsed.thresholdTokens === "number" && Number.isSafeInteger(parsed.thresholdTokens)) {
			if (parsed.thresholdTokens > 0) config.thresholdTokens = parsed.thresholdTokens;
		}
	} catch {
		// Missing or malformed file: keep defaults.
	}
	return config;
}

export default function (pi: ExtensionAPI) {
	const configPath = join(getAgentDir(), CONFIG_FILE);
	let config = readConfig(configPath);

	/** True while a compaction requested by this extension is in flight. */
	let compacting = false;
	/**
	 * False after a trigger, until context drops back to or below the threshold.
	 * Prevents a re-trigger loop when the threshold sits below keepRecentTokens.
	 */
	let armed = true;
	let watcher: fs.FSWatcher | undefined;

	const reloadConfig = () => {
		config = readConfig(configPath);
	};

	pi.on("session_start", async () => {
		reloadConfig();
		compacting = false;
		armed = true;

		watcher?.close();
		watcher = undefined;
		const dir = getAgentDir();
		try {
			// Watch the directory, not the file: the file may not exist yet and an
			// atomic save replaces its inode, which breaks a file-level watcher.
			watcher = fs.watch(dir, (_eventType, filename) => {
				if (filename && basename(String(filename)) === CONFIG_FILE) reloadConfig();
			});
			watcher.on("error", () => {});
		} catch {
			// Directory may be unavailable; the config just stops hot-reloading.
		}
	});

	pi.on("session_shutdown", () => {
		watcher?.close();
		watcher = undefined;
	});

	const triggerCompaction = (ctx: ExtensionContext, tokens: number) => {
		compacting = true;
		armed = false;
		if (ctx.hasUI) {
			ctx.ui.notify(`Context ${formatTokens(tokens)} > ${formatTokens(config.thresholdTokens)}, compacting`, "info");
		}
		ctx.compact({
			onComplete: () => {
				compacting = false;
			},
			onError: (error) => {
				compacting = false;
				if (ctx.hasUI) {
					ctx.ui.notify(`Compaction failed: ${error.message}`, "error");
				}
			},
		});
	};

	pi.on("turn_end", (_event, ctx) => {
		const usage = ctx.getContextUsage();
		const tokens = usage?.tokens ?? null;
		if (tokens === null) return;

		if (tokens <= config.thresholdTokens) {
			armed = true;
			return;
		}

		if (!config.enabled || compacting || !armed) return;

		// Respect the global auto-compaction off switch.
		if (pi.getSettings().compaction?.enabled === false) return;

		triggerCompaction(ctx, tokens);
	});

	pi.registerCommand("mod-compact", {
		description: "Toggle, set, or persist the absolute auto-compaction token threshold",
		handler: async (args, ctx) => {
			const parts = args.trim().split(/\s+/).filter(Boolean);
			const notify = (text: string, level: "info" | "warning" | "error" = "info") => {
				if (ctx.hasUI) ctx.ui.notify(text, level);
			};

			const describe = () => {
				const usage = ctx.getContextUsage();
				const current = usage?.tokens != null ? formatTokens(usage.tokens) : "unknown";
				const state = config.enabled ? "on" : "off";
				notify(`mod-compact: ${state}, threshold ${formatTokens(config.thresholdTokens)}, context ${current}`);
			};

			const applyTokens = (raw: string): boolean => {
				const tokens = parseTokenCount(raw);
				if (tokens === null) {
					notify(`Invalid token count: ${raw}`, "error");
					return false;
				}
				config = { ...config, thresholdTokens: tokens };
				armed = true;
				return true;
			};

			const persist = () => {
				try {
					fs.writeFileSync(configPath, `${JSON.stringify(config, null, 2)}\n`);
					notify(`Saved ${configPath}`);
				} catch (error) {
					notify(`Could not write ${configPath}: ${(error as Error).message}`, "error");
				}
			};

			const [first, second] = parts;
			if (!first) {
				describe();
				return;
			}

			switch (first) {
				case "on":
				case "off":
					config = { ...config, enabled: first === "on" };
					if (config.enabled) armed = true;
					describe();
					return;
				case "reset":
					config = readConfig(configPath);
					armed = true;
					describe();
					return;
				case "save":
					if (second && !applyTokens(second)) return;
					persist();
					return;
				default:
					if (!applyTokens(first)) return;
					describe();
					return;
			}
		},
	});
}
