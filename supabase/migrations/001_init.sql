-- Paperly v1 initial schema
-- Tables: todos, time_blocks
-- RLS: users can only access their own rows
-- Triggers: auto-update updated_at on row update

create extension if not exists "pgcrypto";

create table todos (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid references auth.users not null,
  date        date not null,
  title       text not null,
  is_done     boolean not null default false,
  sort_order  integer not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create table time_blocks (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid references auth.users not null,
  date        date not null,
  label       text not null,
  start_time  time not null,
  end_time    time not null,
  note        text,
  color       text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index todos_user_date_idx on todos (user_id, date);
create index time_blocks_user_date_idx on time_blocks (user_id, date);

alter table todos enable row level security;
alter table time_blocks enable row level security;

create policy "Users can select their own todos"
  on todos for select
  using (user_id = auth.uid());

create policy "Users can insert their own todos"
  on todos for insert
  with check (user_id = auth.uid());

create policy "Users can update their own todos"
  on todos for update
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "Users can delete their own todos"
  on todos for delete
  using (user_id = auth.uid());

create policy "Users can select their own time blocks"
  on time_blocks for select
  using (user_id = auth.uid());

create policy "Users can insert their own time blocks"
  on time_blocks for insert
  with check (user_id = auth.uid());

create policy "Users can update their own time blocks"
  on time_blocks for update
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "Users can delete their own time blocks"
  on time_blocks for delete
  using (user_id = auth.uid());

create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger todos_set_updated_at
  before update on todos
  for each row
  execute function set_updated_at();

create trigger time_blocks_set_updated_at
  before update on time_blocks
  for each row
  execute function set_updated_at();
