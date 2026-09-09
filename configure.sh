#!/usr/bin/env bash
# Supabase 연결 정보를 소스에 기록한다. 손으로 HTML을 편집할 필요가 없다.
set -uo pipefail
cd "$(dirname "$0")"
SRC="src/artifact-body.html"

echo "Supabase 연결 정보 입력"
echo "──────────────────────────────────────────"
echo "Supabase 대시보드 → Project Settings → API 에서 복사해 오세요."
echo

read -r -p "1) Project URL            : " SB_URL
read -r -p "2) anon / publishable 키  : " SB_KEY
read -r -p "3) 관리자 이메일 [admin@guilinpay.local] : " SB_EMAIL
SB_EMAIL="${SB_EMAIL:-admin@guilinpay.local}"

SB_URL="$(echo "$SB_URL" | tr -d '[:space:]' | sed 's#/$##')"
SB_KEY="$(echo "$SB_KEY" | tr -d '[:space:]')"

if ! echo "$SB_URL" | grep -qE '^https://[a-z0-9-]+\.supabase\.co$'; then
  echo; echo "✗ Project URL 형식이 올바르지 않습니다."
  echo "  https://xxxxxxxx.supabase.co 형태여야 합니다. 입력값: $SB_URL"
  exit 1
fi
if [ "${#SB_KEY}" -lt 20 ]; then
  echo; echo "✗ 키가 너무 짧습니다 (${#SB_KEY}자). 잘못 복사되지 않았는지 확인하세요."
  exit 1
fi
case "$SB_KEY" in
  *service_role*|sb_secret_*)
    echo; echo "✗ service_role / secret 키로 보입니다. 이 키는 RLS를 무시하므로 넣으면 안 됩니다."
    echo "  'anon public' 또는 'publishable' 키를 사용하세요."
    exit 1 ;;
esac

SB_URL="$SB_URL" SB_KEY="$SB_KEY" SB_EMAIL="$SB_EMAIL" SRC="$SRC" python3 - <<'PY'
import io, os, re
src, url, key, email = os.environ["SRC"], os.environ["SB_URL"], os.environ["SB_KEY"], os.environ["SB_EMAIL"]
s = io.open(src, encoding="utf-8").read()
s, a = re.subn(r'(const SUPABASE_URL\s*=\s*")[^"]*(")',      lambda m: m.group(1)+url+m.group(2),   s)
s, b = re.subn(r'(const SUPABASE_ANON_KEY\s*=\s*")[^"]*(")', lambda m: m.group(1)+key+m.group(2),   s)
s, c = re.subn(r'(const ADMIN_EMAIL\s*=\s*")[^"]*(")',       lambda m: m.group(1)+email+m.group(2), s)
if not (a and b and c):
    raise SystemExit("설정 자리를 찾지 못했습니다 (URL:%d KEY:%d EMAIL:%d)" % (a, b, c))
io.open(src, "w", encoding="utf-8").write(s)

# schema.sql 의 관리자 이메일도 함께 맞춘다 — 다르면 편집이 거부된다
sp = "supabase/schema.sql"
if os.path.exists(sp):
    q = io.open(sp, encoding="utf-8").read()
    q2, n = re.subn(r"'[^']*@[^']*'(\s*\))", lambda m: "'"+email+"'"+m.group(1), q)
    if n:
        io.open(sp, "w", encoding="utf-8").write(q2)
        print("  schema.sql 관리자 이메일 %d곳도 함께 맞췄습니다." % n)
PY
[ $? -ne 0 ] && exit 1

echo
echo "✓ 기록 완료"
echo "    URL   : $SB_URL"
echo "    KEY   : ${SB_KEY:0:12}…${SB_KEY: -4}  (${#SB_KEY}자)"
echo "    관리자 : $SB_EMAIL"
echo
echo "참고: anon 키는 프론트엔드에 공개되도록 설계된 키입니다."
echo "      공개 저장소에 커밋되지만 문제되지 않습니다. 권한은 DB의 RLS가 막습니다."
echo
echo "다음: ./deploy.sh 로 배포하세요."
