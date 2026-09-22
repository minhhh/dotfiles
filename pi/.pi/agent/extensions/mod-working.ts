/**
 * Fun working message.
 *
 * Replaces the built-in "Working" loader text with a single unicode character.
 * Placed in ~/.pi/agent/extensions/ so it is auto-discovered and hot-reloadable
 * with /reload.
 *
 * Swap WORKING_CHAR for any of these if you get bored:
 *   "👀"  watching you work
 *   "🦑"  squid, tentacles busy
 *   "🫠"  melting, for long waits
 *   "🧠"  thinking
 *   "✦"   sparkle, single width, plays nice with the border
 *
 * Alternative working indicators:
 *   Plant growing:  🌱 → 🌿 → 🪴 → 🌳. Reads like the task is maturing.
 *   Face frames:    😐 → 😀. Optimistic.
 *   Moon phases:    🌑🌒🌓🌔🌕🌖🌗🌘. A full cycle feels like it takes exactly the right amount of time.
 *   Traffic light:  🔴🟡🟢. Implies something is about to start.
 *   Spinner:
 *     ctx.ui.setWorkingIndicator({ frames: ["◐","◓","◑","◒"], intervalMs: 120 });
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const WORKING_CHAR = "pondering";

export default function (pi: ExtensionAPI) {
	pi.on("session_start", async (_event, ctx) => {
		ctx.ui.setWorkingMessage(WORKING_CHAR);
		ctx.ui.setWorkingIndicator({ frames: ["🌑", "🌒", "🌓", "🌔", "🌕", "🌖", "🌗", "🌘"], intervalMs: 120 });
	});
}
