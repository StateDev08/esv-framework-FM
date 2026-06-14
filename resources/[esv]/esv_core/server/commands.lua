-- Grundlegende Server-Befehle

RegisterCommand('esv', function(source, args, rawCommand)
    if source ~= 0 then return end -- Nur Konsole
    print("^2[ESV Framework]^0 Version 1.0.0")
    print("^2[ESV Framework]^0 Spieler online: " .. ESV.Functions.GetOnlinePlayerCount())
end, false)
