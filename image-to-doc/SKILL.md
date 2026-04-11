---
name: image-to-doc
description: "从图片中提取文字并生成 Markdown、PDF、Word 文档。当用户上传图片（照片、扫描件、截图）并要求提取文字、OCR识别、转成文档时，必须使用本 Skill。触发关键词：提取文字、OCR、图片转文档、图片转文字、识别图片中的文字、复原文档、扫描件转文字、截图提取、图片内容提取。即使用户只是上传了若干图片并说'帮我把这些变成文档'或'提取图片里的内容'，也应触发本 Skill。当用户上传多张图片且图片内容是连续的文档页面时，尤其应当触发。"
---

# 图片文字提取与文档生成 (image-to-doc)

## 概述

将用户上传的图片（拍照、扫描件、截图等）中的文字内容逐字提取，并生成格式规范的 Markdown、PDF 和/或 Word（docx）文档。核心原则是 **逐字还原，不改不漏**。

## 工作流程

### 第一步：理解图片内容与顺序

1. 用户上传的图片通常是连续文档的多页。先浏览所有图片，确定正确的页序。
2. 识别文档的结构层次：标题、一级/二级/三级标题、正文段落、列表项等。
3. 注意区分：
   - **带序号的小标题**（如 `1.感知能力升级`）vs **正文段落**
   - **缩进的子条目** vs **独立段落**
   - **应用场景** 等固定格式段落

### 第二步：逐字提取文字

**核心原则：一字不差地还原原文。**

具体要求：
- 逐行、逐字识别图片中的文字，不得遗漏、替换、增添任何文字
- 保留原文的标点符号（中文标点），包括原文中的错误（如多余句号"。。"）
- 保留原文用词，即使看起来像笔误（如"效准"而非"校准"），除非用户明确要求修正
- 跨页内容需正确拼接，确保句子、段落在页面交界处不断裂、不重复
- 中文引号（""''）如实保留

**易错点检查清单：**
- 跨页拼接处是否完整、无重复
- 相似字确认：的/得/地、战/站、效/校、线/钱、已/己、亟/极
- 序号连续性：1. 2. 3. ... 是否齐全
- 括号、引号是否配对
- 专业术语是否准确（电力、法律、医疗等行业术语需特别注意）

### 第三步：生成 Markdown 文件

1. 将提取的文字按原文档结构组织为 Markdown 格式
2. 标题层级映射：
   - 文档大标题 → `# 标题`
   - 一级标题（如"一、总体需求"）→ `## 一、总体需求`
   - 二级标题（如"1.感知能力升级"）→ `### 1.感知能力升级`
3. 正文段落直接写，段落之间空一行
4. 列表条目如果原文是独立行但无项目符号，保持为独立段落（不要自行添加 `-` 或 `*`）
5. 输出到 `/mnt/user-data/outputs/` 目录

### 第四步：核对验证

**必须执行的核对步骤：**

1. 将生成的 Markdown 文件内容与每张原图逐页对照
2. 重点核对：
   - 每页的首行和末行是否正确（跨页拼接处）
   - 数字、序号是否正确
   - 专业术语是否准确
   - 标点符号是否与原文一致
3. 如发现差异，立即修正
4. 向用户报告核对结果，如有不确定的字词应主动说明

### 第五步：按需生成 PDF 和/或 docx

根据用户需求，基于已验证的 Markdown 内容生成其他格式。用户可能一次性要求所有格式，也可能分步追加。

#### 生成 PDF

优先使用 `wkhtmltopdf` 通过 HTML 中间格式生成：

1. 将 Markdown 内容转为 HTML，设置中文字体
2. HTML 样式要点：
   ```css
   body {
     font-family: "Noto Sans CJK SC", "Noto Serif CJK SC", sans-serif;
     font-size: 14px;
     line-height: 2;
     margin: 60px 70px;
   }
   h1 { text-align: center; font-size: 22px; }
   h2 { font-size: 18px; }
   h3 { font-size: 15px; text-indent: 2em; }
   p { text-align: justify; text-indent: 2em; margin: 4px 0; }
   p.item { text-indent: 0; }  /* 无缩进的条目行 */
   ```
3. 执行转换：
   ```bash
   wkhtmltopdf --encoding utf-8 --page-size A4 \
     --margin-top 25mm --margin-bottom 25mm \
     --margin-left 25mm --margin-right 25mm \
     input.html output.pdf
   ```

**备选方案**：`pandoc + xelatex`（需要 texlive-xetex 和 lmodern 包）：
```bash
pandoc input.md -o output.pdf --pdf-engine=xelatex \
  -V CJKmainfont="Noto Sans CJK SC" \
  -V geometry:margin=2.5cm -V fontsize=12pt
```

**注意**：不要使用 reportlab 的 TTFont 加载 Noto CJK 字体，因为这些字体是 CFF（PostScript）格式，reportlab 不支持，会报错 `postscript outlines are not supported`。

#### 生成 docx

参照 docx skill（`/mnt/skills/public/docx/SKILL.md`），使用 `docx-js`（npm 包 `docx`）生成。关键点：

- 先阅读 `/mnt/skills/public/docx/SKILL.md` 获取最新指引
- 使用 `Noto Sans CJK SC` 或系统可用的中文字体
- 正文设置首行缩进（`indent: { firstLine: 480 }`，约2个中文字符）
- 标题使用 HeadingLevel 映射

## 输出规范

| 格式 | 文件位置 | 说明 |
|------|---------|------|
| Markdown | `/mnt/user-data/outputs/文档标题.md` | 必须生成，作为基准文本 |
| PDF | `/mnt/user-data/outputs/文档标题.pdf` | 按用户需求生成 |
| docx | `/mnt/user-data/outputs/文档标题.docx` | 按用户需求生成 |

文件名取自文档大标题。如无明显标题，使用用户提供的文件名或按内容概括。

## 常见场景与处理方式

| 场景 | 处理 |
|------|------|
| 多页纸质文件拍照 | 按页序拼接，注意跨页断句 |
| 屏幕截图 | 直接识别，注意 UI 元素不要误提取 |
| 扫描件（图片已在 context 中） | 直接视觉识别 |
| 扫描件（图片不在 context 中） | 使用 tesseract OCR |
| 表格内容 | 在 Markdown 中用表格语法还原；PDF/docx 中用对应表格功能 |
| 图片中包含图表/插图 | 文字部分提取，图表以 `[图：描述]` 标注位置 |

## 注意事项

- **忠实原文是第一优先级**，排版美观是第二位的
- 如果图片模糊导致某些字无法确认，应在输出中标注 `[?]` 并告知用户
- 多张图片时，注意页面可能有重叠内容（拍照时重复拍摄），需去重但不要误删
- 用户可能先要求 Markdown，后续再追加要求 PDF 或 docx，支持增量生成
- 生成每种格式后，都使用 `present_files` 工具将文件呈现给用户
