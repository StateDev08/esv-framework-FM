window.addEventListener('message', function(event) {
    const d = event.data;
    if (d.action === 'openScoreboard') {
        document.getElementById('scoreboard').classList.remove('hidden');
        document.getElementById('sb-title').textContent = d.serverName || 'ESV HARDCORE RP';
        document.getElementById('sb-count').textContent = d.players.length + '/' + d.maxPlayers;
        const list = document.getElementById('sb-list');
        list.innerHTML = '';
        d.players.sort((a, b) => a.id - b.id).forEach(p => {
            list.innerHTML += `<div class="sb-row">
                <span class="id">${p.id}</span>
                <span class="name">${p.name}</span>
                <span class="job">${p.job}</span>
                <span class="ping">${p.ping}ms</span>
            </div>`;
        });
    }
    if (d.action === 'closeScoreboard') {
        document.getElementById('scoreboard').classList.add('hidden');
    }
});
