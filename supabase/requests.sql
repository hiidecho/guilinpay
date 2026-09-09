-- ============================================================
-- 광서사범대 경비 장부 — 요청/승인 기능
-- Supabase SQL Editor 에 붙여넣고 Run 하세요.
-- 기존 장부 데이터는 건드리지 않습니다. 여러 번 실행해도 안전합니다.
-- ============================================================

drop function if exists approve_request(text);
drop table if exists requests cascade;

create table requests (
  id           text primary key,
  kind         text          not null check (kind     in ('EXPENSE','ADD')),
  date         date          not null,
  title        text          not null,
  currency     text          not null check (currency in ('KRW','CNY')),
  mode         text          not null check (mode     in ('SAME','SPLIT','CUSTOM')),
  memo         text          not null default '',
  entries      jsonb         not null,          -- {"P01": 9500, "P03": 8900}
  requester    text          not null,
  status       text          not null default 'PENDING'
                             check (status in ('PENDING','APPROVED','REJECTED')),
  decided_at   timestamptz,
  created_at   timestamptz   not null default now()
);

create index requests_status_idx on requests (status, created_at desc);

-- ============================================================
-- 권한
--   · 누구나 요청을 올릴 수 있다 — 단 PENDING 으로만
--   · 누구나 요청 목록을 볼 수 있다 (진행 상황 확인용)
--   · 처리(승인/거절)와 삭제는 관리자만
-- ============================================================
alter table requests enable row level security;

create policy "누구나 요청 조회" on requests
  for select to anon, authenticated using (true);

-- with check 로 status 를 못박는다. 이게 없으면 아무나 APPROVED 로 넣을 수 있다.
create policy "누구나 요청 작성" on requests
  for insert to anon, authenticated
  with check (status = 'PENDING' and decided_at is null);

create policy "관리자만 처리" on requests
  for update to authenticated
  using      ((auth.jwt() ->> 'email') = 'admin@guilinpay.local')
  with check ((auth.jwt() ->> 'email') = 'admin@guilinpay.local');

create policy "관리자만 삭제" on requests
  for delete to authenticated
  using ((auth.jwt() ->> 'email') = 'admin@guilinpay.local');

-- ============================================================
-- 승인 — 거래 생성과 상태 변경을 한 번에 처리한다.
-- 클라이언트에서 두 번 나눠 쓰면 중간에 실패했을 때 장부가 어긋난다.
-- ============================================================
create or replace function approve_request(req_id text)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  r   requests%rowtype;
  tid text;
  k   text;
  v   text;
begin
  -- security definer 함수이므로 권한 검사를 함수 안에서 직접 한다
  if coalesce(auth.jwt() ->> 'email', '') <> 'admin@guilinpay.local' then
    raise exception '관리자만 승인할 수 있습니다';
  end if;

  select * into r from requests where id = req_id and status = 'PENDING' for update;
  if not found then
    raise exception '이미 처리되었거나 존재하지 않는 요청입니다';
  end if;

  tid := 'T' || r.id;

  insert into transactions (id, date, type, title, currency, mode, memo)
  values (tid, r.date, r.kind, r.title, r.currency, r.mode, r.memo);

  for k, v in select key, value from jsonb_each_text(r.entries) loop
    if v is not null and v <> '' and v::numeric <> 0 then
      insert into transaction_entries (transaction_id, member_id, amount)
      values (tid, k, v::numeric);
    end if;
  end loop;

  update requests set status = 'APPROVED', decided_at = now() where id = r.id;
  return tid;
end $$;

revoke execute on function approve_request(text) from public, anon;
grant  execute on function approve_request(text) to authenticated;

-- ── 실시간 반영 ──
do $$
begin
  begin alter publication supabase_realtime add table requests; exception when duplicate_object then null; end;
end $$;
