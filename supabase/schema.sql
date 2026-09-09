-- ============================================================
-- 구이린 공동경비 장부 — Supabase 스키마
-- Supabase 대시보드 → SQL Editor → New query 에 붙여넣고 Run
-- 여러 번 실행해도 안전합니다 (기존 표를 지우고 다시 만듭니다)
-- ============================================================

drop table if exists transaction_entries cascade;
drop table if exists transactions       cascade;
drop table if exists members            cascade;

-- ── 구성원 ──
create table members (
  id          text primary key,
  name        text          not null,
  initial_krw numeric(14,2) not null default 0,
  initial_cny numeric(14,2) not null default 0,
  active      boolean       not null default true,
  sort_order  integer       not null default 0,
  created_at  timestamptz   not null default now()
);

-- ── 거래(사용/추가) ──
create table transactions (
  id         text          primary key,
  date       date          not null,
  type       text          not null check (type     in ('EXPENSE','ADD')),
  title      text          not null,
  currency   text          not null check (currency in ('KRW','CNY')),
  mode       text          not null check (mode     in ('SAME','SPLIT','CUSTOM')),
  memo       text          not null default '',
  created_at timestamptz   not null default now(),
  updated_at timestamptz   not null default now()
);

-- ── 거래별 개인 부담액 ──
create table transaction_entries (
  transaction_id text          not null references transactions(id) on delete cascade,
  member_id      text          not null references members(id)      on delete cascade,
  amount         numeric(14,2) not null,
  primary key (transaction_id, member_id)
);

create index transactions_date_idx    on transactions (date desc);
create index entries_member_idx       on transaction_entries (member_id);

-- ── updated_at 자동 갱신 ──
create or replace function touch_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

create trigger transactions_touch
  before update on transactions
  for each row execute function touch_updated_at();

-- ============================================================
-- 권한(RLS) — 열람은 누구나, 편집은 로그인한 관리자만
-- 이 정책이 실제 보안 경계입니다. 프론트의 잠금은 편의일 뿐입니다.
-- ============================================================
alter table members             enable row level security;
alter table transactions        enable row level security;
alter table transaction_entries enable row level security;

create policy "누구나 조회"   on members             for select to anon, authenticated using (true);
create policy "누구나 조회"   on transactions        for select to anon, authenticated using (true);
create policy "누구나 조회"   on transaction_entries for select to anon, authenticated using (true);

-- 주의: "로그인한 사람 전부"로 열면 안 됩니다. Supabase는 기본적으로 누구나
-- 회원가입할 수 있으므로, 그렇게 두면 아무나 가입해서 장부를 고칠 수 있습니다.
-- 그래서 지정한 관리자 이메일 한 개만 편집할 수 있도록 못박습니다.
-- 이 주소는 프론트엔드의 ADMIN_EMAIL 값과 반드시 같아야 합니다.
create policy "관리자만 편집" on members for all to authenticated
  using      ((auth.jwt() ->> 'email') = 'admin@guilinpay.local')
  with check ((auth.jwt() ->> 'email') = 'admin@guilinpay.local');

create policy "관리자만 편집" on transactions for all to authenticated
  using      ((auth.jwt() ->> 'email') = 'admin@guilinpay.local')
  with check ((auth.jwt() ->> 'email') = 'admin@guilinpay.local');

create policy "관리자만 편집" on transaction_entries for all to authenticated
  using      ((auth.jwt() ->> 'email') = 'admin@guilinpay.local')
  with check ((auth.jwt() ->> 'email') = 'admin@guilinpay.local');

-- ============================================================
-- 실시간 반영 — 한 사람이 등록하면 열려 있는 다른 화면도 갱신
-- ============================================================
do $$
begin
  begin alter publication supabase_realtime add table members;             exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table transactions;        exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table transaction_entries; exception when duplicate_object then null; end;
end $$;
