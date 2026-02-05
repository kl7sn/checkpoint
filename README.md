# Checkpoint Skill

Cursor Agent Skill：用自然指令把当前对话总结成 checkpoint 存到本地，需要时再读回，方便跨会话接着聊或做备份。

## 功能

| 指令 | 说明 |
|------|------|
| **ctx save** | 总结当前对话，生成带时间戳的 Markdown，写入 checkpoint 目录（可自定义路径） |
| **ctx load** | 从 checkpoint 目录列出并读取最近或指定的 checkpoint，在回复中展示全文 |

同义表述也会触发：如「保存当前对话」「创建 checkpoint」「读取 checkpoint」等。

## 安装

### 方法一：通过 npx 一键安装（推荐）

```bash
npx skills add https://github.com/kl7sn/checkpoint.git
```

这是最简单的安装方式，会自动将技能安装到正确的目录。

### 方法二：通过 Git 克隆

```bash
# 克隆到 Claude Code 的 skills 目录
git clone https://github.com/kl7sn/checkpoint.git ~/.claude/skills/checkpoint
```

## 使用

- **保存**：在对话里输入 `ctx save`，AI 会总结对话并写入 `checkpoint-YYYY-MM-DD-HHmm-<简短总结>.md`。
- **读取**：输入 `ctx load`，AI 会从 checkpoint 目录取最近一条（或你指定的那条）并展示内容。
- **自定义目录**：
  - 当次指定：`ctx save -d ~/checkpoints`、`存到 ~/checkpoints`、`ctx load -d ~/my-ctx`、`从 ~/my-ctx 读`。
  - 持久默认：设置环境变量 `CHECKPOINT_DIR`，例如 `export CHECKPOINT_DIR=~/checkpoints`。

路径优先级：**当次指定 > 环境变量 `CHECKPOINT_DIR` > 默认 `/tmp/checkpoint`**。目录不存在会自动创建。

## 输出格式

每个 checkpoint 文件为 Markdown，结构大致如下：

```markdown
## checkpoint-<时间>-<简短总结>

### 用户输入（详细记录）
- **主题一**：用户原话与要点…
- **主题二**：…

### AI 输出（简要概括）
- 结论与改动摘要

### 背景 / 未决
- 背景：…
- 未决/后续：…
```

- **用户输入**：尽量完整保留原意、路径、代码片段；相似内容可合并为一条；若出现 `-f xxx`，`-f` 后内容必须完整记录。
- **AI 输出**：只写结论、关键步骤和共识的概括。

## 文件名规则

- 格式：`checkpoint-YYYY-MM-DD-HHmm-<slug>.md`
- 时间：24 小时制，无空格。
- slug：由 AI 根据对话主题生成，3～8 个词，英文或拼音，连字符连接，好找且文件名安全。例如：`writer-kwebback-sync`、`shape-childModelType-fix`。

## 与 ctx 扩展配合

- **ctx save** 后，AI 可在回复中给出总结全文（代码块），你可复制后通过 ctx 扩展粘贴保存。
- **ctx load** 默认从本地 checkpoint 目录读文件；若你更习惯用扩展，可在 Cursor 里用 **ctx list** 与 **ctx insert** 选择要插入的 checkpoint。

## 规范来源

具体行为与约定见同目录的 **SKILL.md**（触发条件、路径解析、总结格式和记录原则等）。

## License

MIT
