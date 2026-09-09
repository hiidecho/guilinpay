# 구이린 공동경비 장부

광시사범대학 구이린 파견 교수진의 공동경비를 **원화(KRW)와 위안(CNY)을 섞지 않고** 각각의 지갑으로 관리하는 단일 HTML 장부입니다.

## 무엇이 들어 있나

| 파일 | 설명 |
|---|---|
| `index.html` | 배포용 완성본. 이 파일 하나만 있으면 동작합니다. |
| `src/artifact-body.html` | 실제 소스. 스타일·마크업·데이터·스크립트가 모두 여기에 있습니다. |
| `build.sh` | `src/artifact-body.html` → `index.html` 생성 |

수정은 **`src/artifact-body.html`을 고친 뒤 `./build.sh`** 를 실행하세요.
`index.html`을 직접 고치면 다음 빌드 때 덮어써집니다.

## 기능

- 구성원별 원화·위안 잔액과 **투입액 대비 남은 비율 막대**
- 사용내역 등록: 동일금액 / 총액 나누기 / 개별금액 3가지 입력 방식
- 금액 추가(추가 환전·추가 회비), 내역 수정·삭제, 구성원 추가·비활성화
- 이름을 누르면 개인별 상세 내역, 인원 수를 누르면 참여자별 부담액
- CSV 내려받기 (엑셀에서 한글이 깨지지 않도록 BOM 포함)
- 라이트/다크 테마 자동 대응

## 데이터가 저장되는 곳

페이지가 어디에 올라가 있느냐에 따라 두 가지로 동작하며, 우측 상단 배지가 현재 상태를 알려줍니다.

- **공유 저장** — Claude Artifact로 발행한 경우. 관리자가 등록한 내역이 새 버전으로 발행되어, 링크를 연 **모든 사람의 화면에 반영**됩니다.
- **이 브라우저에만 저장** — GitHub Pages 등 정적 호스팅이나 파일을 직접 연 경우. 데이터는 `localStorage`에 저장되므로 **보는 사람마다 자기 화면만 바뀝니다.**

> 여러 명이 같은 장부를 함께 보려면 Artifact 링크를 쓰세요.
> GitHub Pages 판은 "각자 자기 기기에서 쓰는 계산기"에 가깝습니다.

## GitHub Pages로 올리기

```bash
git init -b main
git config user.name  "본인 이름"
git config user.email "본인@이메일"
git add -A
git commit -m "구이린 공동경비 장부"
git remote add origin https://github.com/<사용자명>/<저장소명>.git
git push -u origin main
```

푸시한 뒤 GitHub 저장소에서 **Settings → Pages → Source: `main` / `(root)`** 를 선택하면
1~2분 뒤 `https://<사용자명>.github.io/<저장소명>/` 에서 열립니다.

## 알아두실 점

- 관리자 PIN(기본 `1234`)은 **실수 방지용 잠금**이지 보안 장치가 아닙니다. 정적 HTML이라 소스를 보면 확인할 수 있습니다.
- 이 장부에는 **실명과 금액**이 들어 있습니다. 공개(public) 저장소로 올리면 누구나 검색해 볼 수 있으니, 내부용이라면 **private 저장소 + Pages** 조합을 쓰시거나 Artifact 링크를 공유하세요.
