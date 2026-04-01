# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a Claude Code **skills** repository. Skills are prompt files (`*.md`) that teach Claude Code how to perform specific tasks. The primary skill here is `organize-invoices` — an automated invoice processing assistant for Chinese invoices.

## Skills Architecture

Each skill consists of:
- A **skill definition file** (`<skill-name>.md`) — describes the task, implementation steps, and technical details. This is what Claude Code reads when invoked via `/organize-invoices` or natural language trigger.
- A **Python template** (`process_invoices_template.py`) — a reference implementation. When the skill runs, it generates a fresh `process_invoices.py` in the user's working directory (not this repo) and executes it.

The skill does **not** run `process_invoices_template.py` directly — it uses it as a blueprint to create and run a script in the user's invoice directory.

## Key Design Decisions

- **OFD text extraction** is preferred over PDF when both formats exist for the same invoice (OFD extracts cleaner text from Chinese e-invoices).
- **Deduplication** uses `(type, price)` as the key — same type and price = duplicate, skip.
- **Price priority**: 价税合计 > 票价 > 金额合计 > 合计 > ¥ pattern (max value). All prices are tax-inclusive totals.
- **Output location**: Renamed PDFs go into `整理后的发票_YYYYMMDD/` in the user's working directory; the Excel summary goes one level up from that folder.
- ZIP files are extracted to `temp_unzip/` before processing; original files are never modified.

## Dependencies (user must install)

```bash
pip3 install PyPDF2 pdfplumber openpyxl --user
```

## Supported Invoice Types and Keywords

| Type | Keywords |
|------|----------|
| 餐饮 | 餐饮、饭店、餐厅、烤、食品、美食 |
| 打车 | 滴滴、打车、出租、网约车、快车、专车 |
| 火车 | 火车、铁路、高铁、动车、车票、电子客票 |
| 机票 | 机票、代订机票、航空、飞机、国际旅行社、携程、航班 |
| 住宿 | 住宿、酒店、宾馆、旅馆、客栈 |

Note: 火车 is checked before 机票 to avoid "客票" being matched as 机票.
