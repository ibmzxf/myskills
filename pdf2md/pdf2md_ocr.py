#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
pdf2md_ocr.py - 使用 PaddleOCR 提取 PDF 文本，输出纯文本（适合公众号文章等纯文字 PDF）

用法:
  python3 pdf2md_ocr.py <pdf_path>              # 输出到 stdout
  python3 pdf2md_ocr.py <pdf_path> <output.md>  # 输出到文件

安装依赖:
  pip install paddleocr paddlepaddle
"""

import sys
from pathlib import Path


def extract_pdf_to_markdown(pdf_path: str, output_path: str = None) -> bool:
    try:
        from paddleocr import PaddleOCR
    except ImportError:
        print("错误: 未安装 PaddleOCR，请运行: pip install paddleocr paddlepaddle", file=sys.stderr)
        return False

    try:
        # 只用文字检测+识别，不加载表格/公式等重型模型
        ocr = PaddleOCR(use_textline_orientation=False, lang="ch")
        result = ocr.predict(input=pdf_path)

        if not result:
            print("OCR 未提取到内容", file=sys.stderr)
            return False

        lines = []
        for page in result:
            if not page:
                continue
            rec_texts = page.get("rec_texts", []) if hasattr(page, "get") else []
            for text in rec_texts:
                if text and text.strip():
                    lines.append(text.strip())
            lines.append("")  # 页间空行

        combined = "\n".join(lines).strip()
        if not combined:
            print("OCR 提取内容为空", file=sys.stderr)
            return False

        if output_path:
            Path(output_path).write_text(combined, encoding="utf-8")
        else:
            print(combined)

        return True

    except Exception as e:
        print(f"OCR 处理失败: {e}", file=sys.stderr)
        return False


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("用法: python3 pdf2md_ocr.py <pdf_path> [output.md]", file=sys.stderr)
        sys.exit(1)

    pdf_path = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else None

    success = extract_pdf_to_markdown(pdf_path, output_path)
    sys.exit(0 if success else 1)
