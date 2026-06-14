const icons = {
    success: 'fa-check-circle',
    error: 'fa-times-circle',
    info: 'fa-info-circle',
    warning: 'fa-exclamation-triangle',
    police: 'fa-shield-alt',
    ems: 'fa-heartbeat',
};

window.addEventListener('message', function(event) {
    const data = event.data;
    if (data.action === 'notify') {
        createNotification(data.type, data.message, data.duration);
    }
});

function createNotification(type, message, duration) {
    const container = document.getElementById('notification-container');
    const notif = document.createElement('div');
    notif.className = 'notification ' + (type || 'info');

    const icon = icons[type] || icons.info;
    notif.innerHTML = `<i class="fas ${icon}"></i><span>${message}</span>`;

    container.appendChild(notif);

    setTimeout(function() {
        notif.classList.add('removing');
        setTimeout(function() {
            notif.remove();
        }, 300);
    }, duration || 5000);
}
