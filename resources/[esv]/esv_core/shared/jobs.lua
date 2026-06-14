ESV = ESV or {}
ESV.Jobs = {}

ESV.Jobs = {
    arbeitslos = {
        label = "Arbeitslos",
        type = "civilian",
        grades = {
            [0] = { label = "Arbeitslos", salary = 200 },
        },
    },

    police = {
        label = "Los Santos Police Department",
        type = "leo",
        grades = {
            [0] = { label = "Kadett",            salary = 1500 },
            [1] = { label = "Officer",            salary = 2000 },
            [2] = { label = "Senior Officer",     salary = 2500 },
            [3] = { label = "Sergeant",           salary = 3000 },
            [4] = { label = "Lieutenant",         salary = 3500 },
            [5] = { label = "Captain",            salary = 4000 },
            [6] = { label = "Commander",          salary = 4500 },
            [7] = { label = "Chief of Police",    salary = 5000 },
        },
        vehicles = {
            { model = "police",   label = "Police Cruiser",  grade = 0 },
            { model = "police2",  label = "Police Buffalo",  grade = 0 },
            { model = "police3",  label = "Police Interceptor", grade = 2 },
            { model = "police4",  label = "Unmarked Cruiser",  grade = 4 },
            { model = "policeb",  label = "Police Motorrad",  grade = 1 },
            { model = "riot",     label = "Riot Van",          grade = 5 },
            { model = "polmav",   label = "Police Maverick",   grade = 6 },
        },
        armory = {
            { item = "handschellen", label = "Handschellen", price = 0, grade = 0 },
            { item = "polizeiakte",  label = "Polizeiakte",  price = 0, grade = 0 },
            { item = "WEAPON_STUNGUN",    label = "Taser",         price = 0, grade = 0, isWeapon = true },
            { item = "WEAPON_PISTOL",     label = "Pistole",       price = 0, grade = 1, isWeapon = true },
            { item = "WEAPON_COMBATPISTOL", label = "Kampfpistole", price = 0, grade = 3, isWeapon = true },
            { item = "WEAPON_SMG",        label = "SMG",           price = 0, grade = 4, isWeapon = true },
            { item = "WEAPON_CARBINERIFLE", label = "Karabiner",   price = 0, grade = 5, isWeapon = true },
            { item = "WEAPON_PUMPSHOTGUN", label = "Shotgun",      price = 0, grade = 3, isWeapon = true },
            { item = "WEAPON_NIGHTSTICK", label = "Schlagstock",   price = 0, grade = 0, isWeapon = true },
            { item = "WEAPON_FLASHLIGHT", label = "Taschenlampe",  price = 0, grade = 0, isWeapon = true },
            { item = "pistol_ammo",       label = "Pistolenmunition", price = 0, grade = 1 },
            { item = "smg_ammo",          label = "SMG Munition",     price = 0, grade = 4 },
            { item = "rifle_ammo",        label = "Gewehrmunition",   price = 0, grade = 5 },
            { item = "shotgun_ammo",      label = "Schrotmunition",   price = 0, grade = 3 },
        },
        stations = {
            mission_row = {
                label = "Mission Row PD",
                position = vector3(441.0, -982.0, 30.7),
                blip = { sprite = 60, color = 29, scale = 1.0 },
                duty = vector3(440.7, -981.2, 30.7),
                armory = vector3(452.5, -980.0, 30.7),
                garage = vector4(447.4, -1024.5, 28.6, 4.0),
                locker = vector3(449.8, -985.0, 30.7),
            },
        },
    },

    ems = {
        label = "Emergency Medical Services",
        type = "ems",
        grades = {
            [0] = { label = "Praktikant",        salary = 1200 },
            [1] = { label = "Rettungssanitaeter", salary = 1800 },
            [2] = { label = "Notfallsanitaeter",  salary = 2200 },
            [3] = { label = "Notarzt",            salary = 2800 },
            [4] = { label = "Oberarzt",           salary = 3500 },
            [5] = { label = "Chefarzt",           salary = 4200 },
        },
        vehicles = {
            { model = "ambulance",  label = "Krankenwagen",    grade = 0 },
            { model = "lguard",     label = "Lifeguard SUV",   grade = 0 },
            { model = "polmav",     label = "Rettungsheli",    grade = 4 },
        },
        stations = {
            pillbox = {
                label = "Pillbox Hill Hospital",
                position = vector3(340.5, -1397.0, 32.5),
                blip = { sprite = 61, color = 1, scale = 1.0 },
                duty = vector3(340.0, -1395.0, 32.5),
                armory = vector3(342.0, -1400.0, 32.5),
                garage = vector4(338.0, -1456.0, 29.5, 0.0),
                locker = vector3(335.0, -1393.0, 32.5),
            },
        },
    },

    mechanic = {
        label = "Los Santos Customs",
        type = "mechanic",
        grades = {
            [0] = { label = "Lehrling",       salary = 1000 },
            [1] = { label = "Mechaniker",     salary = 1500 },
            [2] = { label = "Meister",        salary = 2000 },
            [3] = { label = "Werkstattleiter", salary = 2800 },
            [4] = { label = "Geschaeftsfuehrer", salary = 3500 },
        },
        vehicles = {
            { model = "towtruck",   label = "Abschleppwagen",  grade = 0 },
            { model = "flatbed",    label = "Tieflader",       grade = 2 },
        },
        stations = {
            lsc = {
                label = "LS Customs",
                position = vector3(-337.0, -136.0, 39.0),
                blip = { sprite = 446, color = 5, scale = 0.9 },
                duty = vector3(-339.0, -134.0, 39.0),
                garage = vector4(-345.0, -138.0, 39.0, 70.0),
            },
        },
    },

    taxi = {
        label = "Downtown Cab Co.",
        type = "civilian",
        grades = {
            [0] = { label = "Taxifahrer",      salary = 800 },
            [1] = { label = "Erfahrener Fahrer", salary = 1200 },
            [2] = { label = "Disponent",         salary = 1600 },
            [3] = { label = "Geschaeftsfuehrer", salary = 2200 },
        },
        vehicles = {
            { model = "taxi", label = "Taxi", grade = 0 },
        },
    },

    trucker = {
        label = "Spediteur",
        type = "civilian",
        grades = {
            [0] = { label = "Fahrer",          salary = 900 },
            [1] = { label = "Fernfahrer",      salary = 1400 },
            [2] = { label = "Disponent",       salary = 1800 },
        },
    },

    reporter = {
        label = "Weazel News",
        type = "civilian",
        grades = {
            [0] = { label = "Praktikant",     salary = 700 },
            [1] = { label = "Reporter",        salary = 1200 },
            [2] = { label = "Redakteur",       salary = 1800 },
            [3] = { label = "Chefredakteur",   salary = 2500 },
        },
    },

    judge = {
        label = "Justiz",
        type = "government",
        grades = {
            [0] = { label = "Anwalt",         salary = 3000 },
            [1] = { label = "Staatsanwalt",   salary = 4000 },
            [2] = { label = "Richter",        salary = 5000 },
        },
    },

    realtor = {
        label = "Immobilienmakler",
        type = "civilian",
        grades = {
            [0] = { label = "Assistent",       salary = 800 },
            [1] = { label = "Makler",          salary = 1500 },
            [2] = { label = "Senior Makler",   salary = 2500 },
        },
    },
}

return ESV.Jobs
