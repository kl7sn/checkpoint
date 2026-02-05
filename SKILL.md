---
name: checkpoint
description: 用户说 "ctx save" 时总结当前对话并按 ctx 规则存储；说 "ctx load" 时指导从 ctx 读回。也响应「保存对话」「创建 checkpoint」「插入 checkpoint」等表述。
---

# Checkpoint Skill

## 目标
- **ctx save**：由 AI 总结当前对话，生成带时间戳标题，**直接写入** 指定或默认的 checkpoint 目录（目录不存在则创建）；同时可在回复中给出全文，供用户用 ctx 扩展粘贴（可选）。
- **ctx load**：从指定或默认的 checkpoint 目录读取指定或最近的 checkpoint 文件，或将内容展示/插入；也可指导用户用 ctx list / ctx insert 读回。
- **自定义目录**：支持用户自定义 checkpoint 文件夹路径（见下方「路径解析」）。

## 触发
- `ctx save` / `ctx load`
- 「保存当前对话」「创建 checkpoint」「插入/读取 checkpoint」等同义表述。

---

## 一、ctx save 流程

当用户要求保存（如输入 **ctx save**）时：

1. **总结当前对话**
   - **用户输入**：必须**详细记录**。保留用户的原意、需求、指定路径/文件名/代码片段等，尽量不删减；**相似的内容可合并为一条**，按主题或意图归类（例如同一类需求、同一文件的多次提及写在一起），便于阅读和后续 ctx load 时还原意图。**若用户输入中出现 `-f xxx`，则 `-f` 后面的内容（xxx）必须完整记录，不可省略。**
   - **AI 输出**：**简要概括**即可。只保留结论、改动的文件与关键步骤、达成的共识，不必保留完整回复原文。
   - 可再补一段：背景（在做什么）、未决/后续（待办或可继续方向）。整体用 Markdown，便于阅读和检索。

2. **生成文件名**（格式：`checkpoint-时间-简短总结.md`）
   - **时间**：执行 `gen_title.sh` 得到展示用标题；文件名中的时间用 `YYYY-MM-DD-HHmm`（无空格），可由 `date "+%Y-%m-%d-%H%M"` 得到。
   - **简短总结**：由 AI 根据对话主题生成 3～8 个词的 slug，用英文或拼音、连字符连接、无空格（例如 `writer-kwebback-utility-classes`、`shape-childModelType-fix`），便于检索且文件名安全。
   - **最终文件名**：`checkpoint-YYYY-MM-DD-HHmm-<简短总结>.md`，例如 `checkpoint-2026-02-05-1801-writer-kwebback-sync.md`。

3. **写入文件**
   - **路径解析**：当次用户指定路径（如「存到 ~/checkpoints」或 `ctx save -d /path`）> 环境变量 `CHECKPOINT_DIR` > 默认 `/tmp/checkpoint`。解析后得到目录 `DIR`（若为 `~` 或含 `~` 需展开为用户主目录）。
   - 确保目录存在：`mkdir -p DIR`
   - 将总结写入：`DIR/checkpoint-<时间>-<简短总结>.md`。
   - 回复中说明已写入的完整路径。

4. **可选：供 ctx 扩展使用**
   - 在回复中同时给出标题与总结全文（代码块），若用户希望用 ctx save 粘贴到扩展，可自行操作。
   - 提醒之后可用 **ctx load** 从文件读回，或用 **ctx list** / **ctx insert** 读回。

---

## 二、ctx load 流程

当用户要求读取（如输入 **ctx load**）时，优先从 **文件** 读回：

1. **从 checkpoint 目录读文件**
   - **路径解析**：当次用户指定路径（如「从 ~/checkpoints 读」或 `ctx load -d /path`）> 环境变量 `CHECKPOINT_DIR` > 默认 `/tmp/checkpoint`。
   - 列出该目录下 `checkpoint-*.md` 文件，按时间或名称让用户选择，或取最近一条。
   - 若用户指定了名称（如「ctx load writer-kwebback-sync」或部分文件名），则匹配并读取对应 `checkpoint-<时间>-<简短总结>.md`。
   - 读取文件内容后，在回复中展示全文（或关键部分），便于继续对话或编辑。

2. **若用户希望从 ctx 扩展读回**
   - 说明：在 Cursor 中执行 **ctx list** 查看列表，再执行 **ctx insert** 选择要插入的 checkpoint。

3. **确认**
   - 读回后简短确认，并询问是否需要基于该内容继续。

---

## 三、总结格式（可后续优化）

当前建议的总结结构（**用户输入详记、AI 输出略记**）：

```markdown
## checkpoint-<时间>-<简短总结>

### 用户输入（详细记录）
- **主题/类别一**：（该主题下用户原话或完整要点，含路径/代码/需求；相似内容放一起）
- **主题/类别二**：…
- （尽量保留原意，不删减；相似输入可合并为一条）

### AI 输出（简要概括）
- （结论、改动的文件与关键步骤、共识；不必保留完整原文）

### 背景 / 未决
- 背景：（一句话）
- 未决/后续：（待办或可继续方向）
```

先按上述结构稳定跑通 **ctx save → 存储** 和 **ctx load → 读回**，再在技能内或单独文档里迭代「总结的步骤与格式」优化。

---

## 四、存储路径与补充

- **路径解析（优先级从高到低）**
  1. **当次指定**：用户在本轮输入中给出的路径。例如：「存到 ~/checkpoints」「ctx save -d /path」「从 ~/my-ctx 读」「ctx load -d /path」——则本次 save/load 使用该路径。
  2. **环境变量**：`CHECKPOINT_DIR`。若已设置（如 `export CHECKPOINT_DIR=~/checkpoints`），且用户未当次指定路径，则使用该目录。
  3. **默认**：`/tmp/checkpoint/`。
- **文件名格式**：`checkpoint-<时间>-<简短总结>.md`（时间：YYYY-MM-DD-HHmm；简短总结：由 AI 生成的英文/拼音 slug，连字符分隔）。目录不存在时先 `mkdir -p` 再写入。
- **记录原则**：执行 ctx save 时，**用户输入的内容一定要详细记录**，AI 输出的内容**简要概括**即可。用户输入中若有 **`-f xxx`**，**`-f` 后面的内容必须完整记录**，不可省略。
- **ctx load** 从解析得到的目录列出并读取 `checkpoint-*.md` 文件；用户也可选择从 ctx 扩展 list/insert 读回。
- 源优先级（当用户不明确说 ctx save 时）：剪贴板 > 编辑器选区 > 当前文档；若用户说「保存当前对话」，则走「总结当前对话 + 写入解析得到的 checkpoint 目录」流程。
