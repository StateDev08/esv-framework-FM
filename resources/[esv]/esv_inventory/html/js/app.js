let inventoryData = [];
let selectedItem = null;
let maxSlots = 40;

const itemIcons = {
    brot: 'fa-bread-slice', wasser: 'fa-bottle-water', burger: 'fa-burger',
    cola: 'fa-glass-water', kaffee: 'fa-mug-hot', donut: 'fa-cookie',
    sandwich: 'fa-hotdog', energydrink: 'fa-bolt',
    verbandskasten: 'fa-kit-medical', schmerzmittel: 'fa-pills', bandage: 'fa-band-aid',
    medikit: 'fa-briefcase-medical',
    reparaturkit: 'fa-wrench', lockpick: 'fa-key', taschenlampe: 'fa-flashlight',
    seil: 'fa-link', klebeband: 'fa-tape', benzinkanister: 'fa-gas-pump',
    handy: 'fa-mobile-screen', funkgeraet: 'fa-walkie-talkie',
    pistol_ammo: 'fa-crosshairs', rifle_ammo: 'fa-crosshairs',
    smg_ammo: 'fa-crosshairs', shotgun_ammo: 'fa-crosshairs',
    handschellen: 'fa-link', polizeiakte: 'fa-file',
    defibrillator: 'fa-heart-pulse', trage: 'fa-bed',
    cannabis_samen: 'fa-seedling', cannabis_blatt: 'fa-leaf',
    cannabis_trocken: 'fa-leaf', joint: 'fa-smoking',
    koka_blatt: 'fa-leaf', kokain: 'fa-vial', meth_zutaten: 'fa-flask', meth: 'fa-vial',
    goldbarren: 'fa-coins', diamant: 'fa-gem', rolex: 'fa-clock',
    geldboerse: 'fa-wallet', usb_stick: 'fa-usb',
    thermit: 'fa-fire', c4: 'fa-bomb', vpn_dongle: 'fa-wifi',
    autoschluessel: 'fa-car', hausschluessel: 'fa-house',
    personalausweis: 'fa-id-card', fuehrerschein: 'fa-id-badge', waffenschein: 'fa-gun',
};

window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.action === 'openInventory') {
        document.getElementById('inventory-container').classList.remove('hidden');
        document.getElementById('player-name').textContent = data.playerName || '';
        inventoryData = data.items || [];
        maxSlots = data.maxSlots || 40;
        renderGrid(data.items, data.maxWeight);
    }

    if (data.action === 'closeInventory') {
        document.getElementById('inventory-container').classList.add('hidden');
        hideContextMenu();
    }

    if (data.action === 'refreshInventory') {
        inventoryData = data.items || [];
        renderGrid(data.items, data.maxWeight);
    }
});

function renderGrid(items, maxWeight) {
    const grid = document.getElementById('inv-grid');
    grid.innerHTML = '';

    const slotMap = {};
    let totalWeight = 0;
    items.forEach(item => {
        slotMap[item.slot] = item;
        totalWeight += item.weight * item.amount;
    });

    document.getElementById('weight-display').textContent =
        (totalWeight / 1000).toFixed(1) + ' / ' + (maxWeight / 1000).toFixed(0) + ' kg';

    for (let i = 1; i <= maxSlots; i++) {
        const slot = document.createElement('div');
        slot.className = 'inv-slot';
        slot.dataset.slot = i;

        const item = slotMap[i];
        if (item) {
            slot.classList.add('has-item');
            const icon = itemIcons[item.name] || 'fa-box';
            slot.innerHTML = `
                <div class="item-icon"><i class="fas ${icon}"></i></div>
                <div class="item-label">${item.label}</div>
                ${item.amount > 1 ? `<div class="item-amount">${item.amount}</div>` : ''}
            `;

            slot.addEventListener('contextmenu', function(e) {
                e.preventDefault();
                selectedItem = item;
                showContextMenu(e.clientX, e.clientY);
            });

            slot.addEventListener('mouseenter', function(e) {
                showTooltip(e.clientX, e.clientY, item);
            });

            slot.addEventListener('mouseleave', function() {
                document.getElementById('item-tooltip').classList.add('hidden');
            });
        }

        grid.appendChild(slot);
    }
}

function showContextMenu(x, y) {
    const menu = document.getElementById('context-menu');
    menu.style.left = x + 'px';
    menu.style.top = y + 'px';
    menu.classList.remove('hidden');
}

function hideContextMenu() {
    document.getElementById('context-menu').classList.add('hidden');
    selectedItem = null;
}

function showTooltip(x, y, item) {
    const tooltip = document.getElementById('item-tooltip');
    document.getElementById('tooltip-name').textContent = item.label;
    document.getElementById('tooltip-desc').textContent = item.description || '';
    document.getElementById('tooltip-weight').textContent = (item.weight / 1000).toFixed(1) + ' kg';
    tooltip.style.left = (x + 15) + 'px';
    tooltip.style.top = (y - 10) + 'px';
    tooltip.classList.remove('hidden');
}

function useItem() {
    if (!selectedItem) return;
    fetch(`https://${GetParentResourceName()}/useItem`, {
        method: 'POST',
        body: JSON.stringify({ name: selectedItem.name, slot: selectedItem.slot })
    });
    hideContextMenu();
}

function giveItem() {
    if (!selectedItem) return;
    fetch(`https://${GetParentResourceName()}/giveItem`, {
        method: 'POST',
        body: JSON.stringify({ name: selectedItem.name, amount: 1 })
    });
    hideContextMenu();
}

function dropItem() {
    if (!selectedItem) return;
    fetch(`https://${GetParentResourceName()}/dropItem`, {
        method: 'POST',
        body: JSON.stringify({ name: selectedItem.name, amount: 1 })
    });
    hideContextMenu();
}

function closeInventory() {
    fetch(`https://${GetParentResourceName()}/closeInventory`, { method: 'POST', body: '{}' });
}

document.addEventListener('click', function(e) {
    if (!e.target.closest('#context-menu')) {
        hideContextMenu();
    }
});

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        closeInventory();
    }
});
