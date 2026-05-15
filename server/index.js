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
        cover_image as "coverImage", summary, source_root as "sourceRoot"
      from modules
      order by title
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
          select id, name, ancestry, class_name as "className", sheet_path as "sheetPath"
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
              ss.subscene_number as "subsceneNumber", ss.title as "subsceneTitle"
            from bestiary_appearances ba
            left join acts a on a.id = ba.act_id
            left join scenes s on s.id = ba.scene_id
            left join subscenes ss on ss.id = ba.subscene_id
            where ba.bestiary_entry_id = $1
            order by a.act_number, s.scene_number, ss.subscene_number, ba.label
          `,
          [entry.id]
        );

        const { id: _bestiaryEntryId, ...entryPayload } = entry;
        bestiary.push({
          ...entryPayload,
          appearances: appearances.rows
        });
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
              where scene_id = $1 and subscene_id is null
              order by title
            `,
            [scene.id]
          );

          const sceneEncounters = await client.query(
            `
              select title, encounter_type as "encounterType", difficulty,
                source_path as "sourcePath", notes
              from encounters
              where scene_id = $1 and subscene_id is null
              order by title
            `,
            [scene.id]
          );

          const subscenes = await client.query(
            `
              select id, subscene_number as number, title, kind, html_path as path, summary
              from subscenes
              where scene_id = $1
              order by subscene_number, title
            `,
            [scene.id]
          );

          const hydratedSubscenes = [];
          for (const subscene of subscenes.rows) {
            const subsceneNarratives = await client.query(
              `
                select title, body, body_format as "bodyFormat", sort_order as "sortOrder"
                from subscene_narratives
                where subscene_id = $1
                order by sort_order, title
              `,
              [subscene.id]
            );

            const subsceneHandouts = await client.query(
              `
                select title, file_path as "filePath", description
                from handouts
                where subscene_id = $1
                order by title
              `,
              [subscene.id]
            );

            const subsceneEncounters = await client.query(
              `
                select title, encounter_type as "encounterType", difficulty,
                  source_path as "sourcePath", notes
                from encounters
                where subscene_id = $1
                order by title
              `,
              [subscene.id]
            );

            const { id: _subsceneId, ...subscenePayload } = subscene;
            hydratedSubscenes.push({
              ...subscenePayload,
              narratives: subsceneNarratives.rows,
              handouts: subsceneHandouts.rows,
              encounters: subsceneEncounters.rows
            });
          }

          const { id: _id, ...scenePayload } = scene;
          hydratedScenes.push({
            ...scenePayload,
            narratives: sceneNarratives.rows,
            handouts: sceneHandouts.rows,
            encounters: sceneEncounters.rows,
            subscenes: hydratedSubscenes
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
        coverImage: module.coverImage,
        summary: module.summary,
        sourceRoot: module.sourceRoot,
        acts: hydratedActs,
        pcs,
        npcs: npcs.rows,
        bestiary
      });
    }

    return modules;
  } finally {
    client.release();
  }
}
