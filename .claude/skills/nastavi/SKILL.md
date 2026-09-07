---
name: nastavi
description: Automatizuje "gdje smo stali" — čita CHECKPOINT.md frontmatter i aktivnu sekciju, nalazi sljedeći korak, provjerava scope. Koristi kad korisnik kaže "nastavi", "šta je sljedeće", ili počinje novu sesiju bez konteksta.
---

# Nastavi — session-start protokol

Ovaj skill automatizuje protokol iz `CLAUDE.md` § "Početak sesije" — umjesto da svaki put ručno izvodiš isti niz čitanja, slijedi ove korake:

1. Pročitaj `docs/06-production/CHECKPOINT.md` frontmatter (ne cijeli fajl): `aktivna_sekcija`, `sljedeci_korak`, `b0_aktivan`, `milestone`, `zadnja_sesija`, `zadnje_azurirano`.
2. Ako `b0_aktivan: true` → javi kratki B0 podsjetnik i pitaj "preskoči B0" / "B0 gotovo". Ako `false` ili polje ne postoji → **ne spominji B0 uopšte**.
3. U aktivnoj CHECKPOINT sekciji (npr. `## Sekcija D`) nađi tablicu "Aktivne trake (feature ID)" ili ekvivalentnu listu i identifikuj prvu stavku sa statusom "u toku" ili prvi neoznačen `[ ]` checkbox — to je sljedeći konkretan korak.
4. Otvori doc na koji `sljedeci_korak` upućuje (freeze/hub link iz tog reda) da potvrdiš da je opis još uvijek tačan.
5. Provjeri `docs/06-production/scope-i-granice.md` — red za trenutni `milestone` iz koraka 1, da znaš šta je IN/OUT prije nego predložiš bilo šta izvan tog koraka (puna scope-guard procedura je u `CLAUDE.md`).
6. Javi korisniku kratak sažetak: **milestone**, **aktivna sekcija**, **sljedeći konkretan korak** (sa linkom na freeze/hub doc), i eventualno napomenu ako je nešto blizu scope granice.

Ne čitaj cijeli `CHECKPOINT.md` ako frontmatter + aktivna sekcija tablica već daju dovoljno konteksta — cilj je brz, jeftin odgovor na "šta je sljedeće", ne puni re-read cijelog projekta.

Ako korisnik kaže nešto poput "nastavi sa chata" bez dodatnog konteksta, ovaj protokol JE odgovor — ne traži dodatna pojašnjenja prije nego što ga izvršiš.
