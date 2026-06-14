ESV = ESV or {}
ESV.Items = {}

-- Item-Definitionen: name = { label, weight, stackable, description, usable }
ESV.Items = {
    -- Allgemeine Items
    brot         = { label = "Brot",          weight = 200, stackable = true,  usable = true,  description = "Ein frisches Brot" },
    wasser       = { label = "Wasser",        weight = 300, stackable = true,  usable = true,  description = "Eine Flasche Wasser" },
    burger       = { label = "Burger",        weight = 250, stackable = true,  usable = true,  description = "Ein saftiger Burger" },
    cola         = { label = "Cola",          weight = 300, stackable = true,  usable = true,  description = "Eine Dose Cola" },
    kaffee       = { label = "Kaffee",        weight = 200, stackable = true,  usable = true,  description = "Ein heisser Kaffee" },
    donut        = { label = "Donut",         weight = 150, stackable = true,  usable = true,  description = "Ein glasierter Donut" },
    sandwich     = { label = "Sandwich",      weight = 200, stackable = true,  usable = true,  description = "Ein belegtes Sandwich" },
    energydrink  = { label = "Energy Drink",  weight = 300, stackable = true,  usable = true,  description = "Ein Energy Drink" },

    -- Medizinische Items
    verbandskasten = { label = "Verbandskasten",  weight = 500,  stackable = true,  usable = true,  description = "Erste-Hilfe-Kasten" },
    schmerzmittel  = { label = "Schmerzmittel",   weight = 100,  stackable = true,  usable = true,  description = "Schmerztabletten" },
    bandage        = { label = "Bandage",         weight = 100,  stackable = true,  usable = true,  description = "Sterile Bandage" },
    medikit        = { label = "Medikit",         weight = 800,  stackable = true,  usable = true,  description = "Professionelles Medikit" },

    -- Werkzeuge
    reparaturkit = { label = "Reparaturkit",   weight = 1000, stackable = true,  usable = true,  description = "Fahrzeug-Reparaturkit" },
    lockpick     = { label = "Lockpick",       weight = 200,  stackable = true,  usable = true,  description = "Dietrich zum Aufbrechen" },
    taschenlampe = { label = "Taschenlampe",   weight = 300,  stackable = false, usable = true,  description = "Eine Taschenlampe" },
    seil         = { label = "Seil",           weight = 500,  stackable = true,  usable = false, description = "Ein robustes Seil" },
    klebeband    = { label = "Klebeband",      weight = 200,  stackable = true,  usable = false, description = "Stabiles Klebeband" },
    benzinkanister = { label = "Benzinkanister", weight = 2000, stackable = false, usable = true, description = "Kanister mit Benzin" },

    -- Kommunikation
    handy       = { label = "Handy",          weight = 200,  stackable = false, usable = true,  description = "Smartphone" },
    funkgeraet  = { label = "Funkgeraet",     weight = 500,  stackable = false, usable = true,  description = "Polizei-/EMS-Funkgeraet" },

    -- Waffen-Zubehoer
    pistol_ammo  = { label = "Pistolenmunition", weight = 200,  stackable = true, usable = true, description = "9mm Munition (12 Schuss)" },
    rifle_ammo   = { label = "Gewehrmunition",   weight = 500,  stackable = true, usable = true, description = "5.56mm Munition (30 Schuss)" },
    smg_ammo     = { label = "SMG-Munition",     weight = 300,  stackable = true, usable = true, description = "SMG Munition (30 Schuss)" },
    shotgun_ammo = { label = "Schrotmunition",   weight = 400,  stackable = true, usable = true, description = "12 Gauge Munition (8 Schuss)" },

    -- Polizei-Items
    handschellen = { label = "Handschellen",  weight = 500,  stackable = false, usable = true,  description = "Polizei-Handschellen" },
    polizeiakte  = { label = "Polizeiakte",   weight = 100,  stackable = true,  usable = true,  description = "Polizeiakte" },
    blitzer      = { label = "Blitzer",       weight = 2000, stackable = false, usable = true,  description = "Mobiler Blitzer" },

    -- EMS-Items
    defibrillator = { label = "Defibrillator", weight = 3000, stackable = false, usable = true, description = "AED Defibrillator" },
    trage         = { label = "Trage",         weight = 5000, stackable = false, usable = true, description = "Krankentrage" },

    -- Drogen (Rohmaterial)
    cannabis_samen = { label = "Cannabis Samen",  weight = 50,   stackable = true, usable = false, description = "Hanfsamen" },
    cannabis_blatt = { label = "Cannabis Blatt",   weight = 100,  stackable = true, usable = false, description = "Unverarbeitetes Cannabis" },
    cannabis_trocken = { label = "Getrocknetes Cannabis", weight = 80, stackable = true, usable = false, description = "Getrocknetes Cannabis" },
    joint          = { label = "Joint",            weight = 50,   stackable = true, usable = true,  description = "Ein gedrehter Joint" },
    koka_blatt     = { label = "Koka Blatt",       weight = 100,  stackable = true, usable = false, description = "Rohes Kokablatt" },
    kokain         = { label = "Kokain",           weight = 100,  stackable = true, usable = true,  description = "Verarbeitetes Kokain" },
    meth_zutaten   = { label = "Meth Zutaten",     weight = 500,  stackable = true, usable = false, description = "Chemische Zutaten" },
    meth           = { label = "Crystal Meth",     weight = 100,  stackable = true, usable = true,  description = "Crystal Meth" },

    -- Wertgegenstaende
    goldbarren   = { label = "Goldbarren",    weight = 5000, stackable = true,  usable = false, description = "Ein Goldbarren" },
    diamant      = { label = "Diamant",       weight = 100,  stackable = true,  usable = false, description = "Ein geschliffener Diamant" },
    rolex        = { label = "Rolex Uhr",     weight = 300,  stackable = true,  usable = false, description = "Luxus-Armbanduhr" },
    geldboerse   = { label = "Geldboerse",    weight = 200,  stackable = true,  usable = true,  description = "Gefundene Geldboerse" },
    usb_stick    = { label = "USB-Stick",     weight = 50,   stackable = true,  usable = true,  description = "USB-Speicherstick" },

    -- Schwarzmarkt
    thermit     = { label = "Thermit",        weight = 1000, stackable = true,  usable = true,  description = "Thermit-Ladung" },
    c4          = { label = "C4 Sprengstoff",  weight = 2000, stackable = true,  usable = true,  description = "Plastiksprengstoff" },
    vpn_dongle  = { label = "VPN Dongle",     weight = 100,  stackable = true,  usable = true,  description = "Verschluesselungs-Dongle" },

    -- Schluessel
    autoschluessel = { label = "Autoschluessel", weight = 100, stackable = false, usable = true, description = "Fahrzeugschluessel" },
    hausschluessel = { label = "Hausschluessel", weight = 100, stackable = false, usable = true, description = "Wohnungsschluessel" },

    -- Ausweis
    personalausweis = { label = "Personalausweis", weight = 50, stackable = false, usable = true, description = "Personalausweis" },
    fuehrerschein   = { label = "Fuehrerschein",   weight = 50, stackable = false, usable = true, description = "Fuehrerschein" },
    waffenschein    = { label = "Waffenschein",    weight = 50, stackable = false, usable = true, description = "Waffenschein" },
}

return ESV.Items
