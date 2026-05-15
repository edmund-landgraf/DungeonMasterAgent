import React, { useEffect, useMemo, useState } from "react";
import { createRoot } from "react-dom/client";
import { BookOpen, Database, FileText, Shield, Users } from "lucide-react";
import { modules as seedModules } from "./moduleSeed.js";
import "./styles.css";

function App() {
  const [modules, setModules] = useState(seedModules);
  const [activeSlug, setActiveSlug] = useState(seedModules[0].slug);

  useEffect(() => {
    let isMounted = true;
    fetch("/api/modules")
      .then((response) => (response.ok ? response.json() : seedModules))
      .then((loadedModules) => {
        if (isMounted && Array.isArray(loadedModules) && loadedModules.length > 0) {
          setModules(loadedModules);
          setActiveSlug((current) =>
            loadedModules.some((module) => module.slug === current) ? current : loadedModules[0].slug
          );
        }
      })
      .catch(() => {
        if (isMounted) {
          setModules(seedModules);
        }
      });

    return () => {
      isMounted = false;
    };
  }, []);

  const activeModule = useMemo(
    () => modules.find((module) => module.slug === activeSlug) ?? modules[0],
    [activeSlug, modules]
  );

  const totals = {
    modules: modules.length,
    acts: modules.reduce((sum, module) => sum + module.acts.length, 0),
    scenes: modules.reduce(
      (sum, module) =>
        sum +
        module.acts.reduce(
          (actSum, act) =>
            actSum +
            act.scenes.reduce((sceneSum, scene) => sceneSum + 1 + (scene.subscenes?.length ?? 0), 0),
          0
        ),
      0
    ),
    characters: modules.reduce((sum, module) => sum + module.pcs.length + module.npcs.length, 0),
    bestiary: modules.reduce((sum, module) => sum + (module.bestiary?.length ?? 0), 0)
  };

  return (
    <main className="app-shell">
      <header className="topbar">
        <div>
          <p className="eyebrow">Pathfinder campaign control</p>
          <h1>DungeonMasterAgent</h1>
        </div>
        <div className="status-strip" aria-label="Project status">
          <span><BookOpen size={16} /> {totals.modules} modules</span>
          <span><FileText size={16} /> {totals.scenes} scenes</span>
          <span><Users size={16} /> {totals.characters} characters</span>
          <span><Shield size={16} /> {totals.bestiary} bestiary</span>
          <span><Database size={16} /> Postgres ready</span>
        </div>
      </header>

      <section className="module-grid" aria-label="Modules">
        {modules.map((module) => (
          <button
            type="button"
            className={`module-card ${module.slug === activeSlug ? "is-active" : ""}`}
            key={module.slug}
            onClick={() => setActiveSlug(module.slug)}
          >
            <img src={module.coverImage} alt="" />
            <span className="module-card__body">
              <span className="module-card__title">{module.title}</span>
              <span className="module-card__meta">{module.status} - {module.levelRange}</span>
            </span>
          </button>
        ))}
      </section>

      <ModuleDetail module={activeModule} />
    </main>
  );
}

function ModuleDetail({ module }) {
  return (
    <section className="detail-layout">
      <aside className="module-cover">
        <img src={module.coverImage} alt={`${module.title} cover`} />
      </aside>

      <div className="module-detail">
        <div className="detail-header">
          <div>
            <p className="eyebrow">{module.levelRange}</p>
            <h2>{module.title}</h2>
          </div>
          <a className="source-link" href={module.sourceRoot}>Open source folder</a>
        </div>

        <p className="summary">{module.summary}</p>

        <div className="content-columns">
          <section>
            <h3>Acts and Scenes</h3>
            {module.acts.length === 0 ? (
              <p className="empty-state">No structured scenes yet.</p>
            ) : (
              <div className="act-list">
                {module.acts.map((act) => (
                  <article className="act-block" key={`${module.slug}-${act.number}`}>
                    <div className="act-heading">
                      <span>Act {act.number}</span>
                      <h4>{act.title}</h4>
                      <p>{act.summary}</p>
                    </div>
                    <NarrativeList narratives={act.narratives ?? []} />
                    <HandoutList handouts={act.handouts ?? []} />
                    <div className="scene-list">
                      {act.scenes.map((scene) => (
                        <article className="scene-block" key={scene.path}>
                          <a className="scene-row" href={scene.path}>
                            <span>{scene.kind}</span>
                            <strong>{scene.title}</strong>
                          </a>
                          <NarrativeList narratives={scene.narratives ?? []} compact />
                          <HandoutList handouts={scene.handouts ?? []} compact />
                          <EncounterList encounters={scene.encounters ?? []} compact />
                          <SubsceneList subscenes={scene.subscenes ?? []} />
                        </article>
                      ))}
                    </div>
                  </article>
                ))}
              </div>
            )}
          </section>

          <section>
            <h3>Player Characters</h3>
            <Roster entries={module.pcs} emptyText="No PCs loaded yet." />

            <h3>NPCs and Encounters</h3>
            <Roster entries={module.npcs} emptyText="No NPCs loaded yet." />

            <h3>Bestiary</h3>
            <Bestiary entries={module.bestiary ?? []} />
          </section>
        </div>
      </div>
    </section>
  );
}

function Bestiary({ entries }) {
  if (entries.length === 0) {
    return <p className="empty-state">No bestiary entries loaded yet.</p>;
  }

  return (
    <div className="bestiary-list">
      {entries.map((entry) => (
        <article className="bestiary-row" key={entry.name}>
          <div className="bestiary-heading">
            <div>
              <strong>{entry.name}</strong>
              <span>{[entry.creatureType, entry.levelText].filter(Boolean).join(" - ")}</span>
            </div>
            {entry.statBlockPath ? <a href={entry.statBlockPath}>Open</a> : null}
          </div>
          {entry.role ? <p>{entry.role}</p> : null}
          <AppearanceList appearances={entry.appearances ?? []} />
        </article>
      ))}
    </div>
  );
}

function AppearanceList({ appearances }) {
  if (appearances.length === 0) {
    return null;
  }

  return (
    <div className="appearance-list">
      {appearances.map((appearance) => (
        <div
          className="appearance-row"
          key={`${appearance.label}-${appearance.actNumber}-${appearance.sceneNumber}-${appearance.subsceneNumber ?? "scene"}`}
        >
          <span>{appearance.label ?? "Appears"}</span>
          <small>{formatAppearanceTarget(appearance)}</small>
        </div>
      ))}
    </div>
  );
}

function formatAppearanceTarget(appearance) {
  const parts = [];
  if (appearance.actNumber != null) {
    parts.push(`Act ${appearance.actNumber}: ${appearance.actTitle}`);
  }
  if (appearance.sceneNumber != null) {
    parts.push(`Scene ${appearance.sceneNumber}: ${appearance.sceneTitle}`);
  }
  if (appearance.subsceneNumber != null) {
    parts.push(`Subscene ${appearance.subsceneNumber}: ${appearance.subsceneTitle}`);
  }
  return parts.join(" / ");
}

function SubsceneList({ subscenes }) {
  if (subscenes.length === 0) {
    return null;
  }

  return (
    <div className="subscene-list">
      {subscenes.map((subscene) => (
        <article className="subscene-block" key={`${subscene.number}-${subscene.title}`}>
          <div className="subscene-heading">
            <span>{subscene.kind}</span>
            {subscene.path ? (
              <a href={subscene.path}>{subscene.title}</a>
            ) : (
              <strong>{subscene.title}</strong>
            )}
            {subscene.summary ? <p>{subscene.summary}</p> : null}
          </div>
          <NarrativeList narratives={subscene.narratives ?? []} compact />
          <HandoutList handouts={subscene.handouts ?? []} compact />
          <EncounterList encounters={subscene.encounters ?? []} compact />
        </article>
      ))}
    </div>
  );
}

function EncounterList({ encounters, compact = false }) {
  if (encounters.length === 0) {
    return null;
  }

  return (
    <div className={`encounter-list ${compact ? "is-compact" : ""}`}>
      {encounters.map((encounter) => (
        <article className="encounter-row" key={encounter.title}>
          <div>
            <span>{encounter.encounterType}</span>
            <strong>{encounter.title}</strong>
            {encounter.difficulty ? <small>{encounter.difficulty}</small> : null}
          </div>
          {encounter.sourcePath ? <a href={encounter.sourcePath}>Open</a> : null}
        </article>
      ))}
    </div>
  );
}

function NarrativeList({ narratives, compact = false }) {
  if (narratives.length === 0) {
    return null;
  }

  return (
    <div className={`narrative-list ${compact ? "is-compact" : ""}`}>
      {narratives.map((narrative) => (
        <section className="narrative-block" key={narrative.title}>
          <h5>{narrative.title}</h5>
          <RichText body={narrative.body} format={narrative.bodyFormat} />
        </section>
      ))}
    </div>
  );
}

function RichText({ body, format }) {
  if (format === "html") {
    return <div className="rich-text" dangerouslySetInnerHTML={{ __html: body }} />;
  }

  return <div className="rich-text is-plain">{body}</div>;
}

function HandoutList({ handouts, compact = false }) {
  if (handouts.length === 0) {
    return null;
  }

  return (
    <div className={`handout-list ${compact ? "is-compact" : ""}`}>
      {handouts.map((handout) => (
        <a className="handout-row" href={handout.filePath} key={handout.title}>
          <FileText size={15} />
          <span>
            <strong>{handout.title}</strong>
            <small>{handout.description}</small>
          </span>
        </a>
      ))}
    </div>
  );
}

function Roster({ entries, emptyText }) {
  if (entries.length === 0) {
    return <p className="empty-state">{emptyText}</p>;
  }

  return (
    <div className="roster-list">
      {entries.map((entry) => (
        <div className="roster-row" key={entry.name}>
          <a href={entry.sheetPath}>
            <strong>{entry.name}</strong>
            <span>{entry.ancestry ?? entry.role}</span>
          </a>
          {entry.resources?.length > 0 ? (
            <div className="resource-list">
              {entry.resources.map((resource) => (
                <a href={resource.filePath} key={resource.title}>{resource.title}</a>
              ))}
            </div>
          ) : null}
        </div>
      ))}
    </div>
  );
}

createRoot(document.getElementById("root")).render(<App />);
