insert into modules (slug, title, status, level_range, cover_image, summary, source_root)
values
  (
    'frost-in-the-vault',
    'Frost in the Vault',
    'Playable draft',
    'Levels 1-2',
    '/assets/covers/frost-in-the-vault.png',
    'A Silverhall opening arc with prologue material, Act I scenes, Act II complications, pregenerated PCs, NPC sheets, handouts, and sidequests.',
    '/modules/frost-in-the-vault/silverhall'
  ),
  (
    'shrouded-lineage',
    'Shrouded Lineage',
    'Cover art only',
    'TBD',
    '/assets/covers/shrouded-lineage.png',
    'Module shell created from available cover art. Add acts, scenes, PCs, NPCs, handouts, and encounters as source material becomes available.',
    '/modules/shrouded-lineage'
  )
on conflict (slug) do update set
  title = excluded.title,
  status = excluded.status,
  level_range = excluded.level_range,
  cover_image = excluded.cover_image,
  summary = excluded.summary,
  source_root = excluded.source_root,
  updated_at = now();

with frost as (select id from modules where slug = 'frost-in-the-vault')
insert into acts (module_id, act_number, title, summary)
select id, 0, 'Prologue', 'Opening context and expanded prologue variants.' from frost
union all
select id, 1, 'Dust in the Palm', 'The first Silverhall act, from the Crumbling Coin to Vault of Echoes.' from frost
union all
select id, 2, 'Ash and Chain', 'Ambushes, contracts, sword swaps, and the delivery.' from frost
on conflict (module_id, act_number) do update set
  title = excluded.title,
  summary = excluded.summary;

with frost as (select id from modules where slug = 'frost-in-the-vault')
insert into player_characters (module_id, name, ancestry, sheet_path)
select id, 'Karzak Deepstem', 'Dwarf', '/modules/frost-in-the-vault/silverhall/Characters/character-karzak.htm' from frost
union all select id, 'Sava of Zmeyka', 'Human', '/modules/frost-in-the-vault/silverhall/Characters/character-sava.htm' from frost
union all select id, 'Velra Wynne', 'Human', '/modules/frost-in-the-vault/silverhall/Characters/character-velra.htm' from frost
union all select id, 'Serune Quen', 'Elf', '/modules/frost-in-the-vault/silverhall/Characters/character-serune.htm' from frost
union all select id, 'Ilexi Tinctwhistle', 'Gnome', '/modules/frost-in-the-vault/silverhall/Characters/character-ilexi.htm' from frost
union all select id, 'Lazlo Oerlen', 'Human', '/modules/frost-in-the-vault/silverhall/Characters/character-lazlo.htm' from frost
union all select id, 'Fosk', 'Cave badger', '/modules/frost-in-the-vault/silverhall/Characters/character-fosk.htm' from frost
on conflict (module_id, name) do update set
  ancestry = excluded.ancestry,
  sheet_path = excluded.sheet_path;

with frost as (select id from modules where slug = 'frost-in-the-vault')
insert into npcs (module_id, name, role, sheet_path)
select id, 'Warehouse Gang', 'Act I encounter', '/modules/frost-in-the-vault/silverhall/Characters/stats-warehouse-gang.html' from frost
on conflict (module_id, name) do update set
  role = excluded.role,
  sheet_path = excluded.sheet_path;

with target_acts as (
  select a.id, a.act_number
  from acts a
  join modules m on m.id = a.module_id
  where m.slug = 'frost-in-the-vault'
)
insert into scenes (act_id, scene_number, title, kind, html_path)
select id, 1, 'Silverhall Prologue', 'scene', '/modules/frost-in-the-vault/silverhall/Modules/module-prologue.html' from target_acts where act_number = 0
union all select id, 2, 'Expanded Prologue', 'scene', '/modules/frost-in-the-vault/silverhall/Modules/module-prologue-expanded.html' from target_acts where act_number = 0
union all select id, 3, 'Full Prologue', 'scene', '/modules/frost-in-the-vault/silverhall/Modules/module-prologue-tripled.html' from target_acts where act_number = 0
union all select id, 1, 'The Crumbling Coin', 'scene', '/modules/frost-in-the-vault/silverhall/Modules/a1-s1-the-crumbling-coin.html' from target_acts where act_number = 1
union all select id, 2, 'City Threads', 'scene', '/modules/frost-in-the-vault/silverhall/Modules/a1-s2-city-threads.html' from target_acts where act_number = 1
union all select id, 3, 'Vault of Echoes', 'scene', '/modules/frost-in-the-vault/silverhall/Modules/a1-s3-vault-of-echoes.html' from target_acts where act_number = 1
union all select id, 4, 'Warehouse Gang', 'encounter', '/modules/frost-in-the-vault/silverhall/Characters/stats-warehouse-gang.html' from target_acts where act_number = 1
union all select id, 2, 'Ambush', 'scene', '/modules/frost-in-the-vault/silverhall/Modules/a2-s2-ambush.html' from target_acts where act_number = 2
union all select id, 3, 'Breach of Contract', 'scene', '/modules/frost-in-the-vault/silverhall/Modules/a2-s3-breach-of-contract.html' from target_acts where act_number = 2
union all select id, 4, 'Silver for Swords', 'scene', '/modules/frost-in-the-vault/silverhall/Modules/a2-s4.1-silver-for-swords.html' from target_acts where act_number = 2
union all select id, 5, 'The Delivery', 'scene', '/modules/frost-in-the-vault/silverhall/Modules/a2-s4.2-the-delivery.html' from target_acts where act_number = 2
on conflict (act_id, scene_number, title) do update set
  kind = excluded.kind,
  html_path = excluded.html_path;

with frost as (select id from modules where slug = 'frost-in-the-vault')
insert into handouts (module_id, title, file_path, description)
select id, 'Ilexi Reagent Analysis', '/modules/frost-in-the-vault/silverhall/Handouts + Props/ilexi-reagent-analysis.html', 'Handout' from frost
union all select id, 'Science: Hollow Chill', '/modules/frost-in-the-vault/silverhall/Handouts + Props/science-hollow-chill-updated.html', 'Handout' from frost
on conflict (module_id, title) do update set
  file_path = excluded.file_path,
  description = excluded.description;
