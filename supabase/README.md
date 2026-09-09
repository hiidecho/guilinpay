# Supabase 연결 준비

이 순서대로 하면 장부가 서버에 연결됩니다. 전부 무료 플랜으로 됩니다.

---

## 1. 프로젝트 만들기

**https://supabase.com** → 로그인 → **New project**

- Name: `guilinpay` (아무거나)
- Database Password: 강한 것으로 정하고 어딘가 보관하세요. **이 비밀번호는 이 장부와 무관합니다** — 나중에 쓸 일이 거의 없습니다
- Region: **Northeast Asia (Seoul)** 또는 **(Tokyo)** — 가까울수록 빠릅니다

프로젝트가 준비되기까지 1~2분 걸립니다.

## 2. 표 만들기

좌측 **SQL Editor** → **New query** → `schema.sql` 내용을 통째로 붙여넣고 **Run**

`Success. No rows returned` 이 나오면 정상입니다.

## 3. 현재 데이터 넣기

같은 화면에서 **New query** → `seed.sql` 붙여넣고 **Run**

구성원 5명, 거래 11건, 개인부담 36행이 들어갑니다.

## 4. 관리자 계정 만들기

좌측 **Authentication** → **Users** → **Add user** → **Create new user**

- Email: `admin@guilinpay.local`
- Password: **6자 이상**으로 정하세요. 이게 앞으로 장부에서 쓸 관리자 비밀번호입니다
- **Auto Confirm User 를 켜세요** — 켜지 않으면 메일 인증이 안 돼 로그인되지 않습니다

> 이메일 주소를 바꾸고 싶으면 `schema.sql` 안의 `admin@guilinpay.local` 세 군데와
> 프론트엔드의 `ADMIN_EMAIL` 값을 **모두 같이** 바꿔야 합니다.

## 5. 아무나 가입하지 못하게 막기

좌측 **Authentication** → **Sign In / Providers** → **Email** → **Allow new users to sign up** 을 **끄세요**.

끄지 않아도 RLS 정책이 관리자 이메일 하나만 편집하도록 막고 있지만, 두 겹으로 막아두는 편이 안전합니다.

## 6. 연결 정보 복사

좌측 **Project Settings** → **API**

| 항목 | 어디에 넣나 |
|---|---|
| **Project URL** (`https://xxxx.supabase.co`) | `SUPABASE_URL` |
| **anon / public** 키 (`eyJ...` 로 시작하는 긴 문자열) | `SUPABASE_ANON_KEY` |

> **`service_role` 키는 절대 넣지 마세요.** 그 키는 RLS를 통째로 무시합니다.
> `anon` 키는 프론트엔드에 공개되도록 설계된 키라 그대로 넣어도 됩니다.

## 7. 값 채우고 배포

`src/artifact-body.html` 을 열면 파일 중간쯤 `설정` 이라고 표시된 부분이 있습니다:

```js
const SUPABASE_URL      = "";   // 여기에 Project URL
const SUPABASE_ANON_KEY = "";   // 여기에 anon public 키
const ADMIN_EMAIL       = "admin@guilinpay.local";
```

두 값을 채운 뒤:

```bash
cd "/Users/hiide/Documents/정리/광서사범대/guilin-expense-site" && ./deploy.sh
```

1~2분 뒤 https://hiidecho.github.io/guilinpay/ 에서 우측 상단 배지가
**"서버 연결됨 · 모두에게 반영"** 으로 바뀌면 완료입니다.

---

## 확인 방법

- **일반 교수** — 로그인 없이 장부와 잔액이 보입니다. 관리자 버튼을 눌러도 비밀번호를 모르면 아무것도 못 합니다
- **관리자** — 로그인 후 등록하면, 다른 사람이 열어둔 화면도 **새로고침 없이 즉시 갱신**됩니다 (실시간 구독)
- 한 기기에서 등록하고 다른 기기에서 열어 같은 숫자가 나오면 성공입니다

## 잘 안 될 때

| 증상 | 원인 |
|---|---|
| 배지가 **설정 필요** | URL/키가 비어 있거나 형식이 틀림 |
| 배지가 **서버 연결 실패** | URL 오타, 프로젝트 일시중지(무료 플랜은 오래 안 쓰면 멈춤), 네트워크 차단 |
| 로그인 시 *비밀번호가 올바르지 않습니다* | 비밀번호 오타, 또는 4번에서 만든 이메일과 `ADMIN_EMAIL` 불일치 |
| 로그인 시 *이메일 인증이 끝나지 않았습니다* | 4번에서 **Auto Confirm User** 를 켜지 않음 |
| 등록 시 *편집 권한이 없습니다* | `schema.sql` 의 관리자 이메일과 로그인 계정이 다름 |

## 알아두실 점

- **무료 플랜은 일주일간 요청이 없으면 프로젝트가 일시중지**됩니다. 대시보드에서 Restore를 누르면 즉시 복구되고 데이터는 그대로입니다
- **중국에서의 접속성은 미리 확인하세요.** Supabase는 AWS 위에서 돌아가는데, 중국 본토에서 간헐적으로 느리거나 막힐 수 있습니다. 구이린 도착 전에 현지에서 한 번 열어보시는 편이 안전합니다
