window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.action === 'toggleHud') {
        const hud = document.getElementById('hud-container');
        if (data.visible) {
            hud.classList.remove('hidden');
        } else {
            hud.classList.add('hidden');
        }
    }

    if (data.action === 'updateHud') {
        document.getElementById('health-fill').style.height = data.health + '%';
        document.getElementById('armor-fill').style.height = data.armor + '%';
        document.getElementById('hunger-fill').style.height = data.hunger + '%';
        document.getElementById('thirst-fill').style.height = data.thirst + '%';
        document.getElementById('stress-fill').style.height = data.stress + '%';

        const voiceIcon = document.getElementById('voice-icon');
        if (data.talking) {
            voiceIcon.classList.add('voice-active');
        } else {
            voiceIcon.classList.remove('voice-active');
        }

        document.getElementById('cash-amount').textContent = '$' + formatMoney(data.cash);
        document.getElementById('bank-amount').textContent = '$' + formatMoney(data.bank);

        const vehHud = document.getElementById('vehicle-hud');
        if (data.inVehicle) {
            vehHud.classList.remove('hidden');
            document.getElementById('speed-value').textContent = data.speed;
            document.getElementById('fuel-fill').style.width = data.fuel + '%';
        } else {
            vehHud.classList.add('hidden');
        }

        // Color changes for low values
        const hungerBar = document.getElementById('hunger-bar');
        const thirstBar = document.getElementById('thirst-bar');
        if (data.hunger < 25) hungerBar.classList.add('critical');
        else hungerBar.classList.remove('critical');
        if (data.thirst < 25) thirstBar.classList.add('critical');
        else thirstBar.classList.remove('critical');
    }

    if (data.action === 'updateMoney') {
        if (data.moneyType === 'cash') {
            document.getElementById('cash-amount').textContent = '$' + formatMoney(data.amount);
        } else if (data.moneyType === 'bank') {
            document.getElementById('bank-amount').textContent = '$' + formatMoney(data.amount);
        }
    }
});

function formatMoney(amount) {
    return amount.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.');
}
