-- Server-Logik wird hauptsaechlich von esv_core uebernommen
-- Diese Datei dient fuer zusaetzliche Multichar-spezifische Server-Events

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    print("^2[ESV]^0 Multichar-System geladen")
end)
