# 你看看（Video Insight）

把 B 站、YouTube 或本地视频整理成 **带时间码的分镜图 + 可核查的文字证据**，再交给支持看图的 AI 进行总结、提示词提取和个性化分析。

这是一个可复用的 Codex/ChatGPT Skill **源码仓库**，不是已经安装到你的 ChatGPT 中的 Skill。核心分镜能力来自 [SAOS-3624/dsh-video-storyboard](https://github.com/SAOS-3624/dsh-video-storyboard)（MIT）。本项目调用上游，不复制或改写其核心代码。

## 自然口令：「你看看」

把这个 Skill **实际安装到可识别 Skills 的聊天环境之后**，你发一个 B 站 / YouTube 链接再说「你看看」，就应该按视频分析流程运行。不需要反复写出内部名字。**仅在 GitHub 存放源码不等于已安装**；在安装前，新聊天不保证自动识别。只有「你看看」却没有明确视频对象时，应先确认需要看什么，而不是误触发。

## 能做什么

- **快速看视频**：默认 6 格分镜，先读整体，再按时间码放大重点。
- **认真看视频**：12 格、2 张分镜，适合提取演讲中的具体观点和提示词。
- **区分事实与推断**：保留时间码、原话或字幕来源；没有音频转写时不假装听懂了台词。
- **低成本**：只把少量分镜和所需的文字喂给模型，不逐帧传整段视频。实际 token 与费用依模型、图片计费方式和转写服务而异；**不承诺“2 分钱”**。

## 本机使用

需要 Bash、Git、Node.js 20+、ffmpeg、ffprobe；处理网络链接时另外需要 yt-dlp。macOS/Linux 可直接使用脚本；Windows 建议 WSL。视频下载、字幕转写和 AI 模型调用都可能产生不同费用。

~~~bash
git clone https://github.com/tina1yan/video-insight.git
cd video-insight
bash scripts/setup-engine.sh
bash scripts/video-insight.sh 'https://www.bilibili.com/video/BV...' --quick
# 或分析本地文件并读取已有字幕：
bash scripts/video-insight.sh '/path/to/video.mp4' --deep --transcript-file '/path/to/subtitles.srt'
~~~

运行结束会显示本地输出目录，包含 `storyboard.png`（deep 模式可能有多张）、`manifest.json` 和 `notes.txt`。然后把图和文字交给支持看图的 AI，并附上自己的分析目标。若只用纯文本模型（包括不支持图片输入的 API），它无法直接看分镜图。

> **重要**：分镜图只解决“看画面”；完整理解口播仍需要字幕或 ASR。B 站登录态视频可能无法匿名获取，建议使用自己有权处理的本地文件；不要把 cookies、API 密钥或含隐私的视频上传到 GitHub。

## Skill 使用

Skill 入口是 [SKILL.md](SKILL.md)。支持 Skills 的环境可以从该文件及 `agents/openai.yaml` 读取流程说明；是否能实际安装和自动调用取决于宿主环境的 Skill 安装机制及相关工具权限。

示例提问：

> 使用 $video-insight 分析这条 B 站视频，精确提取视频中的提示词，指出哪些结论有直接证据，并结合我的职业发展给出建议。

## 目录

- `SKILL.md`：AI 操作流程（优先字幕，分镜取证，局部细看，带出处分析）
- `scripts/setup-engine.sh`：手动安装固定版本的开源引擎
- `scripts/video-insight.sh`：快速/深度分镜处理入口
- `references/engine.md`：依赖、限制、版权与故障提示
- `agents/openai.yaml`：Skill 界面元数据

## 上游来源

[SAOS-3624/dsh-video-storyboard](https://github.com/SAOS-3624/dsh-video-storyboard), pinned at `0c03a7d78307d7e8e2b8e6bcaa9d1673d79d3333`. Its code is used separately under its own MIT license. See [references/engine.md](references/engine.md).
