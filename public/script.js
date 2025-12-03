let ledgerChart;
let syncGauge;

async function loadStatus() {
    const res = await fetch('/api/status');
    const data = await res.json();

    // LED helper
    const led = (state) => {
        if (state.includes("Running") || state.includes("Synced"))
            return "<span class='led led-green'></span>";
        return "<span class='led led-red'></span>";
    };

    document.getElementById("docker").innerHTML = led(data.containerStatus) + data.containerStatus;
    document.getElementById("core").innerHTML   = led(data.coreStatus.state) + data.coreStatus.state;

    document.getElementById("ledger").innerText = data.coreStatus.ledger;
    document.getElementById("peers").innerText = data.coreStatus.peers;

    // Info block
    document.getElementById("info").innerHTML = `
        Horizon Version: ${data.horizonInfo.horizonVersion}<br>
        Core Version: ${data.horizonInfo.coreVersion}<br>
        Latest Ledger: ${data.horizonInfo.coreLatestLedger}<br>
        History Ledger Closed At: ${data.horizonInfo.historyLedgerClosedAt}<br>
        Network: ${data.horizonInfo.networkPassphrase}<br>
        Protocol: ${data.horizonInfo.currentProtocolVersion}
    `;

    updateCharts(data);
}

function updateCharts(data) {
    const ledger = data.coreStatus.ledger;
    const sync = parseFloat(data.syncProgress);

    // Ledger line chart init/update
    if (!ledgerChart) {
        ledgerChart = new Chart(document.getElementById("ledgerChart"), {
            type: 'line',
            data: {
                labels: [],
                datasets: [{
                    label: "Ledger",
                    data: [],
                    borderColor: "#4c8dff",
                    borderWidth: 2
                }]
            },
            options: { animation: false }
        });
    }

    ledgerChart.data.labels.push("");
    ledgerChart.data.datasets[0].data.push(ledger);
    ledgerChart.update();

    // Gauge chart init/update
    if (!syncGauge) {
        syncGauge = new Chart(document.getElementById("syncGauge"), {
            type: "doughnut",
            data: {
                datasets: [{
                    data: [sync, 100 - sync],
                    backgroundColor: ["#22c55e", "#1e293b"],
                    borderWidth: 0
                }]
            },
            options: {
                cutout: "75%",
                plugins: { tooltip: { enabled: false } }
            }
        });
    } else {
        syncGauge.data.datasets[0].data = [sync, 100 - sync];
        syncGauge.update();
    }
}

// Auto refresh every 3 seconds
setInterval(loadStatus, 3000);
loadStatus();
