create table if not exists modules (
  id bigserial primary key,
  slug text not null unique,
  title text not null,
  status text not null default 'Draft',
  level_range text,
  level_min integer,
  level_max integer,
  cover_image text,
  summary text,
  marketing_blurb_html text,
  marketing_blurb_format text not null default 'html' check (marketing_blurb_format in ('html', 'markdown', 'plain')),
  source_root text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table modules add column if not exists level_min integer;
alter table modules add column if not exists level_max integer;
alter table modules add column if not exists marketing_blurb_html text;
alter table modules add column if not exists marketing_blurb_format text;

create table if not exists hierarchy_levels (
  level_key text primary key,
  parent_level_key text references hierarchy_levels(level_key),
  label text not null,
  sort_order integer not null unique
);

create table if not exists acts (
  id bigserial primary key,
  module_id bigint not null references modules(id) on delete cascade,
  act_number integer not null,
  title text not null,
  summary text,
  unique (module_id, act_number)
);

create table if not exists scenes (
  id bigserial primary key,
  act_id bigint not null references acts(id) on delete cascade,
  scene_number integer not null,
  title text not null,
  kind text not null default 'scene',
  html_path text,
  summary text,
  gm_notes text,
  unique (act_id, scene_number, title)
);

create table if not exists act_narratives (
  id bigserial primary key,
  act_id bigint not null references acts(id) on delete cascade,
  title text not null,
  body text not null,
  body_format text not null default 'html' check (body_format in ('html', 'markdown', 'plain')),
  sort_order integer not null default 0,
  unique (act_id, title)
);

create table if not exists scene_narratives (
  id bigserial primary key,
  scene_id bigint not null references scenes(id) on delete cascade,
  title text not null,
  body text not null,
  body_format text not null default 'html' check (body_format in ('html', 'markdown', 'plain')),
  sort_order integer not null default 0,
  unique (scene_id, title)
);

create table if not exists narrative_images (
  id bigserial primary key,
  act_narrative_id bigint references act_narratives(id) on delete cascade,
  scene_narrative_id bigint references scene_narratives(id) on delete cascade,
  event_narrative_id bigint,
  title text not null,
  image_path text not null,
  alt_text text,
  image_kind text not null default 'illustration' check (image_kind <> 'tactical'),
  sort_order integer not null default 0,
  constraint narrative_images_single_parent check (
    num_nonnulls(act_narrative_id, scene_narrative_id, event_narrative_id) = 1
  )
);

alter table narrative_images add column if not exists event_narrative_id bigint;

do $$
declare
  constraint_record record;
begin
  for constraint_record in
    select conname
    from pg_constraint
    where conrelid = 'narrative_images'::regclass
      and contype = 'c'
      and conname <> 'narrative_images_single_parent'
      and pg_get_constraintdef(oid) like '%act_narrative_id%'
      and pg_get_constraintdef(oid) like '%scene_narrative_id%'
  loop
    execute format('alter table narrative_images drop constraint %I', constraint_record.conname);
  end loop;
end
$$;

alter table narrative_images drop constraint if exists narrative_images_single_parent;
alter table narrative_images add constraint narrative_images_single_parent
  check (num_nonnulls(act_narrative_id, scene_narrative_id, event_narrative_id) = 1);

create table if not exists player_characters (
  id bigserial primary key,
  module_id bigint not null references modules(id) on delete cascade,
  name text not null,
  ancestry text,
  class_name text,
  level integer,
  sheet_path text,
  backstory_html_path text,
  backstory_summary text,
  notes text,
  unique (module_id, name)
);

alter table player_characters add column if not exists backstory_html_path text;
alter table player_characters add column if not exists backstory_summary text;

create table if not exists character_resources (
  id bigserial primary key,
  player_character_id bigint not null references player_characters(id) on delete cascade,
  title text not null,
  resource_type text not null default 'sheet',
  file_path text not null,
  unique (player_character_id, title)
);

create table if not exists npcs (
  id bigserial primary key,
  module_id bigint not null references modules(id) on delete cascade,
  name text not null,
  role text,
  faction text,
  sheet_path text,
  notes text,
  unique (module_id, name)
);

create table if not exists bestiary_entries (
  id bigserial primary key,
  module_id bigint not null references modules(id) on delete cascade,
  name text not null,
  creature_type text,
  level_text text,
  role text,
  stat_block_path text,
  notes text,
  unique (module_id, name)
);

create table if not exists bestiary_appearances (
  id bigserial primary key,
  bestiary_entry_id bigint not null references bestiary_entries(id) on delete cascade,
  act_id bigint references acts(id) on delete cascade,
  scene_id bigint references scenes(id) on delete cascade,
  encounter_id bigint,
  event_id bigint,
  label text,
  notes text,
  constraint bestiary_appearance_target_required check (
    num_nonnulls(act_id, scene_id, encounter_id, event_id) >= 1
  )
);

alter table bestiary_appearances add column if not exists encounter_id bigint;
alter table bestiary_appearances add column if not exists event_id bigint;

alter table bestiary_appearances drop constraint if exists bestiary_appearance_target_required;
alter table bestiary_appearances add constraint bestiary_appearance_target_required
  check (num_nonnulls(act_id, scene_id, encounter_id, event_id) >= 1);

create table if not exists locations (
  id bigserial primary key,
  module_id bigint not null references modules(id) on delete cascade,
  name text not null,
  location_type text,
  description text,
  unique (module_id, name)
);

create table if not exists items (
  id bigserial primary key,
  module_id bigint not null references modules(id) on delete cascade,
  name text not null,
  item_type text,
  rarity text,
  description text,
  html_path text,
  summary text,
  gm_notes text,
  unique (module_id, name)
);

alter table items add column if not exists html_path text;
alter table items add column if not exists summary text;
alter table items add column if not exists gm_notes text;

create table if not exists handouts (
  id bigserial primary key,
  module_id bigint not null references modules(id) on delete cascade,
  act_id bigint references acts(id) on delete cascade,
  scene_id bigint references scenes(id) on delete cascade,
  encounter_id bigint,
  event_id bigint,
  title text not null,
  file_path text,
  description text,
  unique (module_id, title),
  constraint handouts_target_required check (
    num_nonnulls(act_id, scene_id, encounter_id, event_id) >= 1
  )
);

alter table handouts add column if not exists act_id bigint references acts(id) on delete cascade;
alter table handouts add column if not exists scene_id bigint references scenes(id) on delete cascade;
alter table handouts add column if not exists encounter_id bigint;
alter table handouts add column if not exists event_id bigint;

do $$
declare
  constraint_record record;
begin
  for constraint_record in
    select conname
    from pg_constraint
    where conrelid = 'handouts'::regclass
      and contype = 'c'
      and conname <> 'handouts_target_required'
      and pg_get_constraintdef(oid) like '%act_id%'
      and pg_get_constraintdef(oid) like '%scene_id%'
  loop
    execute format('alter table handouts drop constraint %I', constraint_record.conname);
  end loop;
end
$$;

alter table handouts drop constraint if exists handouts_target_required;
alter table handouts add constraint handouts_target_required
  check (num_nonnulls(act_id, scene_id, encounter_id, event_id) >= 1);

create table if not exists encounters (
  id bigserial primary key,
  module_id bigint not null references modules(id) on delete cascade,
  scene_id bigint references scenes(id) on delete cascade,
  encounter_number integer not null default 0,
  title text not null,
  encounter_type text not null default 'challenge',
  difficulty text,
  source_path text,
  notes text,
  unique (module_id, title),
  constraint encounters_target_required check (
    scene_id is not null
  )
);

alter table encounters add column if not exists encounter_type text not null default 'challenge';
alter table encounters add column if not exists encounter_number integer not null default 0;

do $$
declare
  constraint_record record;
begin
  for constraint_record in
    select conname
    from pg_constraint
    where conrelid = 'encounters'::regclass
      and contype = 'c'
      and conname <> 'encounters_target_required'
      and pg_get_constraintdef(oid) like '%scene_id%'
  loop
    execute format('alter table encounters drop constraint %I', constraint_record.conname);
  end loop;
end
$$;

alter table encounters drop constraint if exists encounters_target_required;
alter table encounters add constraint encounters_target_required
  check (scene_id is not null);

create table if not exists encounter_events (
  id bigserial primary key,
  encounter_id bigint not null references encounters(id) on delete cascade,
  event_number integer not null,
  title text not null,
  event_type text not null default 'beat',
  html_path text,
  summary text,
  gm_notes text,
  unique (encounter_id, event_number, title)
);

create table if not exists event_narratives (
  id bigserial primary key,
  event_id bigint not null references encounter_events(id) on delete cascade,
  title text not null,
  body text not null,
  body_format text not null default 'html' check (body_format in ('html', 'markdown', 'plain')),
  sort_order integer not null default 0,
  unique (event_id, title)
);

create table if not exists item_appearances (
  id bigserial primary key,
  item_id bigint not null references items(id) on delete cascade,
  act_id bigint references acts(id) on delete cascade,
  scene_id bigint references scenes(id) on delete cascade,
  encounter_id bigint,
  event_id bigint,
  label text,
  notes text,
  constraint item_appearance_target_required check (
    num_nonnulls(act_id, scene_id, encounter_id, event_id) >= 1
  )
);

alter table item_appearances drop constraint if exists item_appearances_encounter_id_fkey;
alter table item_appearances add constraint item_appearances_encounter_id_fkey
  foreign key (encounter_id) references encounters(id) on delete cascade;

alter table item_appearances drop constraint if exists item_appearances_event_id_fkey;
alter table item_appearances add constraint item_appearances_event_id_fkey
  foreign key (event_id) references encounter_events(id) on delete cascade;

create unique index if not exists item_appearances_target_idx
  on item_appearances (item_id, act_id, scene_id, encounter_id, event_id) nulls not distinct;

alter table narrative_images drop constraint if exists narrative_images_event_narrative_id_fkey;
alter table narrative_images add constraint narrative_images_event_narrative_id_fkey
  foreign key (event_narrative_id) references event_narratives(id) on delete cascade;

alter table bestiary_appearances drop constraint if exists bestiary_appearances_encounter_id_fkey;
alter table bestiary_appearances add constraint bestiary_appearances_encounter_id_fkey
  foreign key (encounter_id) references encounters(id) on delete cascade;

alter table bestiary_appearances drop constraint if exists bestiary_appearances_event_id_fkey;
alter table bestiary_appearances add constraint bestiary_appearances_event_id_fkey
  foreign key (event_id) references encounter_events(id) on delete cascade;

alter table handouts drop constraint if exists handouts_encounter_id_fkey;
alter table handouts add constraint handouts_encounter_id_fkey
  foreign key (encounter_id) references encounters(id) on delete cascade;

alter table handouts drop constraint if exists handouts_event_id_fkey;
alter table handouts add constraint handouts_event_id_fkey
  foreign key (event_id) references encounter_events(id) on delete cascade;

create table if not exists scene_assets (
  id bigserial primary key,
  scene_id bigint not null references scenes(id) on delete cascade,
  asset_type text not null,
  title text not null,
  file_path text not null,
  unique (scene_id, file_path)
);

-- Future-facing: store publication layout specs (e.g., "pathfinder_infinite_64") without implementing export yet.
create table if not exists module_publication_specs (
  id bigserial primary key,
  module_id bigint not null references modules(id) on delete cascade,
  spec_key text not null,
  page_count integer,
  outline text,
  notes text,
  unique (module_id, spec_key)
);

alter table narrative_images drop constraint if exists narrative_images_single_parent;
alter table narrative_images drop column if exists subscene_narrative_id cascade;
alter table narrative_images add constraint narrative_images_single_parent
  check (num_nonnulls(act_narrative_id, scene_narrative_id, event_narrative_id) = 1);

alter table bestiary_appearances drop constraint if exists bestiary_appearance_target_required;
alter table bestiary_appearances drop column if exists subscene_id cascade;
alter table bestiary_appearances add constraint bestiary_appearance_target_required
  check (num_nonnulls(act_id, scene_id, encounter_id, event_id) >= 1);
alter table bestiary_appearances drop constraint if exists bestiary_appearances_bestiary_entry_id_act_id_scene_id_key;
drop index if exists bestiary_appearances_entry_act_scene_idx;

-- Deduplicate old rows so the new uniqueness can be applied cleanly.
delete from bestiary_appearances ba
using bestiary_appearances newer
where ba.ctid < newer.ctid
  and ba.bestiary_entry_id is not distinct from newer.bestiary_entry_id
  and ba.act_id is not distinct from newer.act_id
  and ba.scene_id is not distinct from newer.scene_id
  and ba.encounter_id is not distinct from newer.encounter_id
  and ba.event_id is not distinct from newer.event_id;

create unique index if not exists bestiary_appearances_target_idx
  on bestiary_appearances (bestiary_entry_id, act_id, scene_id, encounter_id, event_id) nulls not distinct;

alter table handouts drop constraint if exists handouts_target_required;
alter table handouts drop column if exists subscene_id cascade;
alter table handouts add constraint handouts_target_required
  check (num_nonnulls(act_id, scene_id, encounter_id, event_id) >= 1);

alter table encounters drop constraint if exists encounters_target_required;
alter table encounters drop column if exists subscene_id cascade;
alter table encounters add constraint encounters_target_required
  check (scene_id is not null);

drop table if exists subscene_narratives cascade;
drop table if exists subscenes cascade;
