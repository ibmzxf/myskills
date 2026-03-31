# Claude Code Skills

我的自定义 Claude Code Skills 合集。

## Skills 列表

| Skill | 说明 | 用法 |
|-------|------|------|
| [organize-invoices](./organize-invoices/) | 发票自动整理、识别、重命名、统计 | `/organize-invoices` |
| [pdf2md](./pdf2md/) | PDF转Markdown，支持图片型PDF | `/pdf2md <文件或目录>` |

## 安装

将需要的 skill 目录复制到 `~/.claude/skills/` 下即可：

```bash
# 克隆仓库
git clone https://github.com/ibmzxf/myskills.git

# 安装单个skill（以pdf2md为例）
cp -r myskills/pdf2md ~/.claude/skills/

# 或全部安装
cp -r myskills/pdf2md ~/.claude/skills/
cp -r myskills/organize-invoices ~/.claude/skills/
```

安装后在 Claude Code 中输入 `/` 即可看到对应的 skill。

---

### organize-invoices - 发票整理助手

自动整理发票文件，识别类型、提取价格、重命名并生成统计。

**用法**：`/organize-invoices`

**功能**：
- 识别类型：餐饮、打车、火车、机票、住宿
- 提取价格：自动从发票内容提取金额
- 重命名：`类型_价格.pdf` 格式
- 去重：自动跳过重复发票
- 统计：生成 `发票统计汇总_YYYYMMDD.xlsx`

**支持格式**：PDF、OFD、ZIP

**依赖**：`pip3 install PyPDF2 pdfplumber openpyxl --user`

**文件**：
- `SKILL.md` - Skill 定义
- `process_invoices_template.py` - 发票处理脚本模板

---

### pdf2md - PDF转Markdown

将PDF文件转换为干净的Markdown文档。支持图片型PDF，自动去除水印和广告，保留原文格式。

**用法**：
```bash
/pdf2md /path/to/文件.pdf              # 单文件
/pdf2md /path/to/pdf目录               # 整个目录
/pdf2md /path/to/pdf目录 /path/to/输出  # 指定输出目录
```

**功能**：
- 自动识别图片型/文字型PDF
- 逐页精准转录（利用Claude视觉能力）
- 自动去除水印和广告
- 保留原文加粗/强调格式
- 支持单文件和目录批量处理
- 已处理文件自动跳过

**依赖**：仅需 Claude Code CLI

**文件**：
- `SKILL.md` - Skill 定义
- `pdf2md_claude.sh` - 批量处理 Shell 脚本
