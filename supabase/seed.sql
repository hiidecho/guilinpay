-- ============================================================
-- 광서사범대 경비 장부 — 최종 내역 (2026-09-09 확정)
-- Supabase SQL Editor 에 붙여넣고 Run 하세요.
-- 기존 내역을 전부 지우고 이 내용으로 다시 채웁니다.
-- 하나의 트랜잭션이라 도중에 실패하면 아무것도 바뀌지 않습니다.
-- ============================================================

begin;

delete from transaction_entries;
delete from transactions;
delete from members;

insert into members (id, name, initial_krw, initial_cny, active, sort_order) values
  ('P01', '안창은', 100000, 930, true, 0),
  ('P02', '조희대', 100000, 465, true, 1),
  ('P03', '이민성', 100000, 930, true, 2),
  ('P04', '목정훈', 100000, 930, true, 3),
  ('P05', '송기정', 100000, 465, true, 4),
  ('P06', '김지훈', 100000, 465, true, 5);

insert into transactions (id, date, type, title, currency, mode, memo) values
  ('G001', '2026-09-07', 'EXPENSE', '롯데리아', 'KRW', 'CUSTOM', ''),
  ('G002', '2026-09-07', 'EXPENSE', '노포', 'KRW', 'SAME', ''),
  ('G003', '2026-09-06', 'EXPENSE', '피자', 'CNY', 'SAME', ''),
  ('G004', '2026-09-06', 'EXPENSE', '커피', 'CNY', 'SAME', ''),
  ('G005', '2026-09-07', 'EXPENSE', '맥주·백주 저녁', 'CNY', 'SAME', '7일 저녁'),
  ('G006', '2026-09-07', 'EXPENSE', '점심', 'CNY', 'CUSTOM', '송기정 기록'),
  ('G007', '2026-09-07', 'EXPENSE', '커피', 'CNY', 'SAME', ''),
  ('G008', '2026-09-08', 'EXPENSE', '8일 점심', 'CNY', 'SAME', ''),
  ('G009', '2026-09-08', 'EXPENSE', '8일 저녁', 'CNY', 'SAME', ''),
  ('G010', '2026-09-09', 'EXPENSE', '9일 점심', 'CNY', 'CUSTOM', ''),
  ('G011', '2026-09-09', 'EXPENSE', '커피', 'CNY', 'CUSTOM', '안창은'),
  ('G012', '2026-09-05', 'EXPENSE', '햄버거+커피', 'CNY', 'CUSTOM', '김지훈');

insert into transaction_entries (transaction_id, member_id, amount) values
  ('G001', 'P01', 9500),
  ('G001', 'P02', 9500),
  ('G001', 'P03', 8900),
  ('G001', 'P04', 9500),
  ('G001', 'P05', 9500),
  ('G001', 'P06', 9500),
  ('G002', 'P01', 20600),
  ('G002', 'P03', 20600),
  ('G002', 'P04', 20600),
  ('G002', 'P05', 20600),
  ('G002', 'P06', 20600),
  ('G003', 'P01', 25),
  ('G003', 'P03', 25),
  ('G003', 'P04', 25),
  ('G003', 'P05', 25),
  ('G003', 'P06', 25),
  ('G004', 'P01', 20),
  ('G004', 'P03', 20),
  ('G004', 'P04', 20),
  ('G005', 'P01', 175),
  ('G005', 'P03', 175),
  ('G005', 'P04', 175),
  ('G005', 'P06', 175),
  ('G006', 'P05', 44),
  ('G007', 'P01', 25),
  ('G007', 'P03', 25),
  ('G007', 'P04', 25),
  ('G007', 'P05', 25),
  ('G007', 'P06', 25),
  ('G008', 'P01', 117),
  ('G008', 'P02', 117),
  ('G008', 'P03', 117),
  ('G008', 'P04', 117),
  ('G008', 'P05', 117),
  ('G008', 'P06', 117),
  ('G009', 'P03', 226),
  ('G009', 'P04', 226),
  ('G010', 'P01', 52),
  ('G010', 'P03', 51),
  ('G010', 'P04', 61),
  ('G010', 'P05', 69),
  ('G011', 'P01', 20),
  ('G012', 'P06', 52);

commit;

-- 확인용 — 실행하면 사람별 최종 잔액이 나옵니다
select m.name,
       m.initial_krw - coalesce(sum(e.amount) filter (where t.currency='KRW'), 0) as 원화잔액,
       m.initial_cny - coalesce(sum(e.amount) filter (where t.currency='CNY'), 0) as 위안잔액
from members m
left join transaction_entries e on e.member_id = m.id
left join transactions t        on t.id = e.transaction_id
group by m.id, m.name, m.initial_krw, m.initial_cny, m.sort_order
order by m.sort_order;
