insert into modules (slug, title, status, level_range, level_min, level_max, cover_image, summary, marketing_blurb_html, marketing_blurb_format, source_root)
values
  (
    'frost-in-the-vault',
    'Frost in the Vault',
    'Playable draft',
    'Levels 1-2',
    1,
    2,
    '/assets/covers/frost-in-the-vault.png',
    'A Silverhall opening arc with prologue material, Act I scenes, Act II complications, pregenerated PCs, NPC sheets, handouts, and sidequests.',
    '<p><strong>Gold should not crumble.</strong> When a sealed temple coin collapses into dust in Silverhall, a House Lebeda intermediary convenes a quiet meeting, demonstrates the failure firsthand, and arms the party with a reagent that changes color when applied to tainted ore or gems. The first task is to follow the bad money upstream and identify who introduced the corruption. The second is to meet with alchemists and secure scarce ingredients so the reagent can be produced at scale.</p><p><strong>Campaign Path (Levels 1-12+)</strong></p><table><thead><tr><th>#</th><th>Location</th><th>Levels</th><th>Chapter Title</th></tr></thead><tbody><tr><td>1</td><td>Silverhall</td><td>1-2</td><td>The Tarnished Coin</td></tr><tr><td>2</td><td>Zmeyka</td><td>2-4</td><td>Whispers in the Flow</td></tr><tr><td>3</td><td>Grayhaven</td><td>4-6</td><td>A Fortress Under Strain</td></tr><tr><td>4</td><td>Highdelve</td><td>6-8</td><td>Ashes in the Vein</td></tr><tr><td>5</td><td>Port Ice</td><td>8-10</td><td>Heart of the Chill</td></tr><tr><td>6</td><td>Grayhaven (Finale)</td><td>10-12+</td><td>The Siege of Grayhaven</td></tr></tbody></table><p><strong>Core Plot Element: The Tainted Alloy</strong> An ancient cold-born agent introduced at the point of forging causes metals and gemstones to become brittle and disintegrate after months. The decay accelerates in warm climates, masking the attack until it spreads. The goal is economic destabilization: ruin Orlovsky confidence, collapse military pay, and soften the region for a final political strike.</p>',
    'html',
    '/modules/frost-in-the-vault/silverhall'
  ),
  (
    'shrouded-lineage',
    'Shrouded Lineage',
    'Cover art only',
    'TBD',
    null,
    null,
    '/assets/covers/shrouded-lineage.png',
    'Module shell created from available cover art. Add acts, scenes, PCs, NPCs, handouts, and encounters as source material becomes available.',
    '<p><strong>Shrouded Lineage</strong> is a Pathfinder Roleplaying Game Adventure for Levels 1-12. Along the storm-lashed coast of Cheliax, heirs vanish without warning. A discreet kidnapping case spirals into a conspiracy of bloodlines, vengeance, and forbidden resurrection lore that drags the heroes from Corentyn to pirate waters and the shattered Azlant Frontier.</p>',
    'html',
    '/modules/shrouded-lineage'
  )
on conflict (slug) do update set
  title = excluded.title,
  status = excluded.status,
  level_range = excluded.level_range,
  level_min = excluded.level_min,
  level_max = excluded.level_max,
  cover_image = excluded.cover_image,
  summary = excluded.summary,
  marketing_blurb_html = excluded.marketing_blurb_html,
  marketing_blurb_format = excluded.marketing_blurb_format,
  source_root = excluded.source_root,
  updated_at = now();

insert into hierarchy_levels (level_key, parent_level_key, label, sort_order)
values
  ('act', null, 'Act', 10),
  ('scene', 'act', 'Scene', 20),
  ('encounter', 'scene', 'Encounter', 30),
  ('event', 'encounter', 'Event/Beat', 40)
on conflict (level_key) do update set
  parent_level_key = excluded.parent_level_key,
  label = excluded.label,
  sort_order = excluded.sort_order;

with frost as (select id from modules where slug = 'frost-in-the-vault')
insert into module_publication_specs (module_id, spec_key, page_count, outline, notes)
select
  id,
  'pathfinder_infinite_64',
  64,
  'Front Matter (4 pages)\n1 Cover Page\n2 Credits & Legal\n3 Table of Contents\n4 Introduction & How to Use\n\nChapter 1: Prologue & Background (4 pages)\n5-6 Prologue: Cracks in the Coin\n7 The Hollow Chill\n8 Key Factions & Nobles\n\nChapter 2: The Six Summoned (8 pages)\n9-10 Using Pre-Gens or Custom PCs\n11-16 Character Profiles\n17-18 Optional Mythic Hooks\n\nChapter 3: Silverhall Rising (32 pages)\n19-20 Adventure Summary\n21-45 Acts I-V + Climactic Encounter\n46-48 Rewards & Fallout\n\nChapter 4: Supplemental Content (10 pages)\n49-51 New Magic Items\n52-53 New Rules Subsystem\n54-56 NPCs & Factions\n57-58 GM Tips\n\nChapter 5: Player Appendix (8 pages)\n59-60 Handouts / Letters\n61 Map\n62 Faction/Plot Map\n63 Downtime Hooks\n64 Next Module Ad',
  'Stored for future PDF/export tooling; not implemented yet.'
from frost
on conflict (module_id, spec_key) do update set
  page_count = excluded.page_count,
  outline = excluded.outline,
  notes = excluded.notes;

with frost as (select id from modules where slug = 'frost-in-the-vault')
insert into acts (module_id, act_number, title, summary)
select id, 0, 'Prologue', 'Opening context and expanded prologue variants.' from frost
union all
select id, 1, 'Dust in the Palm', 'The first Silverhall act, from the Crumbling Coin to Vault of Echoes.' from frost
union all
select id, 2, 'Ash and Chain', 'Ambushes, contracts, sword swaps, and the delivery.' from frost
union all
select id, 3, 'Companion Sidequests', 'Character-focused sidequests, rewards, backstories, relics, and personal props.' from frost
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

update player_characters pc
set
  backstory_html_path = '/modules/frost-in-the-vault/silverhall/Sidequests/Serune/serune-backstory.htm',
  backstory_summary = 'Serune''s personal history and motivations tied to the Hollow Chill arc.'
from modules m
where m.id = pc.module_id
  and m.slug = 'frost-in-the-vault'
  and pc.name = 'Serune Quen';

with pc_targets as (
  select pc.id, pc.name
  from player_characters pc
  join modules m on m.id = pc.module_id
  where m.slug = 'frost-in-the-vault'
)
insert into character_resources (player_character_id, title, resource_type, file_path)
select id, 'Mythic Sheet', 'mythic-sheet', '/modules/frost-in-the-vault/silverhall/Characters/mythic/character-karzak_mythic.htm' from pc_targets where name = 'Karzak Deepstem'
union all select id, 'Mythic Sheet', 'mythic-sheet', '/modules/frost-in-the-vault/silverhall/Characters/mythic/character-sava_mythic.htm' from pc_targets where name = 'Sava of Zmeyka'
union all select id, 'Mythic Sheet', 'mythic-sheet', '/modules/frost-in-the-vault/silverhall/Characters/mythic/character-velra_mythic.htm' from pc_targets where name = 'Velra Wynne'
union all select id, 'Mythic Sheet', 'mythic-sheet', '/modules/frost-in-the-vault/silverhall/Characters/mythic/character-serune_mythic.htm' from pc_targets where name = 'Serune Quen'
union all select id, 'Mythic Sheet', 'mythic-sheet', '/modules/frost-in-the-vault/silverhall/Characters/mythic/character-ilexi_mythic.htm' from pc_targets where name = 'Ilexi Tinctwhistle'
union all select id, 'Mythic Sheet', 'mythic-sheet', '/modules/frost-in-the-vault/silverhall/Characters/mythic/character-lazlo_mythic.htm' from pc_targets where name = 'Lazlo Oerlen'
union all select id, 'Alternate Sheet', 'sheet', '/modules/frost-in-the-vault/silverhall/Characters/character-lazlo2.htm' from pc_targets where name = 'Lazlo Oerlen'
union all select id, 'Mythic Sheet', 'mythic-sheet', '/modules/frost-in-the-vault/silverhall/Characters/mythic/character-fosk_mythic.htm' from pc_targets where name = 'Fosk'
on conflict (player_character_id, title) do update set
  resource_type = excluded.resource_type,
  file_path = excluded.file_path;

with frost as (select id from modules where slug = 'frost-in-the-vault')
insert into npcs (module_id, name, role, sheet_path)
select id, 'Roomstompers Raunch', 'Act I encounter', '/modules/frost-in-the-vault/silverhall/Characters/stats-warehouse-gang.html' from frost
on conflict (module_id, name) do update set
  role = excluded.role,
  sheet_path = excluded.sheet_path;

with frost as (select id from modules where slug = 'frost-in-the-vault')
insert into bestiary_entries (module_id, name, creature_type, level_text, role, stat_block_path, notes)
select id, 'Roomstompers Raunch', 'Humanoid', 'Level 1 encounter', 'Hired killers', '/modules/frost-in-the-vault/silverhall/Characters/stats-warehouse-gang.html', 'A local mercenary gang hired to silence the party before they learn too much about the crumbling coin.' from frost
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

with frost as (select id from modules where slug = 'frost-in-the-vault')
insert into items (module_id, name, item_type, rarity, description, html_path, summary, gm_notes)
select id, 'Black Shard Relics', 'magic item', 'Uncommon', 'Recovered relics tied to Serune''s sidequest.', '/modules/frost-in-the-vault/silverhall/Sidequests/Serune/black-shard-relics-serune.htm', 'Relics and item notes for Serune''s arc.', null from frost
on conflict (module_id, name) do update set
  item_type = excluded.item_type,
  rarity = excluded.rarity,
  description = excluded.description,
  html_path = excluded.html_path,
  summary = excluded.summary,
  gm_notes = excluded.gm_notes;

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
union all select id, 4, 'Opening Scene', 'scene', '/modules/frost-in-the-vault/silverhall/Adventure Text/opening_css.htm' from target_acts where act_number = 0
union all select id, 0, 'Act I Overview', 'scene', '/modules/frost-in-the-vault/silverhall/Modules/module-act1-dust-in-the-palm.html' from target_acts where act_number = 1
union all select id, 1, 'The Crumbling Coin', 'scene', '/modules/frost-in-the-vault/silverhall/Modules/a1-s1-the-crumbling-coin.html' from target_acts where act_number = 1
union all select id, 2, 'City Threads', 'scene', '/modules/frost-in-the-vault/silverhall/Modules/a1-s2-city-threads.html' from target_acts where act_number = 1
union all select id, 3, 'Vault of Echoes', 'scene', '/modules/frost-in-the-vault/silverhall/Modules/a1-s3-vault-of-echoes.html' from target_acts where act_number = 1
union all select id, 4, 'Roomstompers Raunch', 'scene', '/modules/frost-in-the-vault/silverhall/Characters/stats-warehouse-gang.html' from target_acts where act_number = 1
union all select id, 2, 'Ambush', 'scene', '/modules/frost-in-the-vault/silverhall/Modules/a2-s2-ambush.html' from target_acts where act_number = 2
union all select id, 3, 'Breach of Contract', 'scene', '/modules/frost-in-the-vault/silverhall/Modules/a2-s3-breach-of-contract.html' from target_acts where act_number = 2
union all select id, 4, 'Silver for Swords', 'scene', '/modules/frost-in-the-vault/silverhall/Modules/a2-s4.1-silver-for-swords.html' from target_acts where act_number = 2
union all select id, 5, 'The Delivery', 'scene', '/modules/frost-in-the-vault/silverhall/Modules/a2-s4.2-the-delivery.html' from target_acts where act_number = 2
union all select id, 1, 'Sava: Snarehouse', 'sidequest', '/modules/frost-in-the-vault/silverhall/Sidequests/Sava/encounter-snarehouse.htm' from target_acts where act_number = 3
union all select id, 2, 'Karzak and Fosk: The Buried Heart', 'sidequest', '/modules/frost-in-the-vault/silverhall/Sidequests/Karzan/sidequest-fosk-buried-heart.html' from target_acts where act_number = 3
union all select id, 3, 'Serune: Graves of the Hollow', 'sidequest', '/modules/frost-in-the-vault/silverhall/Sidequests/Serune/sidequest-serune-part1.htm' from target_acts where act_number = 3
union all select id, 4, 'Velra: Ledger of Ash', 'sidequest', '/modules/frost-in-the-vault/silverhall/Sidequests/velra/velra-sidequest-LedgerOfAsh.htm' from target_acts where act_number = 3
union all select id, 5, 'Ilexi: Fragments of the Machine', 'sidequest', '/modules/frost-in-the-vault/silverhall/Sidequests/ilexi/ilexi-sidequest.htm' from target_acts where act_number = 3
union all select id, 6, 'Lazlo: The Ice Below', 'sidequest', '/modules/frost-in-the-vault/silverhall/Sidequests/lazlo/lazlo-sidequest-part1.htm' from target_acts where act_number = 3
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
  select bestiary_entry_id, act_id, scene_id, 'Act I encounter' as label, 'Appears as the warehouse opposition.' as notes
  from beast_targets
  where act_id in (select id from acts where act_number = 1)
    and scene_id in (select id from scenes where scene_number = 4)
    and bestiary_entry_id in (select id from bestiary_entries where name = 'Roomstompers Raunch')
  union all
  select bestiary_entry_id, act_id, scene_id, 'Vault clue', 'Referenced as an environmental threat in vault science material.'
  from beast_targets
  where act_id in (select id from acts where act_number = 1)
    and scene_id in (select id from scenes where scene_number = 3)
    and bestiary_entry_id in (select id from bestiary_entries where name = 'Hollow Chill')
  union all
  select bestiary_entry_id, act_id, scene_id, 'Hollow Chill bestiary', 'Imported from hollowchill.html.'
  from beast_targets
  where act_id in (select id from acts where act_number = 1)
    and scene_id in (select id from scenes where scene_number = 3)
    and bestiary_entry_id in (
      select id from bestiary_entries
      where name in ('Coldheart Injector', 'Brinebound Laborer', 'Hollowborn Stalker', 'Oreweaver Shade', 'Lurask the Foldbound')
    )
  union all
  select bestiary_entry_id, act_id, scene_id, 'Warehouse defense', 'Imported from hollowchill.html.'
  from beast_targets
  where act_id in (select id from acts where act_number = 1)
    and scene_id in (select id from scenes where scene_number = 4)
    and bestiary_entry_id in (select id from bestiary_entries where name = 'Warehouse Defense Traps')
)
insert into bestiary_appearances (bestiary_entry_id, act_id, scene_id, encounter_id, event_id, label, notes)
select bestiary_entry_id, act_id, scene_id, null::bigint as encounter_id, null::bigint as event_id, label, notes from appearances
on conflict (bestiary_entry_id, act_id, scene_id, encounter_id, event_id) do update set
  label = excluded.label,
  notes = excluded.notes;

with frost as (select id from modules where slug = 'frost-in-the-vault'),
scene_targets as (
  select s.id, a.act_number, s.scene_number
  from scenes s
  join acts a on a.id = s.act_id
  join modules m on m.id = a.module_id
  where m.slug = 'frost-in-the-vault'
)
insert into encounters (module_id, scene_id, encounter_number, title, encounter_type, difficulty, source_path, notes)
select frost.id, scene_targets.id, 1, 'Roomstompers Raunch', 'combat', 'Level 1 encounter', '/modules/frost-in-the-vault/silverhall/Characters/stats-warehouse-gang.html', 'A local mercenary gang hired to take out the party so they stop asking questions about the crumbling coin.' from frost, scene_targets where act_number = 1 and scene_number = 4
union all
select frost.id, scene_targets.id, 1, 'Vault of Echoes: Hollow Chill Clue', 'hazard', 'TBD', '/modules/frost-in-the-vault/silverhall/Handouts + Props/science-hollow-chill-updated.html', 'Environmental threat or investigation challenge.' from frost, scene_targets where act_number = 1 and scene_number = 3
union all
select frost.id, scene_targets.id, 1, 'Ambush', 'combat', 'TBD', '/modules/frost-in-the-vault/silverhall/Modules/a2-s2-ambush.html', 'Street ambush challenge.' from frost, scene_targets where act_number = 2 and scene_number = 2
union all
select frost.id, scene_targets.id, 1, 'Breach of Contract', 'infiltration', 'TBD', '/modules/frost-in-the-vault/silverhall/Modules/a2-s3-breach-of-contract.html', 'Vault infiltration challenge.' from frost, scene_targets where act_number = 2 and scene_number = 3
union all
select frost.id, scene_targets.id, 1, 'Silver for Swords', 'negotiation', 'TBD', '/modules/frost-in-the-vault/silverhall/Modules/a2-s4.1-silver-for-swords.html', 'Merchant swap challenge.' from frost, scene_targets where act_number = 2 and scene_number = 4
union all
select frost.id, scene_targets.id, 1, 'The Delivery', 'negotiation', 'TBD', '/modules/frost-in-the-vault/silverhall/Modules/a2-s4.2-the-delivery.html', 'Coin-for-loyalty challenge.' from frost, scene_targets where act_number = 2 and scene_number = 5
union all
select frost.id, scene_targets.id, 1, 'Sava: Snarehouse', 'combat', 'TBD', '/modules/frost-in-the-vault/silverhall/Sidequests/Sava/encounter-snarehouse.htm', 'Sava sidequest encounter.' from frost, scene_targets where act_number = 3 and scene_number = 1
union all
select frost.id, scene_targets.id, 2, 'Warehouse Defense Traps', 'trap', 'CR 3-4', '/modules/frost-in-the-vault/silverhall/Stat Blocks/Enemies - Bestiary/hollowchill.html', 'Trap challenge from the Hollow Chill bestiary.' from frost, scene_targets where act_number = 3 and scene_number = 1
union all
select frost.id, scene_targets.id, 1, 'Serune: Graves of the Hollow', 'exploration', 'TBD', '/modules/frost-in-the-vault/silverhall/Sidequests/Serune/sidequest-serune-part1.htm', 'Serune sidequest challenge.' from frost, scene_targets where act_number = 3 and scene_number = 3
union all
select frost.id, scene_targets.id, 1, 'Velra: Ledger of Ash', 'investigation', 'TBD', '/modules/frost-in-the-vault/silverhall/Sidequests/velra/velra-sidequest-LedgerOfAsh.htm', 'Velra sidequest challenge.' from frost, scene_targets where act_number = 3 and scene_number = 4
union all
select frost.id, scene_targets.id, 1, 'Ilexi: Fragments of the Machine', 'investigation', 'TBD', '/modules/frost-in-the-vault/silverhall/Sidequests/ilexi/ilexi-sidequest.htm', 'Ilexi sidequest challenge.' from frost, scene_targets where act_number = 3 and scene_number = 5
union all
select frost.id, scene_targets.id, 1, 'Lazlo: The Ice Below', 'exploration', 'TBD', '/modules/frost-in-the-vault/silverhall/Sidequests/lazlo/lazlo-sidequest-part1.htm', 'Lazlo sidequest challenge.' from frost, scene_targets where act_number = 3 and scene_number = 6
on conflict (module_id, title) do update set
  scene_id = excluded.scene_id,
  encounter_number = excluded.encounter_number,
  encounter_type = excluded.encounter_type,
  difficulty = excluded.difficulty,
  source_path = excluded.source_path,
  notes = excluded.notes;

with target_item as (
  select i.id as item_id
  from items i
  join modules m on m.id = i.module_id
  where m.slug = 'frost-in-the-vault'
    and i.name = 'Black Shard Relics'
),
target_scene as (
  select s.id as scene_id, a.id as act_id
  from scenes s
  join acts a on a.id = s.act_id
  join modules m on m.id = a.module_id
  where m.slug = 'frost-in-the-vault'
    and a.act_number = 3
    and s.scene_number = 3
),
target_encounter as (
  select e.id as encounter_id
  from encounters e
  join modules m on m.id = e.module_id
  where m.slug = 'frost-in-the-vault'
    and e.title = 'Serune: Graves of the Hollow'
)
insert into item_appearances (item_id, act_id, scene_id, encounter_id, event_id, label, notes)
select item_id, act_id, scene_id, encounter_id, null::bigint, 'Serune sidequest', 'Item appears during the Graves of the Hollow sidequest.'
from target_item, target_scene, target_encounter
on conflict (item_id, act_id, scene_id, encounter_id, event_id) do update set
  label = excluded.label,
  notes = excluded.notes;

with encounter_targets as (
  select e.id, e.title
  from encounters e
  join modules m on m.id = e.module_id
  where m.slug = 'frost-in-the-vault'
)
insert into encounter_events (encounter_id, event_number, title, event_type, html_path, summary)
select id, 1, 'Approach Through the Weather', 'beat', null, 'A short setup beat before the ambush becomes visible.' from encounter_targets where title = 'Ambush'
union all
select id, 2, 'The First Strike', 'beat', null, 'The ambush resolves into action or a tense social standoff.' from encounter_targets where title = 'Ambush'
union all
select id, 1, 'Counting the Blades', 'beat', null, 'The party reads the merchant swap before deciding whether to interfere.' from encounter_targets where title = 'Silver for Swords'
union all
select id, 1, 'Sava Reward', 'reward', '/modules/frost-in-the-vault/silverhall/Sidequests/Sava/encounter-sava-reward.htm', 'Reward beat for Sava.' from encounter_targets where title = 'Sava: Snarehouse'
union all
select id, 2, 'Sava Reward Variant', 'reward', '/modules/frost-in-the-vault/silverhall/Sidequests/Sava/encounter-sava-reward2.htm', 'Expanded reward beat for Sava.' from encounter_targets where title = 'Sava: Snarehouse'
union all
select id, 1, 'Black Shard Relics', 'prop', '/modules/frost-in-the-vault/silverhall/Sidequests/Serune/black-shard-relics-serune.htm', 'Serune relic reference.' from encounter_targets where title = 'Serune: Graves of the Hollow'
union all
select id, 2, 'Serune Backstory', 'backstory', '/modules/frost-in-the-vault/silverhall/Sidequests/Serune/serune-backstory.htm', 'Serune backstory reference.' from encounter_targets where title = 'Serune: Graves of the Hollow'
union all
select id, 3, 'Tomb of Glass', 'beat', '/modules/frost-in-the-vault/silverhall/Sidequests/Serune/sidequest-serune-part2.htm', 'Second Serune sidequest beat.' from encounter_targets where title = 'Serune: Graves of the Hollow'
union all
select id, 4, 'Tomb of Glass Narrative', 'beat', '/modules/frost-in-the-vault/silverhall/Sidequests/Serune/sidequest-serune-part2_narrative.htm', 'Narrative version of the Tomb of Glass beat.' from encounter_targets where title = 'Serune: Graves of the Hollow'
union all
select id, 1, 'Chain of Reversal', 'beat', '/modules/frost-in-the-vault/silverhall/Sidequests/velra/velra-sidequest-ChainOfReversal.htm', 'Velra follow-up sidequest.' from encounter_targets where title = 'Velra: Ledger of Ash'
union all
select id, 2, 'Velra Coin Prop', 'prop', '/modules/frost-in-the-vault/silverhall/Sidequests/velra/velra-coins.htm', 'Velra coin reference.' from encounter_targets where title = 'Velra: Ledger of Ash'
union all
select id, 1, 'Fragments Narrative I', 'beat', '/modules/frost-in-the-vault/silverhall/Sidequests/ilexi/ilexi-narrative_1.htm', 'Ilexi narrative beat.' from encounter_targets where title = 'Ilexi: Fragments of the Machine'
union all
select id, 2, 'Stelladex Observation', 'beat', '/modules/frost-in-the-vault/silverhall/Sidequests/ilexi/ilexi-narrative_2.htm', 'Ilexi narrative beat.' from encounter_targets where title = 'Ilexi: Fragments of the Machine'
union all
select id, 3, 'Tinctwhistle Goggles', 'prop', '/modules/frost-in-the-vault/silverhall/Sidequests/ilexi/ilexi-goggle.htm', 'Ilexi item reference.' from encounter_targets where title = 'Ilexi: Fragments of the Machine'
union all
select id, 1, 'Vault of the Pale Ledger', 'beat', '/modules/frost-in-the-vault/silverhall/Sidequests/lazlo/lazlo-sidequest-part2.htm', 'Second Lazlo sidequest beat.' from encounter_targets where title = 'Lazlo: The Ice Below'
union all
select id, 2, 'Frozen Heart Set', 'prop', '/modules/frost-in-the-vault/silverhall/Sidequests/lazlo/lazlo-frozen-heart-set.htm', 'Lazlo item reference.' from encounter_targets where title = 'Lazlo: The Ice Below'
union all
select id, 3, 'Vault of the Pale Ledger Finale', 'beat', '/modules/frost-in-the-vault/silverhall/Sidequests/lazlo/lazlo-sidequest-part3.htm', 'Third Lazlo sidequest beat.' from encounter_targets where title = 'Lazlo: The Ice Below'
on conflict (encounter_id, event_number, title) do update set
  event_type = excluded.event_type,
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

with target_events as (
  select ee.id, e.title as encounter_title, ee.title as event_title
  from encounter_events ee
  join encounters e on e.id = ee.encounter_id
  join modules m on m.id = e.module_id
  where m.slug = 'frost-in-the-vault'
)
insert into event_narratives (event_id, title, body, body_format, sort_order)
select id, 'Weather Read', '<p>Sleet turns the street lamps into dull halos. Wagon tracks vanish quickly here, but one set of prints keeps its shape a little too cleanly.</p>', 'html', 10 from target_events where encounter_title = 'Ambush' and event_title = 'Approach Through the Weather'
union all
select id, 'Action Beat', '<p>The first attacker moves when the cart wheel snaps. It is staged, loud, and meant to make bystanders look away.</p>', 'html', 10 from target_events where encounter_title = 'Ambush' and event_title = 'The First Strike'
union all
select id, 'Tradecraft', '<p>Every sword in the crate is wrapped twice except one. That one has the careful indifference of a planted object.</p>', 'html', 10 from target_events where encounter_title = 'Silver for Swords' and event_title = 'Counting the Blades'
on conflict (event_id, title) do update set
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
  file_path = excluded.file_path,
  description = excluded.description;
