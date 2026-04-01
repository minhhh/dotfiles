---
name: extending-markdown-summary
description: Use when extending a summary of a book or technology, using a reference book or general knowledge. This skill provides a specialized workflow for identifying gaps in existing summaries and integrating detailed, actionable information from external sources while maintaining a consistent Markdown hierarchy.
---

# Extending Markdown Summary

## Overview

This skill enables the systematic extension of technical summaries. It focuses on maintaining structural integrity (`###` for chapters, `▼` for sub-sections) while enriching content with nuanced technical details, specific commands, and underlying rationale gathered from reference materials or general domain expertise.

## Workflow

### 1. Analyze Existing Summary
- Identify areas lacking technical depth or missing critical "how-to" details.
- Pinpoint sections that require more specific command-line examples or architectural context.
- Look for gaps where the "why" behind a troubleshooting step or best practice is omitted.

### 2. Gather External Context
- If a reference book is available, use `read_file` or `grep_search` to locate relevant chapters or sections.
- If a reference book is NOT available, Utilize `google_web_search` or `web_fetch` to find missing technical specifics from official documentation or reputable sources.
- Leverage general domain knowledge to provide context for abstract concepts.

### 3. Integrate and Format
- **Maintain Hierarchy**: Ensure new sections follow the `### Chapter` -> `▼ **Sub-section**` -> `* **Key Point**` pattern.
- **Actionable Details**: Prioritize including exact commands, configuration flags, and expected outputs.
- **Consistency**: Use the same tone and formatting style (e.g., bolding key terms, nested bullets for nuances) as the original summary.

## Guidelines

- **Nuance Matters**: Do not just add "more words." Add specific, actionable information that would help a practitioner solve a problem.
- **Visual Markers**: Always use the `▼` marker for sub-sections.
- **Code Blocks**: Ensure all commands are wrapped in language-specific markdown blocks (e.g., \`\`\`bash).
- **Technical Integrity**: Verify that any added information is accurate and contextually relevant to the original summary's scope.

## Example

### Chapter 2 Extension Example

▼ **Advanced Load Diagnosis**

* **Interpreting `si` and `hi`**: These metrics in `top` indicate time spent on software and hardware interrupts.
    * **High `si`**: Often points to network processing overhead or driver issues.
    * **High `hi`**: Can indicate hardware-level problems or excessive disk controller interrupts.
* `sar -q`: Use this command to view historical queue length and load averages, helping to identify if a system was "stalled" rather than just busy.
