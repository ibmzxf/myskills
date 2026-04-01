#!/bin/bash
# PDF转Markdown自动化脚本 - PaddleOCR预提取 + Claude格式化
# 用法:
#   处理单个文件: ./pdf2md_claude.sh /path/to/file.pdf [输出目录]
#   处理整个目录: ./pdf2md_claude.sh /path/to/pdf/dir [输出目录]

set +e  # 不因单个文件失败而中断

INPUT="${1:?用法: $0 <PDF文件或目录> [输出目录]}"
SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"
OCR_SCRIPT="$SKILL_DIR/pdf2md_ocr.py"

total=0
done_count=0
skip=0

process_pdf() {
    local pdf="$1"
    local out_dir="$2"
    local name=$(basename "$pdf" .pdf)
    local out_file="$out_dir/${name}.md"

    total=$((total + 1))

    # 如果已存在且大于10KB，跳过
    if [ -f "$out_file" ] && [ $(wc -c < "$out_file") -gt 10240 ]; then
        echo "[$total] 跳过（已存在）: $name"
        skip=$((skip + 1))
        return
    fi

    echo "[$total] 处理中: $name"

    # 用 PaddleOCR 提取文本
    local ocr_tmp
    ocr_tmp=$(mktemp /tmp/pdf2md_ocr_XXXXXX.md)

    if ! python3 "$OCR_SCRIPT" "$pdf" "$ocr_tmp" 2>/dev/null || [ ! -s "$ocr_tmp" ]; then
        echo "  -> OCR 失败！请安装 PaddleOCR: pip install 'paddleocr[doc-parser]'"
        rm -f "$ocr_tmp"
        return
    fi

    echo "  -> OCR 提取成功，Claude 格式化..."
    claude -p "你是 Markdown 格式化工具。
1. 用 Read 工具读取 OCR 提取的原始文本: $ocr_tmp
2. 整理成干净的 Markdown 格式
3. 用 Write 工具将结果写入: $out_file

格式要求：
- 第一行 # 标题（提取文章标题，去掉"付费文"等标记）
- 第二行写作者和日期信息
- 段落之间用空行分隔
- 加粗/强调文字用 **加粗** 标记
- 忽略所有水印（明公读书会、2819817355、knn5318、knn6475、进群加薇/微等）
- 忽略末尾的 VIP 广告、评论区、文章链接列表等非正文内容
- 逐字逐句准确转录，不要遗漏或改动原文
- 只输出 Markdown 内容，不要任何说明文字" --dangerously-skip-permissions > /dev/null 2>&1

    rm -f "$ocr_tmp"

    if [ -f "$out_file" ] && [ $(wc -c < "$out_file") -gt 1024 ]; then
        local size=$(wc -c < "$out_file")
        echo "  -> 完成 (${size} bytes)"
        done_count=$((done_count + 1))
    else
        echo "  -> 失败！"
    fi
}

# 判断输入是文件还是目录
if [ -f "$INPUT" ]; then
    OUT_DIR="${2:-$(dirname "$INPUT")/md}"
    mkdir -p "$OUT_DIR"
    process_pdf "$INPUT" "$OUT_DIR"
elif [ -d "$INPUT" ]; then
    OUT_DIR="${2:-$INPUT/md}"
    mkdir -p "$OUT_DIR"
    while IFS= read -r -d '' pdf; do
        process_pdf "$pdf" "$OUT_DIR"
    done < <(find "$INPUT" -maxdepth 2 -name "*.pdf" -not -path "*/md/*" -print0 | sort -z)
else
    echo "错误: $INPUT 不是有效的文件或目录"
    exit 1
fi

echo ""
echo "完成！共 $total 个文件，处理 $done_count 个，跳过 $skip 个"
echo "输出目录: $OUT_DIR"
