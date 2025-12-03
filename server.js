import express from 'express';
import fetch from 'node-fetch';
import cors from 'cors';
import { exec } from 'child_process';

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.static('public'));
app.set('view engine', 'ejs');

const HORIZON_URL = 'http://localhost:31401';

// ===== Helpers =====
function execCommand(cmd) {
    return new Promise((resolve) => {
        exec(cmd, (err, stdout, stderr) => {
            if (err) return resolve(stderr.trim() || 'Error');
            resolve(stdout.trim());
        });
    });
}

async function fetchHorizonInfo() {
    try {
        const res = await fetch(HORIZON_URL);
        const data = await res.json();
        return {
            horizonVersion: data.horizon_version || '-',
            coreVersion: data.core_version || '-',
            ingestLatestLedger: data.ingest_latest_ledger ?? 0,
            historyLatestLedger: data.history_latest_ledger ?? 0,
            historyLedgerClosedAt: data.history_latest_ledger_closed_at || '-',
            coreLatestLedger: data.core_latest_ledger ?? 0,
            networkPassphrase: data.network_passphrase || '-',
            currentProtocolVersion: data.current_protocol_version ?? 0,
            supportedProtocolVersion: data.supported_protocol_version ?? 0,
            coreSupportedProtocolVersion: data.core_supported_protocol_version ?? 0,
            peers: data.peers?.authenticated_count ?? 'N/A'
        };
    } catch (err) {
        console.error('Horizon fetch error:', err);
        return {
            horizonVersion: '-',
            coreVersion: '-',
            ingestLatestLedger: 0,
            historyLatestLedger: 0,
            historyLedgerClosedAt: '-',
            coreLatestLedger: 0,
            networkPassphrase: '-',
            currentProtocolVersion: 0,
            supportedProtocolVersion: 0,
            coreSupportedProtocolVersion: 0,
            peers: 'N/A'
        };
    }
}

// ===== Routes =====
app.get('/', (req, res) => {
    res.render('index');
});

app.get('/api/status', async (req, res) => {
    // Docker container status
    const dockerStatusRaw = await execCommand('docker ps --filter "name=mainnet" --format "{{.Status}}"');
    const containerStatus = dockerStatusRaw.includes('Up') ? 'Running ✅' : 'Stopped ❌';

    // Horizon + Core info
    const horizonInfo = await fetchHorizonInfo();

    const coreStatus = {
        state: horizonInfo.coreLatestLedger > 0 ? 'Synced ✅' : 'Error ❌',
        ledger: horizonInfo.coreLatestLedger,
        peers: horizonInfo.peers
    };

    const horizonStatus = {
        latestLedger: horizonInfo.coreLatestLedger,
        closedAt: horizonInfo.historyLedgerClosedAt
    };

    let syncProgress = 0;
    if (horizonStatus.latestLedger && coreStatus.ledger) {
        syncProgress = ((horizonStatus.latestLedger / coreStatus.ledger) * 100).toFixed(2);
    }

    res.json({
        containerStatus,
        coreStatus,
        horizonStatus,
        horizonInfo,
        syncProgress
    });
});

app.listen(PORT, () => console.log(`Pi Node Dashboard running at http://localhost:${PORT}`));
