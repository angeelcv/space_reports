window.addEventListener('message', function (event) {
    if (event.data.action === 'openReportForm') {
        openSection('reportForm');
    } else if (event.data.action === 'openReportsList') {
        openSection('reportsList');
    } else if (event.data.action === 'populateReportsList') {
        populateReportsList(event.data.reports);
    } else if (event.data.action === 'showReportDetails') {
        showReportDetails(event.data.report);
    }
});

function openSection(sectionId) {
    document.getElementById('reportForm').style.display = 'none';
    document.getElementById('reportsList').style.display = 'none';
    document.getElementById('reportDetails').style.display = 'none';
    document.getElementById(sectionId).style.display = 'block';
}

function populateReportsList(reports) {
    const reportItems = document.getElementById('reportItems');
    reportItems.innerHTML = '';
    reports.forEach(report => {
        const listItem = document.createElement('li');
        listItem.innerHTML = `
            <strong>${report.title}</strong><br>
            <span style="font-size: 12px; color: #666;">Creador: ${report.cfxid} | Fecha: ${report.created_at}</span>
        `;
        listItem.addEventListener('click', () => {
            fetch(`https://${GetParentResourceName()}/getReportDetails`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ id: report.id })
            });
        });
        reportItems.appendChild(listItem);
    });
}



document.getElementById('closeReportsList').addEventListener('click', function () {
    closeNUI();
});

document.getElementById('submitReport').addEventListener('click', function () {
    const title = document.getElementById('reportTitle').value;
    const content = document.getElementById('reportContent').value;

    if (title.trim() === '' || content.trim() === '') {
        return;
    }

    fetch(`https://${GetParentResourceName()}/submitReport`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title, content })
    }).then(() => {
        document.getElementById('reportForm').style.display = 'none';
        fetch(`https://${GetParentResourceName()}/closeNUI`, { method: 'POST' });
    });
    closeNUI();
});

function fetchReports() {
    fetch(`https://${GetParentResourceName()}/getReports`, { method: 'POST' });
}

function closeNUI() {
    document.getElementById('reportForm').style.display = 'none';
    document.getElementById('reportsList').style.display = 'none';
    document.getElementById('reportDetails').style.display = 'none';
    fetch(`https://${GetParentResourceName()}/closeNUI`, { method: 'POST' });
}

document.getElementById('closeReportForm').addEventListener('click', function () {
    closeNUI();
});

document.getElementById('closeReportDetails').addEventListener('click', function () {
    closeNUI();
});

function showReportDetails(report) {
    document.getElementById('detailsTitle').textContent = report.title;
    document.getElementById('detailsTitle').setAttribute('data-id', report.id);
    document.getElementById('detailsContent').textContent = report.content;
    document.getElementById('detailsPlayerInfo').innerHTML = `
        <p><strong>Nombre IC:</strong> ${report.icname}</p>
        <p><strong>Nombre Discord:</strong> ${report.discord}</p>
        <p><strong>Nombre Steam:</strong> ${report.steamname}</p>
        <p><strong>ID (source):</strong> ${report.source}</p>
    `;
    document.getElementById('detailsDate').textContent = report.created_at;
    openSection('reportDetails');
}


document.getElementById('backToReports').addEventListener('click', function () {
    openSection('reportsList');
});

document.getElementById('deleteReport').addEventListener('click', function () {
    const reportId = document.getElementById('detailsTitle').getAttribute('data-id'); 
    fetch(`https://${GetParentResourceName()}/deleteReport`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: reportId })
    }).then(() => {
        fetchReports(); 
        openSection('reportsList'); 
    });
});


document.getElementById('revivePlayer').addEventListener('click', function () {
    const reportId = document.getElementById('detailsTitle').dataset.id;
    fetch(`https://${GetParentResourceName()}/revivePlayer`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: reportId })
    }).then(() => {
    });
});

document.getElementById('openPedMenu').addEventListener('click', function () {
    const reportId = document.getElementById('detailsTitle').dataset.id;
    fetch(`https://${GetParentResourceName()}/openPedMenu`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: reportId })
    }).then(() => {
    });
});
