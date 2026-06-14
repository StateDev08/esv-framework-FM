let currentSlot = null;
let deleteSlot = null;

window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.action === 'openMultichar') {
        document.getElementById('multichar-container').classList.remove('hidden');
        renderSlots(data.characters, data.maxSlots);
    }

    if (data.action === 'closeMultichar') {
        document.getElementById('multichar-container').classList.add('hidden');
    }
});

function renderSlots(characters, maxSlots) {
    const container = document.getElementById('char-slots');
    container.innerHTML = '';

    for (let i = 1; i <= maxSlots; i++) {
        const char = characters[i];
        const slot = document.createElement('div');
        slot.className = 'char-slot' + (char ? '' : ' empty');

        if (char) {
            slot.innerHTML = `
                <div class="slot-number">SLOT ${i}</div>
                <div class="char-icon"><i class="fas fa-user"></i></div>
                <div class="char-name">${char.firstname} ${char.lastname}</div>
                <div class="char-info">
                    <div class="info-row">
                        <span class="label">Geburtsdatum</span>
                        <span class="value">${char.dateofbirth}</span>
                    </div>
                    <div class="info-row">
                        <span class="label">Job</span>
                        <span class="value">${char.jobLabel}</span>
                    </div>
                    <div class="info-row">
                        <span class="label">Rang</span>
                        <span class="value">${char.gradeLabel}</span>
                    </div>
                    <div class="info-row">
                        <span class="label">Bargeld</span>
                        <span class="value">$${formatMoney(char.cash)}</span>
                    </div>
                    <div class="info-row">
                        <span class="label">Bank</span>
                        <span class="value">$${formatMoney(char.bank)}</span>
                    </div>
                </div>
                <div class="slot-buttons">
                    <button class="btn btn-play" onclick="playCharacter(${i})">
                        <i class="fas fa-play"></i> SPIELEN
                    </button>
                    <button class="btn btn-delete" onclick="deleteCharacter(${i})">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            `;
        } else {
            slot.innerHTML = `
                <div class="slot-number">SLOT ${i}</div>
                <div class="char-icon"><i class="fas fa-plus-circle"></i></div>
                <div class="char-name">Leer</div>
                <p style="color: #888; font-size: 14px; margin-top: 12px;">Klicke um einen neuen Charakter zu erstellen</p>
            `;
            slot.onclick = function() { openCreateForm(i); };
        }

        container.appendChild(slot);
    }
}

function playCharacter(slot) {
    fetch(`https://${GetParentResourceName()}/selectCharacter`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ slot: slot })
    });
}

function openCreateForm(slot) {
    currentSlot = slot;
    document.getElementById('create-form').classList.remove('hidden');
    document.getElementById('firstname').value = '';
    document.getElementById('lastname').value = '';
    document.getElementById('dateofbirth').value = '';
    document.getElementById('gender').value = '0';
    document.getElementById('nationality').value = 'Deutschland';
    document.getElementById('firstname').focus();
}

function cancelCreate() {
    currentSlot = null;
    document.getElementById('create-form').classList.add('hidden');
}

function submitCreate() {
    const firstname = document.getElementById('firstname').value.trim();
    const lastname = document.getElementById('lastname').value.trim();
    const dateofbirth = document.getElementById('dateofbirth').value.trim();
    const gender = parseInt(document.getElementById('gender').value);
    const nationality = document.getElementById('nationality').value.trim();

    if (!firstname || !lastname || !dateofbirth) {
        alert('Bitte fuelle alle Pflichtfelder aus!');
        return;
    }

    fetch(`https://${GetParentResourceName()}/createCharacter`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            slot: currentSlot,
            firstname: firstname,
            lastname: lastname,
            dateofbirth: dateofbirth,
            gender: gender,
            nationality: nationality || 'Deutschland',
        })
    });

    cancelCreate();
}

function deleteCharacter(slot) {
    deleteSlot = slot;
    document.getElementById('delete-confirm').classList.remove('hidden');
}

function confirmDelete() {
    if (deleteSlot) {
        fetch(`https://${GetParentResourceName()}/deleteCharacter`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ slot: deleteSlot })
        });
    }
    cancelDelete();
}

function cancelDelete() {
    deleteSlot = null;
    document.getElementById('delete-confirm').classList.add('hidden');
}

function formatMoney(amount) {
    return amount.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.');
}

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        if (!document.getElementById('create-form').classList.contains('hidden')) {
            cancelCreate();
        }
        if (!document.getElementById('delete-confirm').classList.contains('hidden')) {
            cancelDelete();
        }
    }
});
