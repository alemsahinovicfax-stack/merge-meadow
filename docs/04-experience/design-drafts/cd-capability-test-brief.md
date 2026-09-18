---
type: meta
status: aktivan
milestone: "—"
tags: [claude-design, test, pipeline, 3d, performanse, komunikacija]
povezano:
  - merge-arena-cd-brief
  - art-direction
  - design-pillars
  - ui-i-art-alati
  - cd-capability-test-izvjestaj
  - cd_response
ai_sažetak: "Test kapaciteta Claude Designa — 6 raznovrsnih zadataka (3D/glTF, .tscn, animacija, nova mehanika + detalj, performanse, protokol komunikacije CD↔Claude Code) s obaveznim iskrenim izvještajem i instalacijskim paketom kao fallback. Paket stigao i provjeren 2026-09-16."
---

# Claude Design — test kapaciteta

> Roditelj: [[04-experience/_index|04-experience]] · povezano: [[merge-arena-cd-brief]], [[ui-i-art-alati]]
> **Rezultat (2026-09-16):** paket provjeren i izmjeren → [[cd-capability-test-izvjestaj|izvještaj]] · [[cd_response|odgovor za CD]]

**Ovo je sandbox test, ne feature.** Ništa iz ovog paketa ne ulazi u igru bez scope provjere (`scope-i-granice.md`, M8). 3D je ovdje test sposobnosti — [[art-direction]] i dalje kaže flat 2D.

## Postupak

1. U CD projekat priloži: `docs/01-vision/design-pillars.md`, `docs/02-design/core-loop.md`, `docs/04-experience/art-direction.md`, `docs/04-experience/design-drafts/merge-arena-cd-brief.md`, `game/scripts/visual/ui_palette.gd`, `game/scripts/visual/ui_arena.gd` i 1–2 screenshota Arene/Campa.
2. Zalijepi prompt ispod.
3. Kad CD završi: skini paket (zip ili pojedinačne fajlove) i attachaj ga Claude Codeu u chatu uz rečenicu "CD test paket".
4. Claude Code: pročita `HANDOFF.json` + `REPORT.md`, **pregleda instalacijsku skriptu prije pokretanja**, raspakuje u `game/_cd_sandbox/`, pokrene headless provjere i odgovori u `RESPONSE.md` formatu koji je CD definisao.

---

## Prompt (copy-paste u Claude Design)

```text
Zdravo! Radim mobilnu igru "Merge Meadow" (Godot 4.7, portrait 1080×1920, renderer gl_compatibility / OpenGL ES 3, Android-first, slabiji uređaji). U prilogu su design pillars, core loop, art direction, brief za Merge Arenu i paleta boja iz koda. Već smo zajedno radili hub chrome, Camp i Merge Arenu — ti si isporučivao .dc.html + paste-ready .gd fajlove.

Ovaj put NE radimo redizajn. Želim da ISPITAM TVOJE MOGUĆNOSTI kroz 6 raznovrsnih zadataka. Tvoj rad nakon tebe preuzima Claude Code (AI agent koji ima pristup mom repou, može pokretati Godot headless, čitati/pisati fajlove i pokretati skripte). Vi ne možete direktno razgovarati — ja prenosim fajlove između vas. Dio testa je upravo to: kako ćete komunicirati.

PRAVILO BR. 1 — ISKRENOST PRIJE IMPRESIVNOSTI
Za svaki zadatak jasno označi:
  ✅ URAĐENO — stvarno si generisao i (ako možeš) provjerio fajl
  ⚠️ DJELIMIČNO — šta radi, šta ne, šta nisi mogao provjeriti
  ❌ NE MOGU — objasni zašto i predloži najbolju zamjenu
Ne izmišljaj da je fajl validan ako ga nisi mogao provjeriti. Neuspjeh uz tačno objašnjenje vrijedi više od fajla koji izgleda ispravno a ne radi. Ako pretpostavljaš nešto o Godotu/Blenderu, napiši "PRETPOSTAVKA:".

═══════════════════════════════════════
ZADATAK 0 — Inventar alata (prije svega ostalog, kratko)
═══════════════════════════════════════
Prije rada napiši: koje alate/izlaze stvarno imaš (izvršavanje koda? generisanje binarnih fajlova? PNG export? zip? 3D preview u canvasu, npr. three.js?). Za svaki zadatak ispod unaprijed predvidi ✅/⚠️/❌. Na kraju uporedi predviđanje sa stvarnim ishodom.

═══════════════════════════════════════
ZADATAK 1 — 3D koncept + export (Blender / Godot)
═══════════════════════════════════════
Napravi jednostavan low-poly 3D model: "Seed Bag" (vreća sjemenki iz Arene) ILI "T3 kristalni cvijet" — ti biraš, obrazloži.
Tehnički zahtjevi:
- ≤ 800 trokuta, Y-up, 1 unit = 1 m, visina ~0.3 m, origin na dnu u centru
- boje iz ui_palette.gd / ui_arena.gd kao vertex colors ILI 1–3 jednostavna materijala (bez tekstura)
- Isporuči BAR JEDAN od ovih formata (više = bolje, rangiraj po pouzdanosti):
  a) .gltf (JSON, buffer embedded kao base64) — primarni za Godot 4
  b) .obj + .mtl — za Blender
  c) Blender Python skripta (bpy) koja proceduralno gradi model i exporta .glb
  d) Godot skripta (.gd) koja gradi mesh kroz SurfaceTool/ArrayMesh
- 3D preview u canvasu ako možeš (turntable), plus 3 ortho pogleda (front/side/top) kao koncept.
- Bonus: kako bi se ovaj model koristio u 2D igri (pre-render u sprite sheet? 8 uglova?) i da li to ima smisla za nas.
Claude Code će glTF uvesti u Godot headless i prijaviti greške.

═══════════════════════════════════════
ZADATAK 2 — Godot-native fajl (.tscn)
═══════════════════════════════════════
Napiši paste-ready Godot 4 scenu u tekstualnom .tscn formatu: mali "MergeToast" Control (npr. "+1 ✦ Crystal" koji iskoči iznad polja nakon T2+T2→T3), s pripadajućim .gd skriptom koja ima jednu funkciju `play(text: String, at: Vector2)` i Tween animaciju (scale pop + fade + lagani float gore, ukupno ≤ 0.9 s).
- Statičko tipiranje, snake_case, @onready tipovi moraju odgovarati tipovima nodeova u sceni.
- Bez vanjskih fontova/tekstura (ili fallback ako nema).
- Ne generiši uid= / ExtResource id-eve koje ne možeš garantovati — ako nisi siguran u format, reci i predloži da Claude Code generiše scenu iz tvog spec-a.
Claude Code će scenu učitati headless i javiti rezultat.

═══════════════════════════════════════
ZADATAK 3 — Animacija / "feel" spec
═══════════════════════════════════════
Za trenutak T2+T2→T3 (kristal napušta polje i leti u garden stash) napravi:
- storyboard (6–8 frejmova) u canvasu
- timing tabelu: faza, trajanje (ms), easing (Godot Tween.TransitionType/EaseType imena), šta se skalira/pomjera/blijedi
- sprite sheet ≤ 8 frejmova ako možeš izvesti PNG (512×512 po frejmu max); ako ne možeš, SVG frejmovi
- haptic + audio cue prijedlog (kratko, 1 red)
Ovo mora biti izvedivo bez shadera.

═══════════════════════════════════════
ZADATAK 4 — Tvoja ideja: 1 mala mehanika + 1 mali detalj
═══════════════════════════════════════
Na osnovu core loopa i pillara SAM osmisli:
A) JEDNU malu mehaniku koja poboljšava igru (npr. u Areni, Campu ili između runova). Ograničenja:
   - Pillar 2 (Fair F2P) je nepregovarljiv: bez novih valuta, energije, paywalla, FOMO tajmera, panike
   - ne mijenja fiksna pravila Arene iz briefa (30 chipova, magnet 182 px, snap 140 px, ≥4 za izbacivanje…)
   - implementabilno za solo deva za ≤ 2 dana
B) JEDAN mikro detalj (≤ 1 sat rada) koji daje šarm/juice — nešto što igrač primijeti tek treći put.
Format za oboje:
   Naziv · Problem igrača koji rješava · Pravila (brojevi!) · Kako se uklapa u pillare (1–3) · Rizici / kako može pokvariti igru · Effort (S/M/L) · Kako prototipirati za 1 dan · 1 mockup artboard
Na kraju: iskrena samokritika — koja je najslabija tačka tvoje ideje?

═══════════════════════════════════════
ZADATAK 5 — Performanse: da li dizajn "šteka"?
═══════════════════════════════════════
Kontekst: u Areni istovremeno može biti do 30 chipova (rim + well + cvijet), pulsiranje svih istih, magnet, vacuum let nazad u vreću, "clear" bljesak, toast, header/footer chrome. Ciljni uređaj: slabiji Android, OpenGL ES 3, 60 fps (minimum 30).
Tvoj dio (dizajnerska strana):
1. Procijeni vlastiti prethodni Arena dizajn: koji 3 elementa su vjerovatno najskuplji za render (overdraw providnih slojeva, veliki radiusi/sjene u StyleBoxFlat, broj istovremenih tweenova, veličine tekstura…). PRETPOSTAVKA vs znanje — označi.
2. Predloži "performance budget" tabelu: max istovremenih animiranih elemenata, max čestica po efektu, max veličina teksture/atlasa, broj providnih slojeva po chipu, šta ide u atlas.
3. Dizajniraj "Low FX" varijantu (automatski fallback kad FPS padne): šta se isključuje, šta se pojednostavljuje, a igra i dalje izgleda cozy. 1 artboard poređenja Full vs Low FX.
4. Napiši spec za STRESS TEST koji će Claude Code implementirati i izmjeriti: scenariji (npr. 30 chipova + svi pulsiraju + 12 vacuum letova + clear u istom frejmu), šta se mjeri (FPS min/avg, frame time p95, draw calls, broj nodeova), prag za pass/fail.
   Ako možeš, napiši i GDScript skicu za taj benchmark — Claude Code će je popraviti i pokrenuti na emulatoru.
Podjela posla je bitna: TI predlažeš budžet i degradacije, CLAUDE CODE mjeri stvarne brojke i vraća ti ih. Napiši šta ti treba natrag od njega da bi revidirao dizajn.

═══════════════════════════════════════
ZADATAK 6 — Protokol komunikacije CD ↔ Claude Code (osmisli sam)
═══════════════════════════════════════
Vi ne dijelite chat. Ja sam kurir. Osmisli najbolji način komunikacije koji možeš ISPORUČITI, ne samo opisati. Minimum:
1. HANDOFF.json (mašinski čitljiv manifest):
   - protocol_version, datum, lista zadataka {id, status ✅/⚠️/❌, confidence 0–1}
   - za svaki fajl: {path_u_paketu, predložena_putanja_u_repou, tip, kako_provjeriti}
   - verification_steps: konkretne komande/koraci koje Claude Code treba izvršiti
   - questions_for_claude_code: lista pitanja s id-om (npr. Q-01), na koja očekuješ odgovor
   - known_limitations
2. REPORT.md — ljudski čitljiv izvještaj (za mene): tabela zadataka, predviđeno vs stvarno, šta te iznenadilo.
3. RESPONSE_TEMPLATE.md — tačan format u kojem Claude Code treba odgovoriti (rezultati provjera po fajlu, odgovori na Q-xx, izmjerene performanse, zahtjevi za reviziju), tako da ja taj odgovor mogu samo prenijeti tebi i da ti odmah nastaviš iteraciju.
Ako smisliš bolji kanal od ovoga (npr. nešto što ja ne moram ručno prepisivati), predloži ga i objasni ograničenja.

FALLBACK — instalacijski paket:
Ako možeš, spakuj sve u "cd_capability_test.zip" s instalacijskom skriptom `install.ps1` (Windows PowerShell 5.1). Pravila za skriptu:
- podrazumijevano radi DRY-RUN (samo ispiše šta bi uradio); stvarno kopiranje tek s `-Apply`
- kopira ISKLJUČIVO u `game/_cd_sandbox/` i `docs/_cd_sandbox/` — nikad ne prepisuje postojeće fajlove
- bez brisanja, bez mreže, bez pokretanja drugih programa, bez izmjene sistemskih postavki
- na kraju ispiše listu kopiranih fajlova
Claude Code će skriptu pročitati prije nego je pokrene. Ako ne možeš napraviti zip, isporuči fajlove pojedinačno s istom strukturom foldera navedenom u HANDOFF.json.

═══════════════════════════════════════
ISPORUKA — struktura paketa
═══════════════════════════════════════
cd_capability_test/
  HANDOFF.json
  REPORT.md
  RESPONSE_TEMPLATE.md
  install.ps1                (ako možeš)
  t1_3d/                     (.gltf / .obj+.mtl / bpy .py / .gd mesh builder, preview)
  t2_tscn/                   (merge_toast.tscn, merge_toast.gd)
  t3_anim/                   (storyboard, timing, sprite sheet ili SVG frejmovi)
  t4_concept/                (mehanika.md, detalj.md, mockupi)
  t5_perf/                   (budget.md, low_fx artboard, stress_test_spec.md, benchmark .gd skica)
  canvas/                    (.dc.html artboardi)

Redoslijed rada: 0 → 6 (napravi kostur protokola prvo, da sve ostalo odmah upisuješ u HANDOFF.json) → 1 → 2 → 3 → 4 → 5.
Ako ti ponestane prostora/vremena, reci gdje si stao i šta je ostalo — ne skraćuj tiho.
```

---

## Za Claude Code — šta provjeriti kad paket stigne

| Zadatak | Provjera |
|---------|----------|
| T1 3D | `.gltf` u `game/_cd_sandbox/`, `godot-import.ps1`, headless `load()` + broj trokuta; `.obj` samo vizuelno (Blender nije instaliran na HP laptopu); bpy skriptu pročitati, ne pokretati bez Blendera |
| T2 .tscn | headless instanciranje, poziv `play()`, provjera `@onready` tipova |
| T3 anim | timing tabela → isprobati kao Tween u sandbox sceni |
| T4 koncept | scope guard (M8 OUT lista) + Pillar 2 check prije bilo kakve implementacije |
| T5 perf | implementirati stress test u `game/_cd_sandbox/`, mjeriti na emulatoru Pixel_4_API33, vratiti brojke po CD-ovom `RESPONSE_TEMPLATE.md` |
| T6 protokol | validan JSON? putanje tačne? `install.ps1` pročitan prije pokretanja, dry-run prvo |

`_cd_sandbox/` foldere ne commitati dok korisnik ne odluči.
