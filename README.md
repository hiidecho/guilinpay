# 광서사범대 경비 장부

한서대학교 교수파견 교수진의 광서사범대 체류 경비를 **원화(KRW)와 위안(CNY)을 섞지 않고** 각각의 지갑으로 관리하는 장부입니다.

**https://hiidecho.github.io/guilinpay/**

## 구조

```
교수진 휴대폰 / PC
      │
      ▼
GitHub Pages  (화면)
      │  supabase-js
      ▼
Supabase      (PostgreSQL + Auth + 실시간)
```

별도의 API 서버는 없습니다. Supabase가 데이터베이스이자 백엔드입니다.
브라우저는 `anon` 키로 직접 붙고, 누가 무엇을 할 수 있는지는 **DB의 RLS 정책**이 결정합니다.

## 파일

| 파일 | 설명 |
|---|---|
| `index.html` | 배포본. GitHub Pages가 이 파일을 서빙합니다 |
| `src/artifact-body.html` | **실제 소스.** 여기만 고치세요 |
| `build.sh` | `src/` → `index.html` 생성 |
| `deploy.sh` | 재빌드 → 커밋 → 푸시 한 번에 |
| `supabase/README.md` | **Supabase 연결 준비 순서** |
| `supabase/schema.sql` | 표·권한(RLS)·실시간 설정 |
| `supabase/seed.sql` | 현재 데이터 초기 등록 |

`index.html` 을 직접 고치면 다음 빌드 때 덮어써집니다.

## 처음 설정

`supabase/README.md` 를 따라가세요. 요약하면:

1. Supabase 프로젝트 생성
2. `schema.sql` → `seed.sql` 순서로 SQL Editor에서 실행
3. Authentication에서 관리자 계정 생성 (**Auto Confirm User** 켜기)
4. 신규 가입 막기
5. Project URL과 `anon` 키를 `src/artifact-body.html` 상단에 입력
6. `./deploy.sh`

## 수정하고 배포하기

```bash
cd "/Users/hiide/Documents/정리/광서사범대/guilin-expense-site" && ./deploy.sh
```

재빌드·커밋·푸시가 한 번에 됩니다. 1~2분 뒤 사이트에 반영됩니다.

## 기능

- 구성원별 원화·위안 잔액과 투입액 대비 남은 비율 막대
- 지출 등록: 동일금액 / 총액 나누기 / 개별금액
- 금액 추가, 내역 수정·삭제, 구성원 추가·비활성화
- 이름을 누르면 개인 상세, 인원 수를 누르면 참여자별 부담액
- CSV 내려받기 (엑셀 한글 깨짐 방지 BOM 포함)
- 라이트/다크 테마 자동 대응
- **실시간 반영** — 관리자가 등록하면 열려 있는 다른 화면도 새로고침 없이 갱신

## 권한

| | 조회 | 편집 |
|---|---|---|
| 로그인 안 한 사람 | O | X |
| 관리자 계정 | O | O |

편집 권한은 **DB의 RLS 정책**이 지정된 관리자 이메일 하나만 허용하도록 막습니다.
화면의 잠금은 편의일 뿐, 실제 경계는 서버에 있습니다.

`anon` 키는 프론트엔드에 공개되도록 설계된 키라 노출되어도 무방합니다.
**`service_role` 키는 절대 이 저장소에 넣지 마세요** — RLS를 통째로 무시합니다.

## 알아두실 점

- 저장소가 public이라 **구성원 실명이 소스에 보이지는 않습니다**(데이터는 DB에 있음). 다만 사이트를 열면 누구나 장부를 볼 수 있습니다
- 무료 Supabase 프로젝트는 **일주일간 요청이 없으면 일시중지**됩니다. 대시보드에서 Restore하면 데이터 그대로 복구됩니다
- **중국 본토에서의 접속성을 미리 확인하세요.** Supabase는 AWS 기반이라 간헐적으로 느리거나 막힐 수 있습니다
- 이 버전은 Claude Artifact로는 동작하지 않습니다. Artifact 샌드박스가 외부 서버 호출을 차단하기 때문에, 이제 배포 대상은 GitHub Pages 하나입니다
