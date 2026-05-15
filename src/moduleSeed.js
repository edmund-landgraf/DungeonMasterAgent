export const modules = [
  {
    slug: "frost-in-the-vault",
    title: "Frost in the Vault",
    status: "Playable draft",
    levelRange: "Levels 1-2",
    coverImage: "/assets/covers/frost-in-the-vault.png",
    summary:
      "A Silverhall opening arc with prologue material, Act I scenes, Act II complications, pregenerated PCs, NPC sheets, handouts, and sidequests.",
    sourceRoot: "/modules/frost-in-the-vault/silverhall",
    acts: [
      {
        number: 0,
        title: "Prologue",
        summary: "Opening context and expanded prologue variants.",
        scenes: [
          {
            number: 1,
            title: "Silverhall Prologue",
            path: "/modules/frost-in-the-vault/silverhall/Modules/module-prologue.html",
            kind: "scene"
          },
          {
            number: 2,
            title: "Expanded Prologue",
            path: "/modules/frost-in-the-vault/silverhall/Modules/module-prologue-expanded.html",
            kind: "scene"
          },
          {
            number: 3,
            title: "Full Prologue",
            path: "/modules/frost-in-the-vault/silverhall/Modules/module-prologue-tripled.html",
            kind: "scene"
          }
        ]
      },
      {
        number: 1,
        title: "Dust in the Palm",
        summary: "The first Silverhall act, from the Crumbling Coin to Vault of Echoes.",
        scenes: [
          {
            number: 1,
            title: "The Crumbling Coin",
            path: "/modules/frost-in-the-vault/silverhall/Modules/a1-s1-the-crumbling-coin.html",
            kind: "scene"
          },
          {
            number: 2,
            title: "City Threads",
            path: "/modules/frost-in-the-vault/silverhall/Modules/a1-s2-city-threads.html",
            kind: "scene"
          },
          {
            number: 3,
            title: "Vault of Echoes",
            path: "/modules/frost-in-the-vault/silverhall/Modules/a1-s3-vault-of-echoes.html",
            kind: "scene"
          },
          {
            number: 4,
            title: "Warehouse Gang",
            path: "/modules/frost-in-the-vault/silverhall/Characters/stats-warehouse-gang.html",
            kind: "encounter"
          }
        ]
      },
      {
        number: 2,
        title: "Ash and Chain",
        summary: "Ambushes, contracts, sword swaps, and the delivery.",
        scenes: [
          {
            number: 2,
            title: "Ambush",
            path: "/modules/frost-in-the-vault/silverhall/Modules/a2-s2-ambush.html",
            kind: "scene"
          },
          {
            number: 3,
            title: "Breach of Contract",
            path: "/modules/frost-in-the-vault/silverhall/Modules/a2-s3-breach-of-contract.html",
            kind: "scene"
          },
          {
            number: 4,
            title: "Silver for Swords",
            path: "/modules/frost-in-the-vault/silverhall/Modules/a2-s4.1-silver-for-swords.html",
            kind: "scene"
          },
          {
            number: 5,
            title: "The Delivery",
            path: "/modules/frost-in-the-vault/silverhall/Modules/a2-s4.2-the-delivery.html",
            kind: "scene"
          }
        ]
      }
    ],
    pcs: [
      { name: "Karzak Deepstem", ancestry: "Dwarf", sheetPath: "/modules/frost-in-the-vault/silverhall/Characters/character-karzak.htm" },
      { name: "Sava of Zmeyka", ancestry: "Human", sheetPath: "/modules/frost-in-the-vault/silverhall/Characters/character-sava.htm" },
      { name: "Velra Wynne", ancestry: "Human", sheetPath: "/modules/frost-in-the-vault/silverhall/Characters/character-velra.htm" },
      { name: "Serune Quen", ancestry: "Elf", sheetPath: "/modules/frost-in-the-vault/silverhall/Characters/character-serune.htm" },
      { name: "Ilexi Tinctwhistle", ancestry: "Gnome", sheetPath: "/modules/frost-in-the-vault/silverhall/Characters/character-ilexi.htm" },
      { name: "Lazlo Oerlen", ancestry: "Human", sheetPath: "/modules/frost-in-the-vault/silverhall/Characters/character-lazlo.htm" },
      { name: "Fosk", ancestry: "Cave badger", sheetPath: "/modules/frost-in-the-vault/silverhall/Characters/character-fosk.htm" }
    ],
    npcs: [
      { name: "Warehouse Gang", role: "Act I encounter", sheetPath: "/modules/frost-in-the-vault/silverhall/Characters/stats-warehouse-gang.html" }
    ]
  },
  {
    slug: "shrouded-lineage",
    title: "Shrouded Lineage",
    status: "Cover art only",
    levelRange: "TBD",
    coverImage: "/assets/covers/shrouded-lineage.png",
    summary:
      "Module shell created from available cover art. Add acts, scenes, PCs, NPCs, handouts, and encounters as source material becomes available.",
    sourceRoot: "/modules/shrouded-lineage",
    acts: [],
    pcs: [],
    npcs: []
  }
];
