import "dotenv/config";
import express from "express";
import path from "node:path";
import { fileURLToPath } from "node:url";
import pg from "pg";
import { modules as seedModules } from "../src/moduleSeed.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const app = express();
const port = process.env.PORT ?? 3000;
const databaseUrl = process.env.DATABASE_URL;
const pool = databaseUrl ? new pg.Pool({ connectionString: databaseUrl }) : null;

app.use(express.json());

app.get("/api/health", async (_req, res) => {
  if (!pool) {
    res.json({ ok: true, database: "not configured" });
    return;
  }

  try {
    await pool.query("select 1");
    res.json({ ok: true, database: "connected" });
  } catch (error) {
    res.status(503).json({ ok: false, database: "unavailable", message: error.message });
  }
});

app.get("/api/modules", async (_req, res) => {
  if (!pool) {
    res.json(seedModules);
    return;
  }

  try {
    res.json(await loadModulesFromDatabase());
  } catch (error) {
    res.json(seedModules);
  }
});

app.use(express.static(path.join(__dirname, "..", "dist")));
app.get("*splat", (_req, res) => {
  res.sendFile(path.join(__dirname, "..", "dist", "index.html"));
});

app.listen(port, () => {
  console.log(`DungeonMasterAgent listening on http://localhost:${port}`);
});

async function loadModulesFromDatabase() {
  const client = await pool.connect();
  try {
    const moduleRows = await client.query(`
      select id, slug, title, status, level_range as "levelRange",
        level_min as "levelMin", level_max as "levelMax",
        cover_image as "coverImage", summary,
        marketing_blurb_html as "marketingBlurbHtml",
        marketing_blurb_format as "marketingBlurbFormat",
        source_root as "sourceRoot"
      from modules
      order by title
    `);

    const hierarchyRows = await client.query(`
      select level_key as "levelKey", parent_level_key as "parentLevelKey", label, sort_order as "sortOrder"
      from hierarchy_levels
      order by sort_order
    `);

    const modules = [];
    for (const module of moduleRows.rows) {
      const acts = await client.query(
        `
          select id, act_number as number, title, summary
          from acts
          where module_id = $1
          order by act_number, title
        `,
        [module.id]
      );

      const pcRows = await client.query(
        `
          select id, name, ancestry, class_name as "className", sheet_path as "sheetPath",
            backstory_html_path as "backstoryHtmlPath", backstory_summary as "backstorySummary"
          from player_characters
          where module_id = $1
          order by name
        `,
        [module.id]
      );

      const pcs = [];
      for (const pc of pcRows.rows) {
        const resources = await client.query(
          `
            select title, resource_type as "resourceType", file_path as "filePath"
            from character_resources
            where player_character_id = $1
            order by resource_type, title
          `,
          [pc.id]
        );
        const { id: _pcId, ...pcPayload } = pc;
        pcs.push({ ...pcPayload, resources: resources.rows });
      }

      const npcs = await client.query(
        `
          select name, role, sheet_path as "sheetPath"
          from npcs
          where module_id = $1
          order by name
        `,
        [module.id]
      );

      const bestiaryRows = await client.query(
        `
          select id, name, creature_type as "creatureType", level_text as "levelText",
            role, stat_block_path as "statBlockPath", notes
          from bestiary_entries
          where module_id = $1
          order by name
        `,
        [module.id]
      );

      const bestiary = [];
      for (const entry of bestiaryRows.rows) {
        const appearances = await client.query(
          `
            select ba.label, ba.notes,
              a.act_number as "actNumber", a.title as "actTitle",
              s.scene_number as "sceneNumber", s.title as "sceneTitle",
              e.title as "encounterTitle",
              ee.event_number as "eventNumber", ee.title as "eventTitle"
            from bestiary_appearances ba
            left join acts a on a.id = ba.act_id
            left join scenes s on s.id = ba.scene_id
            left join encounters e on e.id = ba.encounter_id
            left join encounter_events ee on ee.id = ba.event_id
            where ba.bestiary_entry_id = $1
            order by a.act_number, s.scene_number, e.encounter_number, ee.event_number, ba.label
          `,
          [entry.id]
        );

        const { id: _bestiaryEntryId, ...entryPayload } = entry;
        bestiary.push({
          ...entryPayload,
          appearances: appearances.rows
        });
      }

      const itemRows = await client.query(
        `
          select id, name, item_type as "itemType", rarity, description,
            html_path as "htmlPath", summary, gm_notes as "gmNotes"
          from items
          where module_id = $1
          order by name
        `,
        [module.id]
      );

      const items = [];
      for (const item of itemRows.rows) {
        const appearances = await client.query(
          `
            select ia.label, ia.notes,
              a.act_number as "actNumber", a.title as "actTitle",
              s.scene_number as "sceneNumber", s.title as "sceneTitle",
              e.title as "encounterTitle",
              ee.event_number as "eventNumber", ee.title as "eventTitle"
            from item_appearances ia
            left join acts a on a.id = ia.act_id
            left join scenes s on s.id = ia.scene_id
            left join encounters e on e.id = ia.encounter_id
            left join encounter_events ee on ee.id = ia.event_id
            where ia.item_id = $1
            order by a.act_number, s.scene_number, e.encounter_number, ee.event_number, ia.label
          `,
          [item.id]
        );

        const { id: _itemId, ...itemPayload } = item;
        items.push({ ...itemPayload, appearances: appearances.rows });
      }

      const hydratedActs = [];
      for (const act of acts.rows) {
        const actNarratives = await client.query(
          `
            select title, body, body_format as "bodyFormat", sort_order as "sortOrder"
            from act_narratives
            where act_id = $1
            order by sort_order, title
          `,
          [act.id]
        );

        const actHandouts = await client.query(
          `
            select title, file_path as "filePath", description
            from handouts
            where act_id = $1 and scene_id is null
            order by title
          `,
          [act.id]
        );

        const scenes = await client.query(
          `
            select id, scene_number as number, title, kind, html_path as path, summary
            from scenes
            where act_id = $1
            order by scene_number, title
          `,
          [act.id]
        );

        const hydratedScenes = [];
        for (const scene of scenes.rows) {
          const sceneNarratives = await client.query(
            `
              select title, body, body_format as "bodyFormat", sort_order as "sortOrder"
              from scene_narratives
              where scene_id = $1
              order by sort_order, title
            `,
            [scene.id]
          );

          const sceneHandouts = await client.query(
            `
              select title, file_path as "filePath", description
              from handouts
              where scene_id = $1 and encounter_id is null and event_id is null
              order by title
            `,
            [scene.id]
          );

          const sceneEncounters = await client.query(
            `
              select id, encounter_number as number, title, encounter_type as "encounterType", difficulty,
                source_path as "sourcePath", notes
              from encounters
              where scene_id = $1
              order by encounter_number, title
            `,
            [scene.id]
          );

          const hydratedEncounters = [];
          for (const encounter of sceneEncounters.rows) {
            const events = await client.query(
              `
                select id, event_number as number, title, event_type as "eventType",
                  html_path as path, summary
                from encounter_events
                where encounter_id = $1
                order by event_number, title
              `,
              [encounter.id]
            );

            const hydratedEvents = [];
            for (const event of events.rows) {
              const eventNarratives = await client.query(
                `
                  select title, body, body_format as "bodyFormat", sort_order as "sortOrder"
                  from event_narratives
                  where event_id = $1
                  order by sort_order, title
                `,
                [event.id]
              );

              const eventHandouts = await client.query(
                `
                  select title, file_path as "filePath", description
                  from handouts
                  where event_id = $1
                  order by title
                `,
                [event.id]
              );

              const { id: _eventId, ...eventPayload } = event;
              hydratedEvents.push({
                ...eventPayload,
                narratives: eventNarratives.rows,
                handouts: eventHandouts.rows
              });
            }

            const { id: _encounterId, ...encounterPayload } = encounter;
            hydratedEncounters.push({
              ...encounterPayload,
              events: hydratedEvents
            });
          }

          const { id: _id, ...scenePayload } = scene;
          hydratedScenes.push({
            ...scenePayload,
            narratives: sceneNarratives.rows,
            handouts: sceneHandouts.rows,
            encounters: hydratedEncounters
          });
        }

        const { id: _actId, ...actPayload } = act;
        hydratedActs.push({
          ...actPayload,
          narratives: actNarratives.rows,
          handouts: actHandouts.rows,
          scenes: hydratedScenes
        });
      }

      modules.push({
        slug: module.slug,
        title: module.title,
        status: module.status,
        levelRange: module.levelRange,
        levelMin: module.levelMin,
        levelMax: module.levelMax,
        coverImage: module.coverImage,
        summary: module.summary,
        marketingBlurbHtml: module.marketingBlurbHtml,
        marketingBlurbFormat: module.marketingBlurbFormat,
        sourceRoot: module.sourceRoot,
        hierarchy: hierarchyRows.rows,
        acts: hydratedActs,
        pcs,
        npcs: npcs.rows,
        bestiary,
        items
      });
    }

    return modules;
  } finally {
    client.release();
  }
}
