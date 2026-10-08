-- ตารางรับงานใหม่ (ใช้กับแท็บ "📥 รับงานใหม่" ใน index.html)
-- รันใน Supabase → SQL Editor
create table if not exists public.new_jobs (
  id             uuid primary key default gen_random_uuid(),
  received_date  date not null,               -- วันที่รับงาน
  audit_type     text not null,               -- ประเภทการตรวจ
  name           text not null,               -- รายชื่อ
  tin            text not null,               -- เลขประจำตัวผู้เสียภาษี (13 หลัก)
  address        text,                        -- ที่อยู่
  refund_amount  numeric(15,2),               -- จำนวนเงินคืน
  team           text,                        -- ทีม (นต061–นต067)
  remark         text,                        -- หมายเหตุ
  created_by     uuid default auth.uid(),
  created_at     timestamptz not null default now(),
  constraint new_jobs_tin_13_digits check (tin ~ '^[0-9]{13}$'),
  constraint new_jobs_refund_nonneg check (refund_amount is null or refund_amount >= 0)
);

create index if not exists new_jobs_received_date_idx on public.new_jobs (received_date desc);
create index if not exists new_jobs_tin_idx on public.new_jobs (tin);

alter table public.new_jobs enable row level security;

-- ผู้ใช้ที่ล็อกอินแล้วอ่าน/เพิ่ม/แก้ไข/ลบได้ (ปรับให้ตรงกับนโยบายของตาราง tax_records)
create policy "new_jobs_select" on public.new_jobs for select to authenticated using (true);
create policy "new_jobs_insert" on public.new_jobs for insert to authenticated with check (true);
create policy "new_jobs_update" on public.new_jobs for update to authenticated using (true) with check (true);
create policy "new_jobs_delete" on public.new_jobs for delete to authenticated using (true);
