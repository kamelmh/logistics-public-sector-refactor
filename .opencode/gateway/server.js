const express = require('express');
const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');

const app = express();
const port = 3000;

app.use(express.static('public'));
app.use(express.json());

const PROJECT_ROOT = path.join(__dirname, '..', '..');

const ACTIONS = {
    'build-erp': { 
        cmd: 'powershell -File .\\Software_Surgical_Edit\\build.ps1', 
        label: 'Build ERP Workbook' 
    },
    'verify-erp': { 
        cmd: 'powershell -File .\\Software_Surgical_Edit\\verify.ps1', 
        label: 'Verify ERP (174 checks)' 
    },
    'build-thesis': { 
        cmd: 'powershell -File .\\Thesis_Surgical_Edit\\build-thesis.ps1', 
        label: 'Build Thesis PDF' 
    },
    'git-status': { 
        cmd: 'git status', 
        label: 'Git Status' 
    }
};

app.get('/api/actions', (req, res) => {
    res.json(ACTIONS);
});

app.get('/api/canvas', (req, res) => {
    const canvasPath = path.join(__dirname, '..', '..', '.opencode', 'canvas', 'thesis_map.mmd');
    if (fs.existsSync(canvasPath)) {
        res.sendFile(canvasPath);
    } else {
        res.status(404).send('Canvas map not found');
    }
});

app.post('/api/execute', (req, res) => {
    const { actionId } = req.body;
    const action = ACTIONS[actionId];

    if (!action) {
        return res.status(400).json({ error: 'Invalid action' });
    }

    console.log(`Executing ${action.label}...`);
    
    exec(action.cmd, { cwd: PROJECT_ROOT }, (error, stdout, stderr) => {
        res.json({
            success: !error,
            stdout: stdout || '',
            stderr: stderr || '',
            error: error ? error.message : null
        });
    });
});

app.listen(port, () => {
    console.log(`OpenCode Gateway running at http://localhost:${port}`);
});
