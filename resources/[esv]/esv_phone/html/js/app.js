let phoneData = {};
let myNumber = '';

window.addEventListener('message', function(event) {
    const d = event.data;
    if (d.action === 'openPhone') {
        document.getElementById('phone-container').classList.remove('hidden');
        myNumber = d.phoneNumber || '';
        document.getElementById('phone-number').textContent = myNumber;
        updateTime();
        renderContacts(d.contacts);
        renderMessages(d.messages);
    }
    if (d.action === 'closePhone') {
        document.getElementById('phone-container').classList.add('hidden');
    }
    if (d.action === 'refreshPhone') {
        renderContacts(d.contacts);
        renderMessages(d.messages);
    }
});

function updateTime() {
    const now = new Date();
    document.getElementById('phone-time').textContent =
        now.getHours().toString().padStart(2, '0') + ':' + now.getMinutes().toString().padStart(2, '0');
}

function switchPhoneTab(tab, btn) {
    document.querySelectorAll('.phone-page').forEach(p => p.classList.add('hidden'));
    document.querySelectorAll('.phone-tab').forEach(t => t.classList.remove('active'));
    document.getElementById('tab-' + tab).classList.remove('hidden');
    btn.classList.add('active');
}

function dialBtn(num) { document.getElementById('dial-number').value += num; }
function dialClear() {
    const el = document.getElementById('dial-number');
    el.value = el.value.slice(0, -1);
}

function makeCall() {
    const number = document.getElementById('dial-number').value.trim();
    if (!number) return;
    fetch(`https://${GetParentResourceName()}/makeCall`, { method: 'POST', body: JSON.stringify({ number }) });
}

function renderContacts(contacts) {
    const list = document.getElementById('contacts-list');
    list.innerHTML = '';
    (contacts || []).forEach(c => {
        list.innerHTML += `<div class="contact-item">
            <div><div class="contact-name">${c.name}</div><div class="contact-number">${c.number}</div></div>
            <div class="contact-actions">
                <button onclick="document.getElementById('dial-number').value='${c.number}';switchPhoneTab('dial',document.querySelectorAll('.phone-tab')[0])"><i class="fas fa-phone"></i></button>
                <button onclick="deleteContact(${c.id})"><i class="fas fa-trash"></i></button>
            </div>
        </div>`;
    });
}

function renderMessages(messages) {
    const list = document.getElementById('messages-list');
    list.innerHTML = '';
    (messages || []).forEach(m => {
        const isSent = m.sender_number === myNumber;
        list.innerHTML += `<div class="msg-item ${isSent ? 'sent' : 'received'}">
            <div>${m.message}</div>
            <div class="msg-meta">${isSent ? 'An: ' + m.receiver_number : 'Von: ' + m.sender_number} | ${m.created_at || ''}</div>
        </div>`;
    });
}

function showAddContact() {
    document.getElementById('add-contact-form').classList.toggle('hidden');
}

function addContact() {
    const name = document.getElementById('contact-name').value.trim();
    const number = document.getElementById('contact-number').value.trim();
    if (!name || !number) return;
    fetch(`https://${GetParentResourceName()}/addContact`, { method: 'POST', body: JSON.stringify({ name, number }) });
    document.getElementById('contact-name').value = '';
    document.getElementById('contact-number').value = '';
    document.getElementById('add-contact-form').classList.add('hidden');
}

function deleteContact(id) {
    fetch(`https://${GetParentResourceName()}/deleteContact`, { method: 'POST', body: JSON.stringify({ id }) });
}

function sendMessage() {
    const number = document.getElementById('msg-number').value.trim();
    const message = document.getElementById('msg-text').value.trim();
    if (!number || !message) return;
    fetch(`https://${GetParentResourceName()}/sendMessage`, { method: 'POST', body: JSON.stringify({ number, message }) });
    document.getElementById('msg-text').value = '';
}

function call911() {
    const type = document.getElementById('emergency-type').value;
    const message = document.getElementById('emergency-msg').value.trim();
    if (!message) return;
    fetch(`https://${GetParentResourceName()}/call911`, { method: 'POST', body: JSON.stringify({ type, message }) });
    document.getElementById('emergency-msg').value = '';
}

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/closePhone`, { method: 'POST', body: '{}' });
    }
});
