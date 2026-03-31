# Claude Code Skills

我的自定义 Claude Code Skills 合集。

## Skills 列表

### organize-invoices - 发票整理助手

自动整理发票文件，识别类型、提取价格、重命名并生成统计。

**使用方法**：
```bash
# 方法1：在Claude Code中使用skill命令
/organize-invoices

# 方法2：直接对话
"帮我整理发票"
"整理一下这个文件夹的发票"
```

**功能**：
- 识别类型：餐饮、打车、火车、机票、住宿
- 提取价格：自动从发票内容提取金额
- 重命名：类型_价格.pdf 格式
- 去重：自动跳过重复发票
- 统计：生成详细的汇总报告

**支持格式**：PDF、OFD、ZIP

**输出**：
- `整理后的发票_YYYYMMDD/` 文件夹（带日期）
- `发票统计汇总_YYYYMMDD.xlsx` Excel统计报告（带日期，保存在整理文件夹的上一层）

## 技术实现

脚本模板位于：`~/.claude/skills/process_invoices_template.py`

包含完整的发票处理逻辑：
- PDF/OFD文本提取
- 智能类型识别
- 价格提取算法
- 去重和统计

## 依赖

需要安装以下Python库：
```bash
pip3 install PyPDF2 pdfplumber openpyxl --user
```

## 注意事项

- 原始文件不会被修改或删除
- 如果价格提取失败，文件名会标记为"未知金额"
- OFD文件会被转换为PDF格式保存
- 所有价格统一按照"价税合计"（含税总额）统计
- Excel统计文件包含格式化的表格，便于查看和分析
- 文件夹和Excel文件名都包含日期（YYYYMMDD格式），便于归档管理
- Excel文件保存在整理文件夹的上一层，方便查看和管理

---

### pdf2md - PDF转Markdown

将PDF文件转换为干净的Markdown文档。支持图片型PDF，自动去除水印和广告，保留原文格式。

**使用方法**：
```bash
# 在Claude Code中使用skill命令
/pdf2md /path/to/文件.pdf
/pdf2md /path/to/pdf目录
/pdf2md /path/to/pdf目录 /path/to/输出目录

# 也可以用shell脚本批量处理
./pdf2md/pdf2md_claude.sh /path/to/pdf目录
```

**功能**：
- 自动识别图片型/文字型PDF
- 逐页精准转录（利用Claude视觉能力）
- 自动去除水印和广告
- 保留原文加粗/强调格式
- 支持单文件和目录批量处理
- 已处理文件自动跳过

**安装**：将 `pdf2md/` 目录复制到 `~/.claude/skills/` 下即可。
