#!/usr/bin/env bash
# src/artifact-body.html (Artifact 발행용 본문) → index.html (GitHub Pages용 완전한 문서)
set -euo pipefail
cd "$(dirname "$0")"
python3 - <<'PY'
src = open("src/artifact-body.html", encoding="utf-8").read()
head, body = src.split("<!--BODY-->", 1)
open("index.html", "w", encoding="utf-8").write(
    '<!doctype html>\n<html lang="ko">\n<head>\n'
    '<meta charset="utf-8">\n'
    '<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">\n'
    '<meta name="color-scheme" content="light dark">\n'
    '<meta name="description" content="원화와 위안을 분리해 관리하는 한서대학교 교수파견 경비 장부">\n'
    + head.strip() + "\n</head>\n<body>\n" + body.strip() + "\n</body>\n</html>\n"
)
print("index.html 생성 완료")
PY
