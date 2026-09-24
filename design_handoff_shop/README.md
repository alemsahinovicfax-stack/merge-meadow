# Handoff — Shop

Jedan dizajn Shop stranice za Merge Meadow (1080 × 1920 baza, stranica 1080 × 1597 između postojećeg headera 143 i footera 180).

## Fajlovi
- `design/ShopScreen.dc.html` — živi ekran. Klikabilni tokovi (kupovina za coine s potvrdom, IAP busy/uspjeh/neuspjeh, boosteri, restore). Props: `scene` (16 stanja), `section`, `price` (eur / km / long), `storeResult` (success / cancel / pending / error).
- `design/Shop Specs.dc.html` — prije → poslije, preglednik stanja, dijelovi, uloge boja.
- `design/HubScreen.dc.html` — kopija headera/footera iz `design_handoff_hub_chrome` (nepromijenjena).
- `godot/` — `shop_export.json`, `ui_shop.gd`, `shop_tree.txt`, README.

## Odlučeno
1. Pozadina stranice `#2E4733` (Camp livada) umjesto `#B8E0F5`.
2. Krem kartice, Nunito, bez Godot default dugmadi i lavanda panela.
3. Sticky red sa 4 JumpChipa (Looks · Seasons · Boosters · Support) + scroll-spy.
4. Redoslijed: Looks → Seasons → Boosters → Support (coin stvari prve, pravi novac niže).
5. Kozmetika grupisana po slotu (Pip skin, Meadow tint, Album frame).
6. Svaki kozmetički predmet ima pregled „Now | With it“, crtan iz igre (UiRun boje × modulate, PipDraw, mini Album).
7. Opremljen predmet → jedan pregled, bez podjele.
8. Kupovina za coine = 2 tapa: „Buy & wear“ → na kartici „Back | Buy for ◎ n“ + stanje nakon.
9. Kupljeno = odmah opremljeno; status na kartici + −N pop prema coin chipu.
10. Nedovoljno coina: „Need n more · earn in runs“, bez inputa.
11. Boja = valuta: zlatno dugme za coine, lavanda za pravi novac, PriceTag uvijek krem-zlatni.
12. Tagovi (Owned / Wearing / Yours / Coming soon) su 60–76 visoki; dugmad 120–130 — nikad se ne miješaju.
13. Season kartice u mood boji, roster 3 × 2, tagline, „same runs, same rewards“.
14. Kupljena sezona → „Play it on Home ↗“ (vodi na Home s fokusom), ne mrtvo dugme.
15. Coming soon (Ember Fen): bez cijene i bez dugmeta.
16. Jedna IAP kupovina u isto vrijeme: aktivno dugme „Waiting for store…“, ostala na 50 %.
17. Neuspjeh ostaje na kartici (roze) do sljedećeg tapa; pending je žut, ne greška.
18. Booster „Use one“ postoji samo s brojem > 0; Merge Hint aktivan → „Go to Arena ↗“; pun bag blokira Loot Burst.
19. Starter Pack pokazuje sadržaj kao 3 chipa; nakon kupovine „Claimed“ + toast.
20. Restore se ne crta u stub modu.
21. Cijene su store stringovi; > 7 znakova → 44 px, nikad manje; PriceTag raste.
22. Tekst ≥ 38, cijene ≥ 44, touch ≥ 120. Fair note na dnu stranice.

## Otvoreno
- `docs/04-experience/design-drafts/shop-cd-brief.md`, `design_handoff_journal/`, `ui_stage.gd` i `ui_journal.gd` nisu bili na `master` — rađeno po promptu i postojećem kodu. Kad se pushnu, provjeriti §5 tokene i §7.1 listu stanja.
- Zlatni Album ram: uskladiti s Journal handoffom.
- Pip skin u runu je PipDraw placeholder.

## Van zadatka (ideje, nije urađeno)
- Slojeviti Pip sprite za skinove umjesto PipDraw.
- Pravi bloom ikone u SeasonRoster (collection_bloom_icon.gd) umjesto krugova.
- „Try on“ u Arena pregledu prije kupovine.
