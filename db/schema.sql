create table if not exists modules (
  id bigserial primary key,
  slug text not null unique,
  title text not null,
  status text not null default 'Draft',
  level_range text,
  cover_image text,
  summary text,
  source_root text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
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

create table if not exists subscenes (
  id bigserial primary key,
  scene_id bigint not null references scenes(id) on delete cascade,
  subscene_number integer not null,
  title text not null,
  kind text not null default 'subscene',
  html_path text,
  summary text,
  gm_notes text,
  unique (scene_id, subscene_number, title)
);

create table if not exists subscene_narratives (
  id bigserial primary key,
  subscene_id bigint not null references subscenes(id) on delete cascade,
  title text not null,
  body text not null,
  body_format text not null default 'html' check (body_format in ('html', 'markdown', 'plain')),
  sort_order integer not null default 0,
  unique (subscene_id, title)
);

create table if not exists narrative_images (
  id bigserial primary key,
  act_narrative_id bigint references act_narratives(id) on delete cascade,
  scene_narrative_id bigint references scene_narratives(id) on delete cascade,
  subscene_narrative_id bigint references subscene_narratives(id) on delete cascade,
  title text not null,
  image_path text not null,
  alt_text text,
  image_kind text not null default 'illustration' check (image_kind <> 'tactical'),
  sort_order integer not null default 0,
  constraint narrative_images_single_parent check (
    num_nonnulls(act_narrative_id, scene_narrative_id, subscene_narrative_id) = 1
  )
);

alter table narrative_images add column if not exists subscene_narrative_id bigint references subscene_narratives(id) on delete cascade;

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
  check (num_nonnulls(act_narrative_id, scene_narrative_id, subscene_narrative_id) = 1);

create table if not exists player_characters (
  id bigserial primary key,
  module_id bigint not null references modules(id) on delete cascade,
  name text not null,
  ancestry text,
  class_name text,
  level integer,
  sheet_path text,
  notes text,
  unique (module_id, name)
);

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
  subscene_id bigint references subscenes(id) on delete cascade,
  label text,
  notes text,
  unique (bestiary_entry_id, act_id, scene_id, subscene_id),
  constraint bestiary_appearance_target_required check (
    num_nonnulls(act_id, scene_id, subscene_id) >= 1
  )
);

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
  unique (module_id, name)
);

create table if not exists handouts (
  id bigserial primary key,
  module_id bigint not null references modules(id) on delete cascade,
  act_id bigint references acts(id) on delete cascade,
  scene_id bigint references scenes(id) on delete cascade,
  subscene_id bigint references subscenes(id) on delete cascade,
  title text not null,
  file_path text,
  description text,
  unique (module_id, title),
  constraint handouts_target_required check (
    num_nonnulls(act_id, scene_id, subscene_id) >= 1
  )
);

alter table handouts add column if not exists act_id bigint references acts(id) on delete cascade;
alter table handouts add column if not exists scene_id bigint references scenes(id) on delete cascade;
alter table handouts add column if not exists subscene_id bigint references subscenes(id) on delete cascade;

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
  check (num_nonnulls(act_id, scene_id, subscene_id) >= 1);

create table if not exists encounters (
  id bigserial primary key,
  scene_id bigint references scenes(id) on delete set null,
  module_id bigint not null references modules(id) on delete cascade,
  title text not null,
  difficulty text,
  source_path text,
  notes text,
  unique (module_id, title)
);

create table if not exists scene_assets (
  id bigserial primary key,
  scene_id bigint not null references scenes(id) on delete cascade,
  asset_type text not null,
  title text not null,
  file_path text not null,
  unique (scene_id, file_path)
);
