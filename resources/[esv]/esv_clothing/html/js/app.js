const componentNames = {
    1: 'Maske', 3: 'Oberteil', 4: 'Hose', 5: 'Tasche',
    6: 'Schuhe', 7: 'Accessoire', 8: 'Unterhemd', 9: 'Koerperschutz', 11: 'Jacke'
};
const propNames = { 0: 'Hut', 1: 'Brille', 2: 'Ohrring', 6: 'Uhr', 7: 'Armband' };

let currentValues = {};
let selectedTab = 'components';

window.addEventListener('message', function(event) {
    const d = event.data;
    if (d.action === 'openClothing') {
        document.getElementById('clothing-container').classList.remove('hidden');
        currentValues = d.currentSkin || {};
        renderCategories();
        renderControls('components');
    }
    if (d.action === 'closeClothing') {
        document.getElementById('clothing-container').classList.add('hidden');
    }
});

function renderCategories() {
    const cats = document.getElementById('clothing-categories');
    cats.innerHTML = `
        <button class="cat-btn active" onclick="switchTab('components', this)">Kleidung</button>
        <button class="cat-btn" onclick="switchTab('props', this)">Accessoires</button>
    `;
}

function switchTab(tab, btn) {
    selectedTab = tab;
    document.querySelectorAll('.cat-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    renderControls(tab);
}

function renderControls(tab) {
    const container = document.getElementById('controls');
    container.innerHTML = '';

    if (tab === 'components') {
        for (const [id, name] of Object.entries(componentNames)) {
            const comp = currentValues.components ? currentValues.components[id] : { drawable: 0, texture: 0 };
            container.innerHTML += createControl(name, 'comp', id, comp ? comp.drawable : 0, comp ? comp.texture : 0);
        }
    } else {
        for (const [id, name] of Object.entries(propNames)) {
            const prop = currentValues.props ? currentValues.props[id] : { drawable: -1, texture: 0 };
            container.innerHTML += createControl(name, 'prop', id, prop ? prop.drawable : -1, prop ? prop.texture : 0);
        }
    }
}

function createControl(name, type, id, drawable, texture) {
    return `
        <div class="control-item">
            <div class="control-label">${name}</div>
            <div class="control-btns">
                <button class="arrow-btn" onclick="changeValue('${type}', ${id}, 'drawable', -1)"><i class="fas fa-chevron-left"></i></button>
                <span class="control-value" id="${type}-${id}-drawable">${drawable}</span>
                <button class="arrow-btn" onclick="changeValue('${type}', ${id}, 'drawable', 1)"><i class="fas fa-chevron-right"></i></button>
            </div>
        </div>
        <div class="control-item">
            <div class="control-label">${name} Textur</div>
            <div class="control-btns">
                <button class="arrow-btn" onclick="changeValue('${type}', ${id}, 'texture', -1)"><i class="fas fa-chevron-left"></i></button>
                <span class="control-value" id="${type}-${id}-texture">${texture}</span>
                <button class="arrow-btn" onclick="changeValue('${type}', ${id}, 'texture', 1)"><i class="fas fa-chevron-right"></i></button>
            </div>
        </div>
    `;
}

function changeValue(type, id, prop, dir) {
    const el = document.getElementById(`${type}-${id}-${prop}`);
    let val = parseInt(el.textContent) + dir;
    if (val < (type === 'prop' ? -1 : 0)) val = type === 'prop' ? -1 : 0;
    el.textContent = val;

    const drawable = parseInt(document.getElementById(`${type}-${id}-drawable`).textContent);
    const texture = parseInt(document.getElementById(`${type}-${id}-texture`).textContent);

    if (type === 'comp') {
        fetch(`https://${GetParentResourceName()}/previewComponent`, {
            method: 'POST', body: JSON.stringify({ component: parseInt(id), drawable, texture })
        });
    } else {
        fetch(`https://${GetParentResourceName()}/previewProp`, {
            method: 'POST', body: JSON.stringify({ prop: parseInt(id), drawable, texture })
        });
    }
}

function saveOutfit() {
    fetch(`https://${GetParentResourceName()}/saveOutfit`, { method: 'POST', body: '{}' });
}

function resetOutfit() {
    fetch(`https://${GetParentResourceName()}/resetOutfit`, { method: 'POST', body: '{}' });
}

function closeClothing() {
    fetch(`https://${GetParentResourceName()}/closeClothing`, { method: 'POST', body: '{}' });
}

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeClothing();
});
