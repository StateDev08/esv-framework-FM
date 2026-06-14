# ESV Framework - FiveM Hardcore RP

Ein vollständiges, eigenständiges FiveM-Framework für Hardcore-Roleplay-Server.

## Features

### Core Systems
- **Multi-Character System** – Erstelle und verwalte mehrere Charaktere pro Spieler
- **Identitätssystem** – Vollständige Charaktererstellung (Name, Geburtsdatum, Geschlecht, Nationalität)
- **HUD** – Gesundheit, Rüstung, Hunger, Durst, Bargeld-Anzeige
- **Inventar** – Gewichtsbasiertes Inventarsystem mit Drag & Drop NUI
- **Banksystem** – Bankkonten, Geldautomaten, Überweisungen
- **Admin-System** – Umfangreiche Admin-Befehle und Verwaltung

### Jobs & Wirtschaft
- **Polizei (LSPD)** – Durchsuchung, Verhaftung, Bußgelder, Fahrzeugflotte
- **Rettungsdienst (EMS)** – Wiederbelebung, Heilung, Krankenwagen
- **Mechaniker** – Fahrzeugreparatur, Tuning, Abschleppdienst
- **Gehaltssystem** – Automatische Gehaltsauszahlung basierend auf Job & Rang

### Fahrzeuge
- **Garagen** – Fahrzeuge einparken & abrufen
- **Autohändler** – Fahrzeuge kaufen & verkaufen
- **Tanksystem** – Realistische Tankstellen
- **Fahrzeugschlüssel** – Schlüsselverwaltung & Aufbrechen

### RP-Features
- **Telefon** – Anrufe, SMS, Kontakte
- **Wohnungen** – Kaufen, Einrichten, Lager
- **Kleidung** – Vollständige Charakter-Anpassung
- **Tod & Respawn** – Realistisches Tod-System mit EMS-Abhängigkeit
- **Status-System** – Hunger, Durst, Stress
- **Emotes** – Animationen & Emotes

### Kriminelle Aktivitäten
- **Drogensystem** – Anbau, Verarbeitung, Verkauf
- **Überfälle** – Laden-, Bank- und Hausüberfälle
- **Gefängnis** – Gefängnissystem mit Aktivitäten
- **Schwarzmarkt** – Illegale Waffen & Items

### Kommunikation
- **911-Dispatch** – Notrufsystem für Polizei & EMS
- **Funk** – Funkfrequenzen für Fraktionen
- **Scoreboard** – Spielerübersicht

## Voraussetzungen

- [FiveM Server](https://fivem.net/)
- [MariaDB](https://mariadb.org/) oder [MySQL](https://www.mysql.com/)
- [oxmysql](https://github.com/overextended/oxmysql) (Datenbank-Resource)
- [ox_lib](https://github.com/overextended/ox_lib) (Utility-Library)

## Installation

1. **Datenbank einrichten:**
   ```sql
   -- Erstelle eine neue Datenbank
   CREATE DATABASE esv_framework;
   
   -- Importiere das SQL-Schema
   mysql -u root -p esv_framework < sql/esv_framework.sql
   ```

2. **Dependencies installieren:**
   - Lade [oxmysql](https://github.com/overextended/oxmysql/releases) herunter → `resources/[deps]/oxmysql/`
   - Lade [ox_lib](https://github.com/overextended/ox_lib/releases) herunter → `resources/[deps]/ox_lib/`

3. **server.cfg anpassen:**
   - Trage deinen FiveM-Lizenzschlüssel ein
   - Passe die MySQL-Verbindung an
   - Konfiguriere Server-Name und Einstellungen

4. **Server starten:**
   ```bash
   cd /path/to/server
   ./run.sh +exec server.cfg
   ```

## Konfiguration

Jede Resource hat eine eigene `config.lua` (im `shared/`-Ordner von `esv_core`) oder lokale Config-Dateien. Die zentrale Konfiguration findest du in:

- `resources/[esv]/esv_core/shared/config.lua` – Hauptkonfiguration
- `resources/[esv]/esv_core/shared/items.lua` – Item-Definitionen
- `resources/[esv]/esv_core/shared/jobs.lua` – Job-Definitionen
- `resources/[esv]/esv_core/shared/vehicles.lua` – Fahrzeug-Definitionen

## Ordnerstruktur

```
esv-framework-FM/
├── server.cfg                    # Server-Konfiguration
├── sql/
│   └── esv_framework.sql        # Datenbank-Schema
└── resources/
    └── [esv]/
        ├── esv_core/             # Kern-Framework
        ├── esv_multichar/        # Charakter-Auswahl
        ├── esv_hud/              # HUD-Anzeige
        ├── esv_inventory/        # Inventarsystem
        ├── esv_banking/          # Banksystem
        ├── esv_status/           # Status (Hunger/Durst)
        ├── esv_death/            # Tod & Respawn
        ├── esv_notify/           # Benachrichtigungen
        ├── esv_admin/            # Admin-System
        ├── esv_jobs/             # Job-System
        ├── esv_vehicles/         # Fahrzeugsystem
        ├── esv_clothing/         # Kleidungssystem
        ├── esv_phone/            # Telefonsystem
        ├── esv_housing/          # Wohnungssystem
        ├── esv_shops/            # Shop-System
        ├── esv_criminal/         # Kriminelle Aktivitäten
        ├── esv_dispatch/         # 911-Dispatch
        ├── esv_emotes/           # Emote-System
        ├── esv_scoreboard/       # Scoreboard
        └── esv_loading/          # Ladebildschirm
```

## Lizenz

Dieses Framework ist Eigentum von ESV / StateDevs. Alle Rechte vorbehalten.

## Support

Bei Fragen oder Problemen wende dich an das ESV-Entwicklerteam.
