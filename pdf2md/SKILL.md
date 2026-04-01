---
name: pdf2md
description: 将PDF文件转换为干净的Markdown文档。支持图片型PDF，自动去除水印和广告，保留原文格式。PaddleOCR预提取+Claude格式化，批量处理速度大幅提升。
argument-hint: "[PDF文件或目录路径] [输出目录(可选)]"
disable-model-invocation: true
allowed-tools: Read, Write, Bash(mkdir *), Bash(ls *), Bash(wc *), Bash(find *), Bash(python3 *), Glob
---

# PDF 转 Markdown 技能

将指定的PDF文件或目录下的所有PDF转换为干净、准确的Markdown文档。

## 输入

- `$ARGUMENTS[0]`：PDF文件路径或包含PDF的目录路径（必填）
- `$ARGUMENTS[1]`：输出目录路径（可选，默认为输入目录下的 `md/` 子目录）

## 处理流程

### 单文件模式
如果输入是一个 `.pdf` 文件：

**第一步：PaddleOCR 提取文本**
```bash
python3 ~/.claude/skills/pdf2md/pdf2md_ocr.py <pdf_path> /tmp/ocr_out.md
```
- 若失败（未安装 PaddleOCR）：报错提示安装，终止处理

**第二步：格式化并写入**
- 用 Read 工具读取 `/tmp/ocr_out.md`
- 将内容按转录要求整理成 Markdown
- 用 Write 工具写入输出目录

### 目录模式
如果输入是一个目录：
1. 用 `find` 查找目录下所有 `.pdf` 文件（最深2层子目录）
2. 逐个处理每个PDF文件
3. 已存在且大于10KB的md文件自动跳过

## 转录要求

对每个PDF文件，请严格遵循以下要求：

1. **标题**：第一行用 `# 标题`（从PDF内容中提取文章标题，去掉"付费文"等商业标记）
2. **元信息**：第二行写作者和日期信息
3. **段落**：段落之间用空行分隔
4. **加粗**：PDF中加粗、红色、或特别强调的文字用 `**加粗**` 标记
5. **水印过滤**：忽略所有水印文字，常见水印包括但不限于：
   - 明公读书会
   - 2819817355
   - knn5318、knn6475
   - 进群加薇/微
   - 获取更多优质资源
6. **广告过滤**：忽略末尾的VIP广告、评论区、文章链接列表等非正文内容
7. **准确性**：逐字逐句准确转录，不要遗漏、改动或"改善"原文内容
8. **口语风格**：保留作者的口语化写作风格，不要书面化

## 输出格式示例

```markdown
# 文章标题

原创 作者名 公众号名 2025年1月1日

正文第一段内容……

正文第二段内容……

**这是加粗的重点内容。**

## 第一个话题：小标题

话题正文内容……
```

## 注意事项

- **PaddleOCR 安装**：
  ```bash
  pip install 'paddleocr[doc-parser]'
  ```
- 处理完成后报告：文件名、大小、是否成功
