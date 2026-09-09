#!/usr/bin/env bash
# 구이린 공동경비 장부 — GitHub Pages 배포
# 사전 준비: 깃허브에서 (1) 빈 public 저장소 생성  (2) Personal Access Token 발급
set -uo pipefail
cd "$(dirname "$0")"

echo "구이린 공동경비 장부 — GitHub 배포"
echo "────────────────────────────────────"

# 1) 소스에서 index.html 재생성
./build.sh

# 2) 커밋 신원 (이 저장소에만 설정)
if [ -z "$(git config user.name || true)" ]; then
  read -r -p "커밋에 쓸 이름   : " GIT_NAME
  git config user.name "$GIT_NAME"
fi
if [ -z "$(git config user.email || true)" ]; then
  read -r -p "커밋에 쓸 이메일 : " GIT_EMAIL
  git config user.email "$GIT_EMAIL"
fi

# 3) 저장소 정보 — 이미 연결돼 있으면 그대로 재사용
ORIGIN="$(git remote get-url origin 2>/dev/null)"
if [ -n "$ORIGIN" ]; then
  GH_USER="$(echo "$ORIGIN" | sed -E 's#.*github\.com[:/]([^/]+)/.*#\1#')"
  GH_REPO="$(echo "$ORIGIN" | sed -E 's#.*/([^/]+)(\.git)?$#\1#; s#\.git$##')"
  echo "연결된 저장소: $GH_USER/$GH_REPO"
else
  read -r -p "깃허브 사용자명  : " GH_USER
  read -r -p "저장소 이름      : " GH_REPO
  if [ -z "$GH_USER" ] || [ -z "$GH_REPO" ]; then
    echo "사용자명과 저장소 이름이 필요합니다."; exit 1
  fi
fi

# 4) 커밋
git add -A
if git rev-parse HEAD >/dev/null 2>&1; then
  git commit -m "구이린 공동경비 장부 업데이트" || echo "  (변경사항 없음 — 기존 커밋 사용)"
else
  git commit -m "구이린 공동경비 장부" || { echo "커밋할 내용이 없습니다."; exit 1; }
fi

# 5) 원격 연결 + 토큰을 키체인에 보관해 재입력 방지
if [ -z "$ORIGIN" ]; then
  git remote add origin "https://github.com/$GH_USER/$GH_REPO.git"
fi
git config --global credential.helper osxkeychain

# 6) 푸시
echo
echo "푸시합니다. 자격증명을 물으면:"
echo "  Username : $GH_USER"
echo "  Password : 발급받은 토큰 붙여넣기  (깃허브 비밀번호 아님)"
echo
git push -u origin main || { echo; echo "푸시 실패. 토큰 권한(Contents: Read and write)과 저장소 이름을 확인하세요."; exit 1; }

echo
echo "────────────────────────────────────"
echo "푸시 완료. 이제 Pages를 켜세요:"
echo "  https://github.com/$GH_USER/$GH_REPO/settings/pages"
echo "  Source: Deploy from a branch  /  Branch: main  /  Folder: (root)"
echo
echo "1~2분 뒤 공개 주소:"
echo "  https://$GH_USER.github.io/$GH_REPO/"
