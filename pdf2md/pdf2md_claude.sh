#!/bin/bash
# PDF转Markdown自动化脚本 - 使用Claude Code直接处理
# 用法:
#   处理单个文件: ./pdf2md_claude.sh /path/to/file.pdf [输出目录]
#   处理整个目录: ./pdf2md_claude.sh /path/to/pdf/dir [输出目录]

set +e  # 不因单个文件失败而中断

INPUT="${1:?用法: $0 <PDF文件或目录> [输出目录]}"

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

    claude -p "你是一个PDF转录工具。请完成以下任务：

1. 用Read工具读取PDF文件: $pdf （如果页数多，分批读取，每次不超过20页）
2. 将PDF中的正文内容转录为markdown
3. 用Write工具将结果写入: $out_file

转录要求：
- 第一行用 # 标题（从PDF中提取文章标题，去掉"付费文"等标记）
- 第二行写作者和日期信息
- 段落之间用空行分隔
- 加粗/红色文字用 **加粗** 标记
- 忽略所有水印文字（明公读书会、2819817355、knn5318、knn6475、进群加薇/微等）
- 忽略末尾的VIP广告、评论区、文章链接列表等非正文内容
- 逐字逐句准确转录，不要遗漏或改动原文
- 不要输出任何说明文字，只执行任务" --dangerously-skip-permissions > /dev/null 2>&1

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
