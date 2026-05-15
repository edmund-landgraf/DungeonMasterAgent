# DungeonMasterAgent

Node/React module browser for Pathfinder adventure material.

## Local development

```powershell
npm install
npm run dev
```

The app opens with two modules: Frost in the Vault and Shrouded Lineage. Frost static HTML is stored under `public/modules/frost-in-the-vault/silverhall`; its HTML files now reference `css/frost_in_the_vaults.css` through relative paths.

## PostgreSQL

The project expects PostgreSQL on `localhost:5432` with database `lDungeonMasterAgent`.

```powershell
docker compose up -d postgres
npm run db:init
```

If Postgres is unavailable, the API falls back to the same seed data used by the React client.

## Linux server

Recommended production path:

```bash
~/repos/DungeonMasterAgent
```

```bash
npm ci
npm run build
cp .env.example .env
npm run db:init
npm start
```

Set `DATABASE_URL` in `.env` for the target server.

With PM2:

```bash
npm run pm2:start
pm2 save
```

The Node server serves the compiled React app from `dist/`, the API from `/api/*`, and imported static module files from the Vite public assets copied into `dist/` during build.
