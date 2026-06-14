window.addEventListener('message', function(event) {
    const d = event.data;
    if (d.action === 'openBank') {
        document.getElementById('bank-container').classList.remove('hidden');
        document.getElementById('account-nr').textContent = d.accountNumber;
        updateBalances(d.cash, d.bank);
        renderTransactions(d.transactions);
    }
    if (d.action === 'closeBank') {
        document.getElementById('bank-container').classList.add('hidden');
    }
    if (d.action === 'refreshBank') {
        updateBalances(d.cash, d.bank);
        renderTransactions(d.transactions);
    }
});

function updateBalances(cash, bank) {
    document.getElementById('bank-balance').textContent = '$' + formatMoney(bank);
    document.getElementById('cash-balance').textContent = '$' + formatMoney(cash);
}

function switchTab(tab) {
    document.querySelectorAll('.tab-content').forEach(el => el.classList.add('hidden'));
    document.querySelectorAll('.tab').forEach(el => el.classList.remove('active'));
    document.getElementById('tab-' + tab).classList.remove('hidden');
    event.target.classList.add('active');
}

function doDeposit() {
    const amount = parseInt(document.getElementById('deposit-amount').value);
    if (!amount || amount <= 0) return;
    fetch(`https://${GetParentResourceName()}/deposit`, {
        method: 'POST', body: JSON.stringify({ amount: amount })
    });
    document.getElementById('deposit-amount').value = '';
}

function doWithdraw() {
    const amount = parseInt(document.getElementById('withdraw-amount').value);
    if (!amount || amount <= 0) return;
    fetch(`https://${GetParentResourceName()}/withdraw`, {
        method: 'POST', body: JSON.stringify({ amount: amount })
    });
    document.getElementById('withdraw-amount').value = '';
}

function doTransfer() {
    const account = document.getElementById('transfer-account').value.trim();
    const amount = parseInt(document.getElementById('transfer-amount').value);
    if (!account || !amount || amount <= 0) return;
    fetch(`https://${GetParentResourceName()}/transfer`, {
        method: 'POST', body: JSON.stringify({ targetAccount: account, amount: amount })
    });
    document.getElementById('transfer-account').value = '';
    document.getElementById('transfer-amount').value = '';
}

function closeBank() {
    fetch(`https://${GetParentResourceName()}/closeBank`, { method: 'POST', body: '{}' });
}

function renderTransactions(transactions) {
    const list = document.getElementById('transaction-list');
    list.innerHTML = '';
    if (!transactions || transactions.length === 0) {
        list.innerHTML = '<p style="text-align:center;color:#555;padding:20px;">Keine Transaktionen</p>';
        return;
    }
    const typeLabels = {
        deposit: 'Einzahlung', withdraw: 'Abhebung',
        transfer_in: 'Eingang', transfer_out: 'Ausgang',
        salary: 'Gehalt', purchase: 'Kauf', fine: 'Bussgeld'
    };
    transactions.forEach(t => {
        const isPositive = ['deposit', 'transfer_in', 'salary'].includes(t.type);
        const div = document.createElement('div');
        div.className = 'transaction';
        div.innerHTML = `
            <div class="trans-info">
                <div class="trans-type">${typeLabels[t.type] || t.type}</div>
                <div class="trans-desc">${t.description || ''}</div>
                <div class="trans-date">${t.created_at || ''}</div>
            </div>
            <div class="trans-amount ${isPositive ? 'positive' : 'negative'}">
                ${isPositive ? '+' : '-'}$${formatMoney(t.amount)}
            </div>
        `;
        list.appendChild(div);
    });
}

function formatMoney(n) { return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.'); }

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeBank();
});
