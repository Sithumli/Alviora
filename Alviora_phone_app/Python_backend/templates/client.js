const video = document.getElementById('video');
const statusDiv = document.getElementById('status');
let pc = null;
let retryCount = 0;
const MAX_RETRIES = 3;
const RETRY_DELAY = 2000; // 2 seconds

async function startSession() {
  if (pc) {
    pc.close();
    pc = null;
  }

  pc = new RTCPeerConnection({
    iceServers: [
      { urls: 'stun:stun.l.google.com:19302' },
      { urls: 'stun:stun1.l.google.com:19302' },
      { urls: 'stun:stun2.l.google.com:19302' }
    ]
  });

  pc.onicecandidate = e => {
    if (e.candidate) {
      console.log('New ICE candidate:', e.candidate);
    }
  };

  pc.onconnectionstatechange = () => {
    statusDiv.textContent = 'Connection State: ' + pc.connectionState;
    if (pc.connectionState === 'failed' || pc.connectionState === 'disconnected') {
      handleConnectionFailure();
    }
  };

  pc.oniceconnectionstatechange = () => {
    console.log('ICE state:', pc.iceConnectionState);
    if (pc.iceConnectionState === 'failed') {
      handleConnectionFailure();
    }
  };

  pc.ontrack = e => {
    console.log('Received track:', e.track.kind);
    if (e.streams && e.streams[0]) {
      video.srcObject = e.streams[0];
      retryCount = 0; // Reset retry count on successful connection
    }
  };

  try {
    const offer = await pc.createOffer({ offerToReceiveVideo: true });
    await pc.setLocalDescription(offer);

    const resp = await fetch('/offer', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(pc.localDescription)
    });

    if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
    
    const answer = await resp.json();
    if (answer.error) throw new Error(answer.error);

    await pc.setRemoteDescription(answer);
  } catch (err) {
    console.error(err);
    statusDiv.textContent = 'Error: ' + err.message;
    handleConnectionFailure();
  }
}

function handleConnectionFailure() {
  if (retryCount < MAX_RETRIES) {
    retryCount++;
    statusDiv.textContent = `Connection failed. Retrying (${retryCount}/${MAX_RETRIES})...`;
    setTimeout(startSession, RETRY_DELAY);
  } else {
    statusDiv.textContent = 'Connection failed after multiple attempts. Please refresh the page.';
  }
}

// Start the session when the page loads
window.addEventListener('load', startSession);

// Add a manual refresh button
const refreshButton = document.createElement('button');
refreshButton.textContent = 'Refresh Stream';
refreshButton.style.position = 'fixed';
refreshButton.style.bottom = '20px';
refreshButton.style.right = '20px';
refreshButton.style.padding = '10px 20px';
refreshButton.style.backgroundColor = '#007bff';
refreshButton.style.color = 'white';
refreshButton.style.border = 'none';
refreshButton.style.borderRadius = '5px';
refreshButton.style.cursor = 'pointer';
refreshButton.onclick = () => {
  retryCount = 0;
  startSession();
};
document.body.appendChild(refreshButton);
