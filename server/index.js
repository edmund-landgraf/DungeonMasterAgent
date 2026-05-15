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

      const pcs = await client.query(
        `
          select name, ancestry, class_name as className, sheet_path as "sheetPath"
          from player_characters
          where module_id = $1
          order by name
        `,
        [module.id]
      );

      const npcs = await client.query(
        `
          select name, role, sheet_path as "sheetPath"
          from npcs
          where module_id = $1
          order by name
        `,
        [module.id]
      );

      const hydratedActs = [];
      for (const act of acts.rows) {
        const scenes = await client.query(
          `
            select scene_number as number, title, kind, html_path as path, summary
            from scenes
            where act_id = $1
            order by scene_number, title
          `,
          [act.id]
        );
        hydratedActs.push({ ...act, scenes: scenes.rows });
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
        pcs: pcs.rows,
        npcs: npcs.rows
      });
    }

    return modules;
  } finally {
    client.release();
  }
}
