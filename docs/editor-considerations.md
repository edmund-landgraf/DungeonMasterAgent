# Adventure Content Editor Considerations

Do not build the editor until the read model stabilizes. The current schema is ready for an editor or importer to target these slots:

- Module
- Act
- Scene
- Subscene
- Encounter
- Act narrative
- Scene narrative
- Subscene narrative
- Act, scene, or subscene handout
- Module bestiary entry
- Bestiary appearance tag for an act, scene, or subscene

## Upload Flow

An upload workflow should parse source content into a staging area before writing to production tables. The staging record should keep the original filename, detected content type, extracted text, proposed module target, and confidence notes.

The user should confirm placement before import:

- Adventure shell maps to `modules`.
- Major chapter headings map to `acts`.
- Numbered encounters or story beats map to `scenes`.
- Smaller beats inside a scene map to `subscenes`.
- Actual gameplay challenges map to `encounters`: combat, traps, chases, negotiations, infiltration, hazards, or skill challenges.
- Read-aloud text, GM notes, boxed text, and lore paragraphs map to narratives.
- Player-facing documents map to handouts.
- Creatures, hazards, monsters, and encounter stat references map to bestiary entries.
- Mentions of where those creatures appear map to bestiary appearance tags.

## Formatting

Narratives should support HTML and Markdown, but store the declared format in `body_format`. Sanitization should happen before rendering user-uploaded HTML. Links are acceptable. Inline game stats in parentheses are acceptable. Tactical maps should be blocked from narrative images and stored separately when tactical asset support is added.

## Future Tables

If upload history becomes important, add:

- `content_uploads`
- `content_import_batches`
- `content_import_suggestions`

Those tables should reference the final target rows only after user confirmation.

## Content Hierarchy

Use this model when placing imported content:

| Layer | Purpose | Example |
| --- | --- | --- |
| Act | Major campaign phase | Tracking the Coin Network |
| Scene | Large story segment or location | The Docks of Silverhall |
| Subscene | Distinct objective or transition | Interview the Dockworkers |
| Encounter | Actual gameplay challenge | Combat, trap, chase, or negotiation |
