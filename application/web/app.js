// Manifold Edge Remover — client-side JS

(function () {
  'use strict';

  var logEl = document.getElementById('log');
  var selectedFile = '';

  // -----------------------------------------------------------------------
  // File selection — sends request to Novus
  // -----------------------------------------------------------------------
  window.selectFile = function () {
    if (typeof novusSend === 'function') {
      novusSend('CMD:SELECT_FILE');
      appendLog('progress', 'Requesting file selection...');
    } else {
      appendLog('error', 'novusSend not available');
    }
  };

  // -----------------------------------------------------------------------
  // Process — sends request to Novus
  // -----------------------------------------------------------------------
  window.processFile = function () {
    if (!selectedFile) return;
    var btn = document.getElementById('process-btn');
    btn.disabled = true;
    btn.textContent = 'Processing...';

    document.getElementById('progress-container').style.display = 'block';
    document.getElementById('result-section').style.display = 'none';
    updateProgress(0, 'Starting...');

    if (typeof novusSend === 'function') {
      novusSend('CMD:PROCESS:' + selectedFile);
      appendLog('progress', 'Starting STL processing...');
    }
  };

  // -----------------------------------------------------------------------
  // Update UI functions
  // -----------------------------------------------------------------------
  function updateProgress(pct, msg) {
    document.getElementById('progress-fill').style.width = pct + '%';
    document.getElementById('progress-text').textContent = pct + '% — ' + msg;
  }

  function setFileSelected(path) {
    selectedFile = path;
    // Extract filename from path
    var name = path.split('/').pop();
    document.getElementById('file-name').textContent = name;
    document.getElementById('file-name').style.color = '#2cb67d';
    document.getElementById('process-btn').disabled = false;
    appendLog('progress', 'Selected: ' + name);
  }

  function showResult(status, outputPath, origVerts, origFaces, fixedVerts, fixedFaces) {
    var section = document.getElementById('result-section');
    var content = document.getElementById('result-content');
    section.style.display = 'block';

    var statusClass = 'success';
    var statusText = 'Mesh is watertight and ready for 3D printing!';
    if (status.indexOf('PARTIAL') === 0) {
      statusClass = 'partial';
      statusText = 'Mesh improved but may still have minor issues.';
    } else if (status.indexOf('ERROR') === 0) {
      statusClass = 'error';
      statusText = status;
    }

    var fileName = outputPath.split('/').pop();
    content.innerHTML =
      '<p class="' + statusClass + '">' + escapeHtml(statusText) + '</p>' +
      '<p class="detail">Saved to: ' + escapeHtml(fileName) + '</p>' +
      '<p class="detail">Original: ' + origVerts + ' vertices, ' + origFaces + ' faces</p>' +
      '<p class="detail">Fixed: ' + fixedVerts + ' vertices, ' + fixedFaces + ' faces</p>';

    // Re-enable buttons
    document.getElementById('process-btn').disabled = false;
    document.getElementById('process-btn').textContent = 'Fix Manifold Edges';
    updateProgress(100, 'Complete!');
  }

  // -----------------------------------------------------------------------
  // Receive messages from Novus
  // -----------------------------------------------------------------------
  if (typeof novusOnMessage === 'function') {
    novusOnMessage(function (msg) {
      if (msg.indexOf('FILE_SELECTED:') === 0) {
        var path = msg.substring(14);
        setFileSelected(path);
      } else if (msg.indexOf('PROGRESS:') === 0) {
        // PROGRESS:<pct>:<message>
        var parts = msg.substring(9).split(':');
        var pct = parseInt(parts[0], 10) || 0;
        var pmsg = parts.slice(1).join(':');
        updateProgress(pct, pmsg);
        appendLog('progress', '[' + pct + '%] ' + pmsg);
      } else if (msg.indexOf('RESULT:') === 0) {
        // RESULT:<status>:<path>:<ov>:<of>:<fv>:<ff>
        var rparts = msg.substring(7).split(':');
        var status = rparts[0] || 'OK';
        var opath = rparts[1] || '';
        var ov = rparts[2] || '0';
        var of_ = rparts[3] || '0';
        var fv = rparts[4] || '0';
        var ff = rparts[5] || '0';
        showResult(status, opath, ov, of_, fv, ff);
        appendLog('result', 'Done: ' + status);
      } else if (msg.indexOf('ERROR:') === 0) {
        appendLog('error', msg.substring(6));
        document.getElementById('process-btn').disabled = false;
        document.getElementById('process-btn').textContent = 'Fix Manifold Edges';
      } else {
        appendLog('progress', msg);
      }
    });
  }

  // -----------------------------------------------------------------------
  // Log helper
  // -----------------------------------------------------------------------
  function appendLog(type, text) {
    var entry = document.createElement('div');
    entry.className = 'log-entry ' + type;
    entry.textContent = text;
    logEl.appendChild(entry);
    logEl.scrollTop = logEl.scrollHeight;
  }

  function escapeHtml(s) {
    var div = document.createElement('div');
    div.textContent = s;
    return div.innerHTML;
  }

  // Send initial ready signal
  setTimeout(function () {
    if (typeof novusSend === 'function') {
      novusSend('READY');
    }
  }, 300);
})();
