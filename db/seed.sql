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

with frost as (select id from modules where slug = 'frost-in-the-vault')
insert into bestiary_entries (module_id, name, creature_type, level_text, role, stat_block_path, notes)
select id, 'Warehouse Gang', 'Humanoid', 'Level 1 encounter', 'Street-level opposition', '/modules/frost-in-the-vault/silverhall/Characters/stats-warehouse-gang.html', 'Use as the Act I pressure encounter.' from frost
union all
select id, 'Hollow Chill', 'Hazard or creature', 'TBD', 'Environmental threat', '/modules/frost-in-the-vault/silverhall/Stat Blocks/Enemies - Bestiary/hollowchill.html', 'Bestiary collection for Hollow Chill entities.' from frost
union all
select id, 'Coldheart Injector', 'Medium Construct', 'CR 2', 'Hollow Chill entity', '/modules/frost-in-the-vault/silverhall/Stat Blocks/Enemies - Bestiary/hollowchill.html', 'Imported from Hollow Chill bestiary.' from frost
union all
select id, 'Brinebound Laborer', 'Medium Undead', 'CR 1', 'Hollow Chill entity', '/modules/frost-in-the-vault/silverhall/Stat Blocks/Enemies - Bestiary/hollowchill.html', 'Imported from Hollow Chill bestiary.' from frost
union all
select id, 'Hollowborn Stalker', 'Medium Fey (Cold)', 'CR 3', 'Hollow Chill entity', '/modules/frost-in-the-vault/silverhall/Stat Blocks/Enemies - Bestiary/hollowchill.html', 'Imported from Hollow Chill bestiary.' from frost
union all
select id, 'Oreweaver Shade', 'Medium Outsider (Cold, Extraplanar)', 'CR 4', 'Hollow Chill entity', '/modules/frost-in-the-vault/silverhall/Stat Blocks/Enemies - Bestiary/hollowchill.html', 'Imported from Hollow Chill bestiary.' from frost
union all
select id, 'Lurask the Foldbound', 'Medium Aberration', 'CR 5', 'Hollow Chill entity', '/modules/frost-in-the-vault/silverhall/Stat Blocks/Enemies - Bestiary/hollowchill.html', 'Imported from Hollow Chill bestiary.' from frost
union all
select id, 'Warehouse Defense Traps', 'Magical Traps', 'CR 3-4', 'Warehouse defense', '/modules/frost-in-the-vault/silverhall/Stat Blocks/Enemies - Bestiary/hollowchill.html', 'Imported from Hollow Chill bestiary.' from frost
on conflict (module_id, name) do update set
  creature_type = excluded.creature_type,
  level_text = excluded.level_text,
  role = excluded.role,
  stat_block_path = excluded.stat_block_path,
  notes = excluded.notes;

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

with beast_targets as (
  select be.id as bestiary_entry_id, a.id as act_id, s.id as scene_id
  from bestiary_entries be
  join modules m on m.id = be.module_id
  join acts a on a.module_id = m.id
  join scenes s on s.act_id = a.id
  where m.slug = 'frost-in-the-vault'
),
appearances as (
  select bestiary_entry_id, act_id, scene_id, null::bigint as subscene_id, 'Act I encounter' as label, 'Appears as the warehouse opposition.' as notes
  from beast_targets
  where act_id in (select id from acts where act_number = 1)
    and scene_id in (select id from scenes where scene_number = 4)
    and bestiary_entry_id in (select id from bestiary_entries where name = 'Warehouse Gang')
  union all
  select bestiary_entry_id, act_id, scene_id, null::bigint, 'Vault clue', 'Referenced as an environmental threat in vault science material.'
  from beast_targets
  where act_id in (select id from acts where act_number = 1)
    and scene_id in (select id from scenes where scene_number = 3)
    and bestiary_entry_id in (select id from bestiary_entries where name = 'Hollow Chill')
  union all
  select bestiary_entry_id, act_id, scene_id, null::bigint, 'Hollow Chill bestiary', 'Imported from hollowchill.html.'
  from beast_targets
  where act_id in (select id from acts where act_number = 1)
    and scene_id in (select id from scenes where scene_number = 3)
    and bestiary_entry_id in (
      select id from bestiary_entries
      where name in ('Coldheart Injector', 'Brinebound Laborer', 'Hollowborn Stalker', 'Oreweaver Shade', 'Lurask the Foldbound')
    )
  union all
  select bestiary_entry_id, act_id, scene_id, null::bigint, 'Warehouse defense', 'Imported from hollowchill.html.'
  from beast_targets
  where act_id in (select id from acts where act_number = 1)
    and scene_id in (select id from scenes where scene_number = 4)
    and bestiary_entry_id in (select id from bestiary_entries where name = 'Warehouse Defense Traps')
)
insert into bestiary_appearances (bestiary_entry_id, act_id, scene_id, subscene_id, label, notes)
select bestiary_entry_id, act_id, scene_id, subscene_id, label, notes from appearances
on conflict (bestiary_entry_id, act_id, scene_id, subscene_id) do update set
  label = excluded.label,
  notes = excluded.notes;

with target_scenes as (
  select s.id, a.act_number, s.scene_number
  from scenes s
  join acts a on a.id = s.act_id
  join modules m on m.id = a.module_id
  where m.slug = 'frost-in-the-vault'
)
insert into subscenes (scene_id, subscene_number, title, kind, html_path, summary)
select id, 1, 'Approach Through the Weather', 'subscene', null, 'A short setup beat before the ambush becomes visible.' from target_scenes where act_number = 2 and scene_number = 2
union all
select id, 2, 'The First Strike', 'subscene', null, 'The ambush resolves into action or a tense social standoff.' from target_scenes where act_number = 2 and scene_number = 2
union all
select id, 1, 'Counting the Blades', 'subscene', null, 'The party reads the merchant swap before deciding whether to interfere.' from target_scenes where act_number = 2 and scene_number = 4
on conflict (scene_id, subscene_number, title) do update set
  kind = excluded.kind,
  html_path = excluded.html_path,
  summary = excluded.summary;

with target_acts as (
  select a.id, a.act_number
  from acts a
  join modules m on m.id = a.module_id
  where m.slug = 'frost-in-the-vault'
)
insert into act_narratives (act_id, title, body, body_format, sort_order)
select id, 'Act Frame', '<p>Silverhall opens under hard weather, anxious coin, and contracts that feel colder than law. Use this narrative as the act-level spine before drilling into individual scenes.</p><p><strong>GM beat:</strong> keep pressure social first, then let the vault threat surface in clues and debts.</p>', 'html', 10 from target_acts where act_number = 1
union all
select id, 'Act Frame', '<p>Act II turns bargains into consequences. The party should feel watched, useful, and increasingly expensive to ignore.</p><p><em>Escalation:</em> reveal rival claims, missing goods, and favors that carry teeth (Diplomacy DC by table level).</p>', 'html', 10 from target_acts where act_number = 2
on conflict (act_id, title) do update set
  body = excluded.body,
  body_format = excluded.body_format,
  sort_order = excluded.sort_order;

with target_scenes as (
  select s.id, a.act_number, s.scene_number, s.title
  from scenes s
  join acts a on a.id = s.act_id
  join modules m on m.id = a.module_id
  where m.slug = 'frost-in-the-vault'
)
insert into scene_narratives (scene_id, title, body, body_format, sort_order)
select id, 'Read-Aloud Opening', '<p>The Crumbling Coin smells of wet wool, brass polish, and old smoke. Outside, sleet needles the shutters. Inside, every quiet conversation stops just long enough to measure who came through the door.</p>', 'html', 10 from target_scenes where act_number = 1 and scene_number = 1
union all
select id, 'GM Context', '<p>City Threads is a connective scene. Let the party choose which lead feels personal, then attach one concrete cost to delay (lost time, public suspicion, or a favor owed).</p>', 'html', 10 from target_scenes where act_number = 1 and scene_number = 2
union all
select id, 'Vault Tone', '<p>The vault is not silent. It ticks, exhales, and answers footsteps with tiny sounds from somewhere behind the stone. Treat environmental details as clues, not decoration.</p>', 'html', 10 from target_scenes where act_number = 1 and scene_number = 3
union all
select id, 'Ambush Setup', '<p>The ambush should begin as a bad feeling before initiative. Give the players one honest sign: a mismatched footprint, a cart parked too squarely, or a window shutting at the wrong moment.</p>', 'html', 10 from target_scenes where act_number = 2 and scene_number = 2
on conflict (scene_id, title) do update set
  body = excluded.body,
  body_format = excluded.body_format,
  sort_order = excluded.sort_order;

with target_subscenes as (
  select ss.id, a.act_number, s.scene_number, ss.subscene_number
  from subscenes ss
  join scenes s on s.id = ss.scene_id
  join acts a on a.id = s.act_id
  join modules m on m.id = a.module_id
  where m.slug = 'frost-in-the-vault'
)
insert into subscene_narratives (subscene_id, title, body, body_format, sort_order)
select id, 'Weather Read', '<p>Sleet turns the street lamps into dull halos. Wagon tracks vanish quickly here, but one set of prints keeps its shape a little too cleanly.</p>', 'html', 10 from target_subscenes where act_number = 2 and scene_number = 2 and subscene_number = 1
union all
select id, 'Action Beat', '<p>The first attacker moves when the cart wheel snaps. It is staged, loud, and meant to make bystanders look away.</p>', 'html', 10 from target_subscenes where act_number = 2 and scene_number = 2 and subscene_number = 2
union all
select id, 'Tradecraft', '<p>Every sword in the crate is wrapped twice except one. That one has the careful indifference of a planted object.</p>', 'html', 10 from target_subscenes where act_number = 2 and scene_number = 4 and subscene_number = 1
on conflict (subscene_id, title) do update set
  body = excluded.body,
  body_format = excluded.body_format,
  sort_order = excluded.sort_order;

with frost as (select id from modules where slug = 'frost-in-the-vault'),
target_scenes as (
  select s.id, a.act_number, s.scene_number
  from scenes s
  join acts a on a.id = s.act_id
  join modules m on m.id = a.module_id
  where m.slug = 'frost-in-the-vault'
)
insert into handouts (module_id, act_id, scene_id, title, file_path, description)
select frost.id, null::bigint, target_scenes.id, 'Ilexi Reagent Analysis', '/modules/frost-in-the-vault/silverhall/Handouts + Props/ilexi-reagent-analysis.html', 'Scene handout' from frost, target_scenes where act_number = 1 and scene_number = 2
union all
select frost.id, null::bigint, target_scenes.id, 'Science: Hollow Chill', '/modules/frost-in-the-vault/silverhall/Handouts + Props/science-hollow-chill-updated.html', 'Scene handout' from frost, target_scenes where act_number = 1 and scene_number = 3
on conflict (module_id, title) do update set
  act_id = excluded.act_id,
  scene_id = excluded.scene_id,
  subscene_id = excluded.subscene_id,
  file_path = excluded.file_path,
  description = excluded.description;
