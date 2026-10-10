-- Run this entire script in Supabase Dashboard > SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  role text not null default 'customer' check (role in ('customer','admin')),
  created_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public
as $$ begin
  insert into public.profiles (id, email, role)
  values (new.id, new.email, 'customer')
  on conflict (id) do update set email = excluded.email;
  return new;
end; $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

create or replace function public.is_rofs_admin()
returns boolean language sql stable security definer set search_path = public
as $$ select exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'); $$;

create table if not exists public.orders (
  order_id text primary key,
  customer_id uuid not null references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  status text not null default 'Pending' check (status in ('Pending','Processing','Completed','Cancelled')),
  type text not null default 'Service Order',
  total numeric(12,2) not null default 0,
  customer_name text not null default '',
  contact text not null default '',
  created_at timestamptz not null default now()
);
create index if not exists orders_customer_id_idx on public.orders(customer_id);
create index if not exists orders_created_at_idx on public.orders(created_at desc);

alter table public.profiles enable row level security;
alter table public.orders enable row level security;

drop policy if exists "Read own profile or admin" on public.profiles;
create policy "Read own profile or admin" on public.profiles for select to authenticated
using (id = auth.uid() or public.is_rofs_admin());
-- No client-side insert/update policy on profiles: customers cannot promote themselves to admin.

drop policy if exists "Customers read own orders and admins read all" on public.orders;
create policy "Customers read own orders and admins read all" on public.orders for select to authenticated
using (customer_id = auth.uid() or public.is_rofs_admin());
drop policy if exists "Customers create own orders" on public.orders;
create policy "Customers create own orders" on public.orders for insert to authenticated
with check (customer_id = auth.uid() and status = 'Pending');
drop policy if exists "Admins update orders" on public.orders;
create policy "Admins update orders" on public.orders for update to authenticated
using (public.is_rofs_admin()) with check (public.is_rofs_admin());
drop policy if exists "Admins delete orders" on public.orders;
create policy "Admins delete orders" on public.orders for delete to authenticated
using (public.is_rofs_admin());

-- After registering your own account, replace the email below with that exact account email and run:
-- update public.profiles set role = 'admin' where email = 'you@example.com';
-- Then use admin-login.html. Do not give admin role to ordinary customer accounts.
