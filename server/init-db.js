import "dotenv/config";
import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import pg from "pg";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const databaseUrl = process.env.DATABASE_URL ?? "postgres://postgres:postgres@localhost:5432/lDungeonMasterAgent";
const parsed = new URL(databaseUrl);
const databaseName = parsed.pathname.replace(/^\//, "") || "lDungeonMasterAgent";
const adminUrl = new URL(process.env.ADMIN_DATABASE_URL ?? databaseUrl);
adminUrl.pathname = adminUrl.pathname === "/" ? "/postgres" : adminUrl.pathname;

const admin = new pg.Client({ connectionString: adminUrl.toString() });
await admin.connect();
const exists = await admin.query("select 1 from pg_database where datname = $1", [databaseName]);
if (exists.rowCount === 0) {
  await admin.query(`create database "${databaseName.replaceAll('"', '""')}"`);
}
await admin.end();

const targetAdminUrl = new URL(adminUrl.toString());
targetAdminUrl.pathname = `/${databaseName}`;
const client = new pg.Client({ connectionString: targetAdminUrl.toString() });
await client.connect();
// Idempotent init: start from a clean public schema so seeds never conflict with old rows.
await client.query("drop schema if exists public cascade");
await client.query("create schema public");
for (const file of ["schema.sql", "seed.sql", "roles.sql"]) {
  const sql = await fs.readFile(path.join(__dirname, "..", "db", file), "utf8");
  await client.query(sql);
}
await client.end();

console.log(`Initialized PostgreSQL database ${databaseName}`);
