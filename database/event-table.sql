create table event_group (
  id bigint generated by default as identity primary key,
  title text not null,
  description text not null
);

create table event_group_pair (
  id bigint generated by default as identity primary key,
  group_a bigint references public.event_group on delete cascade not null,
  group_b bigint references public.event_group on delete cascade not null
);

-- Make sure to not accidentally use a reserved keyword as a table name.
create table matchy_event (
  id uuid default gen_random_uuid() primary key,
  inserted_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  organizer uuid references auth.users not null,
  title text not null,
  description text not null,
  date_time timestamp with time zone not null,
  event_location text not null,
  max_participants integer not null,
  uses_groups boolean not null,
  event_groups bigint references public.event_group_pair on delete cascade not null
);

create table event_registration  (
  id bigint generated by default as identity primary key,
  event_id uuid references auth.users not null,
  user_id uuid references auth.users not null,
  inserted_at timestamp with time zone default timezone('utc'::text, now()) not null,
  in_group_a boolean not null,
  in_group_b boolean not null,
  UNIQUE (event_id, user_id)
);


create table event_round (
  id uuid default gen_random_uuid() primary key,
  inserted_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  event_id uuid references public.matchy_event not null,
  title text not null,
  start_timestamp timestamp with time zone not null,
  end_timestamp timestamp with time zone not null
  
  -- TODO: check that start_timestamp < end_timestamp
);

-- TODO: Row level security (check the docs, like https://supabase.com/docs/guides/auth/row-level-security and https://www.postgresql.org/docs/current/sql-createpolicy.html )
-- Public people can only query an event table by ID
-- Organizers can create and update events (and the related tables)

-- TODO: Make event_registration realtime

-- TODO: Maybe make event_registration unmodifyable after the event has started? But maybe people want to suddenly leave (cause they gotta go) or maybe the organzier realllly wants to add someone?

-- Note that for every date between two people, we end up with *two* rows in this table.
-- One for "Alice likes Bob" and another one for "Bob likes Alice".
create table event_user_pair (
  id bigint generated by default as identity primary key,
  inserted_at timestamp with time zone default timezone('utc'::text, now()) not null,
  event_round uuid references public.event_round not null,
  main_user uuid references auth.users not null,
  other_user uuid references auth.users not null,
  is_match boolean,
  UNIQUE (event_round, main_user, other_user)
);

-- ^ Scan QR code and insert this into the table. After the round is done, update is_match to the correct value.
-- TODO: row level security again
-- TODO: check that both users are attending the event
-- TODO: Frontend: Use the unique constraint to politely tell users "find another person, you've already tried this one"
