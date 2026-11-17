-- ══════════════════════════════════════════════════════════════════════════
-- seed_products.sql
-- ثبت همه ترکیب‌های «مدل پایه × سایز» در جدول products
-- مدل‌های پایه دقیقاً همان گزینه‌های <select id="p-prod"> در فرم ثبت تولید هستند.
-- این اسکریپت idempotent است؛ چند بار اجرا شود ردیف تکراری نمی‌سازد.
-- اجرا: Supabase Dashboard → SQL Editor → این متن را paste کن و Run بزن
-- ══════════════════════════════════════════════════════════════════════════

-- ۰) ساخت جدول اگر وجود ندارد
create table if not exists products (
  id bigserial primary key,
  model text not null,
  size text default '',
  category text default 'shoes',
  created_at timestamptz default now()
);

-- ۱) حذف ردیف‌های تکراری دقیق (model + size) — نگه‌داشتن کوچک‌ترین id
delete from products a
using products b
where a.id > b.id
  and a.model = b.model
  and coalesce(a.size, '') = coalesce(b.size, '');

-- ۲) یکسان‌سازی نام قدیمی با مدل پایه
update products
   set model = 'چپلک حمام سفید دوم'
 where model = 'چپلک حمام سفید';

-- اگر بعد از تغییر نام ردیف تکراری ساخته شد، دوباره پاک شود
delete from products a
using products b
where a.id > b.id
  and a.model = b.model
  and coalesce(a.size, '') = coalesce(b.size, '');

-- ۳) سایز NULL → رشته خالی
update products set size = '' where size is null;

-- ۴) ثبت ترکیب‌ها (فقط ردیف‌هایی که وجود ندارند)
insert into products (model, size, category)
select v.model, v.size, 'shoes'
from (values
  -- بوت شیما سیاه
  ('بوت شیما سیاه',      '1-6'),
  ('بوت شیما سیاه',      '7-10'),
  ('بوت شیما سیاه',      '9-13'),
  -- بوت شیما سفید
  ('بوت شیما سفید',      '1-6'),
  ('بوت شیما سفید',      '7-10'),
  ('بوت شیما سفید',      '9-13'),
  -- بوت زنانه سیاه
  ('بوت زنانه سیاه',     '1-6'),
  ('بوت زنانه سیاه',     '7-10'),
  ('بوت زنانه سیاه',     '9-13'),
  -- بوت دخترانه (سایزهای کوچک/دخترانه)
  ('بوت دخترانه',        '1-5'),
  ('بوت دخترانه',        '5-9'),
  ('بوت دخترانه',        '7-13'),
  -- چپلک حمام اول
  ('چپلک حمام اول',      '1-6'),
  ('چپلک حمام اول',      '7-10'),
  ('چپلک حمام اول',      '9-13'),
  -- چپلک حمام دوم
  ('چپلک حمام دوم',      '1-6'),
  ('چپلک حمام دوم',      '7-10'),
  ('چپلک حمام دوم',      '9-13'),
  -- چپلک حمام سفید دوم
  ('چپلک حمام سفید دوم', '1-6'),
  ('چپلک حمام سفید دوم', '7-10'),
  ('چپلک حمام سفید دوم', '9-13'),
  -- چپلک زنانه آپردار
  ('چپلک زنانه آپردار',  '1-6'),
  ('چپلک زنانه آپردار',  '7-10'),
  ('چپلک زنانه آپردار',  '9-13'),
  -- چپلک زنانه اول
  ('چپلک زنانه اول',     '1-6'),
  ('چپلک زنانه اول',     '7-10'),
  ('چپلک زنانه اول',     '9-13'),
  -- چپلک دخترانه دوم (سایزهای کوچک/دخترانه)
  ('چپلک دخترانه دوم',   '1-5'),
  ('چپلک دخترانه دوم',   '5-9'),
  ('چپلک دخترانه دوم',   '7-13')
) as v(model, size)
where not exists (
  select 1
    from products p
   where p.model = v.model
     and coalesce(p.size, '') = v.size
);

-- ۵) بازخوانی schema cache در PostgREST
notify pgrst, 'reload schema';

-- ۶) بررسی نهایی — باید ۳۰ ردیف باشد
select model, size
  from products
 order by model, size;
