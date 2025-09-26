# Yu-Gi-Oh! Zorc and Bakura Custom Cards for EdoPro

Ovaj paket sadrži custom Yu-Gi-Oh! karte bazirane na Zorc i Bakura temi iz originalne baze podataka.

## Sadržaj

### Karte (ID 1300-1312 + Token 1410)

1. **Zorc Necrophades, God of Darkness** (ID: 1300)
   - Fusion Monster, Level 12, ATK: 4000, DEF: 4000
   - DIVINE/DARK Fusion monster sa win condition

2. **Diabound LV10** (ID: 1301)
   - Fusion Monster, Level 10, ATK: 3500, DEF: 2500
   - Najjači Diabound sa mogućnošću opremanja do 3 čudovišta

3. **Diabound LV9** (ID: 1302)
   - Effect Monster, Level 9, ATK: 3000, DEF: 2000
   - LV monster sa level up mehanizmom

4. **Diabound LV8** (ID: 1303)
   - Effect Monster, Level 8, ATK: 2500, DEF: 1800
   - LV monster sa level up mehanizmom

5. **Diabound LV7** (ID: 1304)
   - Effect Monster, Level 7, ATK: 2000, DEF: 1500
   - LV monster sa level up mehanizmom

6. **Diabound LV6** (ID: 1305)
   - Effect Monster, Level 6, ATK: 1800, DEF: 1200
   - LV monster sa level up mehanizmom

7. **Diabound LV5** (ID: 1306)
   - Effect Monster, Level 5, ATK: 1500, DEF: 1000
   - LV monster sa level up mehanizmom

8. **Diabound LV4** (ID: 1307)
   - Effect Monster, Level 4, ATK: 1200, DEF: 800
   - Početni Diabound sa equip mogućnostima

9. **Dark Spirit of Chaos** (ID: 1308)
   - Flip Effect Monster, Level 3, ATK: 1000, DEF: 1500
   - Support karta za level up mehanizam

10. **Illushu** (ID: 1309)
    - Effect Monster, Level 2, ATK: 800, DEF: 600
    - Hand trap sa defensive efektima

11. **Spirit Illusion** (ID: 1310)
    - Equip Spell Card
    - Kreira token kopiju opremljenog čudovišta

12. **Polymerization** (ID: 1311)
    - Normal Spell Card (reprint)
    - Omogućava Fusion iz Graveyard-a

13. **Monster Reborn** (ID: 1312)
    - Normal Spell Card (reprint)
    - Standardni Monster Reborn efekat

14. **Doppelganger Token** (ID: 1410)
    - Token Monster
    - Kreiran od strane Spirit Illusion

## Instalacija za EdoPro

1. **Kopiraj Lua skriptove:**
   - Kopiraj sve `.lua` fajlove (c1300.lua do c1312.lua + c1410.lua) u `EdoPro/script/` folder

2. **Kopiraj bazu podataka:**
   - Kopiraj `cards.cdb` fajl u `EdoPro/databases/` folder

3. **Restartuj EdoPro**
   - Restartuj EdoPro da učita nove karte

## Mehanizmi

### Diabound LV Serija
- Počinje sa Diabound LV4 koji se može opremiti na čudovišta
- Svaki LV može da se level up-uje u viši LV tokom Main Phase 2
- Viši LV-ovi imaju jače efekte i mogućnost opremanja više čudovišta
- LV10 je Fusion monster koji zahteva LV9 + Monster Reborn

### Zorc Necrophades
- Ultimativni boss monster
- Zahteva DIVINE + DARK materijale za Fusion
- Ima win condition kroz direct attack
- Potpuno imun na opponent efekte

### Support Karte
- Dark Spirit of Chaos pomaže sa level up-om
- Illushu pruža defensive opcije
- Spirit Illusion kreira kopije Diabound čudovišta

## Napomene

- Sve karte koriste setcode 0x1300 za prepoznavanje
- Skriptovi su kompatibilni sa najnovijom verzijom EdoPro
- Karte su balansirane za casual play

## Autor

Kreirano na osnovu originalne "Deck Zorc and Bakura ENG.db" baze podataka.