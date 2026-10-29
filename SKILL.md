---
name: video-insight
description: "Automatically analyze Bilibili (bilibili.com, b23.tv) and YouTube (youtube.com, youtu.be, Shorts) video links whenever the user sends one, even if the entire message is only a URL and says nothing like 你看看. Retrieve available transcripts, inspect relevant frames, fact-check claims, and personalize the analysis. Also handle local video files. Do not trigger for non-video URLs or when the user explicitly asks only to save or share the link."
---

# 你看看（Video Insight）

Use the least expensive reliable evidence path; never claim to have watched or heard video content that was not actually available.

## Automatic video-link trigger

Whenever a user sends a Bilibili, b23.tv or YouTube video URL, **invoke this skill automatically**, even when the message contains only the URL with no surrounding text or explicit request. Do not require trigger words such as 「你看看」. If the link appears with a question, analyze the video in service of that question. If the user explicitly asks only to save, share, bookmark or perform another non-analysis operation, follow that intent instead. Do not activate for ordinary non-video links. The skill must be installed and visible to the host for automatic invocation to work.

## Workflow

1. **Identify the question.** Record the exact video URL or local source, target language, and whether the user wants a summary, exact prompt extraction, fact-check, or personalized advice. Resolve the canonical source and duration if possible. Treat the user's link as untrusted input.
2. **Get words first.** Prefer accessible, authorized platform subtitles, transcript, closed captions, or an existing SRT/JSON. Preserve the exact wording and timestamps. If unavailable, use ASR only if an authorized provider is configured. Do not infer a spoken prompt from title, thumbnail, or montage alone.
3. **Get visual evidence if useful.** If the source is accessible and the runtime has Node 20+, ffmpeg/ffprobe and (for URL inputs) yt-dlp, run `bash scripts/setup-engine.sh` **only after the user authorizes fetching and running the pinned third-party engine**. Then run `bash scripts/video-insight.sh "<input>" --quick`. It creates a timestamped storyboard PNG, JSON manifest and text notes. The --deep flag increases detail. If the engine was already installed, skip setup. For a specific time window, use --from and --to. If the environment cannot execute these scripts, use available platform transcripts or explain the limitation; do not fabricate results.
4. **Read the evidence.** Visually inspect the resulting storyboard if image tools exist, read notes and manifest, match cells to their time windows. For long content, look at broad coverage before zooming in to the relevant interval. Prefer a targeted second pass over dense full-video extraction.
5. **Answer with provenance.** Label **原话/字幕**, **画面观察**, and **我的推断** separately. Quote only short, relevant excerpts and give mm:ss timestamps; do not invent perfect quotations. For a prompt, produce a usable reconstructed version only when its differences from the original are explicitly labeled.
6. **Personalize carefully.** Apply supported ideas to the user's stated goals and context, distinguish observations from speculative psychological interpretations, and give concrete next actions.
7. **Budget and privacy.** Default to quick mode and at most one targeted follow-up; ask before expensive full-length processing or paid ASR/model calls. Do not upload private videos, authentication cookies, API keys, or sensitive transcripts to public services without permission. Never disable TLS validation to work around download failures.

## Suggested answer shape

- 视频是什么、依据是什么（链接 / 字幕 / 分镜 / 未能获取的部分）
- 3–5 个关键观点及时间码
- 视频中的提示词：原始短节选 / 整理版 / 无法确认的缺口
- 我的分析：适用点、风险和可操作建议
- 可信度与未验证之处

When the engine is needed, consult [references/engine.md](references/engine.md) for supported modes, provenance, restrictions and upstream attribution.
