const tips = [
    "Druecke F1 um dein Telefon zu oeffnen",
    "Druecke TAB fuer dein Inventar",
    "Druecke Z fuer die Spielerliste",
    "Druecke U um dein Fahrzeug zu (ent)sperren",
    "Druecke X fuer Haende hoch",
    "Nutze /e [emote] fuer Animationen",
    "Nutze /911 oder /112 fuer Notrufe",
    "Nutze /funk [frequenz] fuer den Funkkanal",
    "Besuche das Autohaus fuer neue Fahrzeuge",
    "Halte dich an die Serverregeln fuer ein gutes RP-Erlebnis",
    "Tanke dein Fahrzeug an Tankstellen auf",
    "EMS kann dich wiederbeleben - warte auf den Rettungsdienst!",
];

let currentTip = 0;
let progress = 0;

function updateTip() {
    document.getElementById('loading-tip').textContent = tips[currentTip % tips.length];
    currentTip++;
}

function updateProgress() {
    progress = Math.min(100, progress + Math.random() * 15);
    document.getElementById('progress-fill').style.width = progress + '%';

    const stages = [
        { min: 0, max: 20, text: 'Verbinde mit Server...' },
        { min: 20, max: 40, text: 'Lade Ressourcen...' },
        { min: 40, max: 60, text: 'Lade Spielwelt...' },
        { min: 60, max: 80, text: 'Synchronisiere Daten...' },
        { min: 80, max: 100, text: 'Fast fertig...' },
    ];

    for (const stage of stages) {
        if (progress >= stage.min && progress < stage.max) {
            document.getElementById('loading-text').textContent = stage.text;
            break;
        }
    }
}

updateTip();
setInterval(updateTip, 5000);
setInterval(updateProgress, 1500);

const handlerTypes = ['startInitFunctionOrder', 'initFunctionInvoking', 'startDataFileEntries', 'performMapLoadFunction'];
window.addEventListener('message', function(event) {
    if (handlerTypes.includes(event.data.eventName)) {
        progress = Math.min(100, progress + 5);
        document.getElementById('progress-fill').style.width = progress + '%';
    }
});
