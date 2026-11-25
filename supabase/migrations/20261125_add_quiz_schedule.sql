-- Run this migration in the Supabase SQL editor before publishing scheduled quizzes.
alter table public.quizzes
  add column if not exists duration_minutes integer,
  add column if not exists available_from timestamptz,
  add column if not exists available_until timestamptz;

alter table public.quizzes
  add constraint quizzes_duration_minutes_positive
  check (duration_minutes is null or duration_minutes > 0);

alter table public.quizzes
  add constraint quizzes_availability_window_valid
  check (
    available_from is null
    or available_until is null
    or available_until > available_from
  );
