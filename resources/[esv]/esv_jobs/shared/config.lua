JobConfig = {}

JobConfig.DutyBlipColor = 2
JobConfig.OffDutyBlipColor = 4

JobConfig.PoliceActions = {
    cuff = { label = "Fesseln/Entfesseln", anim = "mp_arrest_paired", dict = "cop_p2_back_right" },
    search = { label = "Durchsuchen" },
    fine = { label = "Bussgeld ausstellen" },
    jail = { label = "Einsperren" },
    escort = { label = "Mitnehmen/Loslassen" },
    impound = { label = "Fahrzeug beschlagnahmen" },
}

JobConfig.EMSActions = {
    revive = { label = "Wiederbelebung" },
    heal = { label = "Behandeln" },
    escort = { label = "Auf Trage legen" },
}

JobConfig.MechanicActions = {
    repair = { label = "Reparieren", price = 500 },
    wash = { label = "Waschen", price = 100 },
}

return JobConfig
