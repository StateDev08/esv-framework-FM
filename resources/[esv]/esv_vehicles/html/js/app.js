let currentGarage = null;
let allDealerVehicles = [];
let currentCategory = null;

window.addEventListener('message', function(event) {
    const d = event.data;

    if (d.action === 'openGarage') {
        document.getElementById('garage-container').classList.remove('hidden');
        document.getElementById('garage-title').textContent = d.garageLabel || 'GARAGE';
        currentGarage = d.garage;
        renderGarageVehicles(d.vehicles);
    }

    if (d.action === 'openDealership') {
        document.getElementById('dealer-container').classList.remove('hidden');
        document.getElementById('dealer-title').textContent = d.shopLabel || 'AUTOHAUS';
        allDealerVehicles = d.vehicles || [];
        renderCategories(d.categories);
        renderDealerVehicles(allDealerVehicles);
    }

    if (d.action === 'closeUI') {
        document.getElementById('garage-container').classList.add('hidden');
        document.getElementById('dealer-container').classList.add('hidden');
    }
});

function renderGarageVehicles(vehicles) {
    const list = document.getElementById('vehicle-list');
    list.innerHTML = '';
    if (!vehicles || vehicles.length === 0) {
        list.innerHTML = '<p style="text-align:center;color:#555;padding:30px;">Keine Fahrzeuge in dieser Garage</p>';
        return;
    }
    vehicles.forEach(v => {
        const div = document.createElement('div');
        div.className = 'vehicle-item';
        div.innerHTML = `
            <div class="veh-info">
                <div class="veh-name">${v.label}</div>
                <div class="veh-details">Kennzeichen: ${v.plate} | Kraftstoff: ${Math.floor(v.fuel)}%</div>
            </div>
            <button class="veh-btn spawn" onclick="spawnVehicle(${v.id})">AUSFAHREN</button>
        `;
        list.appendChild(div);
    });
}

function renderCategories(categories) {
    const tabs = document.getElementById('category-tabs');
    tabs.innerHTML = '<button class="cat-tab active" onclick="filterCategory(null, this)">Alle</button>';
    for (const [key, cat] of Object.entries(categories || {})) {
        tabs.innerHTML += `<button class="cat-tab" onclick="filterCategory('${key}', this)">${cat.label}</button>`;
    }
}

function filterCategory(cat, btn) {
    currentCategory = cat;
    document.querySelectorAll('.cat-tab').forEach(t => t.classList.remove('active'));
    if (btn) btn.classList.add('active');
    const filtered = cat ? allDealerVehicles.filter(v => v.category === cat) : allDealerVehicles;
    renderDealerVehicles(filtered);
}

function renderDealerVehicles(vehicles) {
    const list = document.getElementById('dealer-list');
    list.innerHTML = '';
    vehicles.forEach(v => {
        const div = document.createElement('div');
        div.className = 'vehicle-item';
        div.innerHTML = `
            <div class="veh-info">
                <div class="veh-name">${v.label}</div>
                <div class="veh-details">${v.category}</div>
            </div>
            <div class="veh-price">$${formatMoney(v.price)}</div>
            <button class="veh-btn buy" onclick="buyVehicle('${v.model}', '${v.shop}')">KAUFEN</button>
        `;
        list.appendChild(div);
    });
}

function spawnVehicle(id) {
    fetch(`https://${GetParentResourceName()}/spawnVehicle`, {
        method: 'POST', body: JSON.stringify({ vehicleId: id, garage: currentGarage })
    });
}

function storeVehicle() {
    fetch(`https://${GetParentResourceName()}/storeVehicle`, {
        method: 'POST', body: JSON.stringify({ garage: currentGarage })
    });
}

function buyVehicle(model, shop) {
    fetch(`https://${GetParentResourceName()}/buyVehicle`, {
        method: 'POST', body: JSON.stringify({ model: model, shop: shop })
    });
}

function closeGarage() {
    fetch(`https://${GetParentResourceName()}/closeGarage`, { method: 'POST', body: '{}' });
}

function closeDealership() {
    fetch(`https://${GetParentResourceName()}/closeDealership`, { method: 'POST', body: '{}' });
}

function formatMoney(n) { return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.'); }

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') { closeGarage(); closeDealership(); }
});
