# server.py
import asyncio, logging, os, time, fractions
import cv2, numpy as np
from aiohttp import web
from aiortc import RTCPeerConnection, RTCSessionDescription, MediaStreamTrack
from aiortc.contrib.media import MediaRecorder
from av import VideoFrame

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("server")

# ❗ Adjust camera index or video source as needed
cap = cv2.VideoCapture(0)
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
cap.set(cv2.CAP_PROP_FPS, 30)

class CameraTrack(MediaStreamTrack):
    kind = "video"

    def __init__(self):
        super().__init__()
        self.counter = 0

    async def recv(self):
        ret, frame = cap.read()
        if not ret:
            # send a black frame if camera fails
            frame = np.zeros((480, 640, 3), np.uint8)

        self.counter += 1
        video_frame = VideoFrame.from_ndarray(frame, format="bgr24")
        video_frame.pts = self.counter
        video_frame.time_base = fractions.Fraction(1, 30)
        return video_frame

pcs = set()

async def index(request):
    return web.FileResponse(os.path.join('templates', 'index.html'))

async def client_js(request):
    return web.FileResponse(os.path.join('templates', 'client.js'))

async def offer(request):
    params = await request.json()
    logger.info("Received offer")

    pc = RTCPeerConnection()
    pcs.add(pc)

    @pc.on("iceconnectionstatechange")
    async def on_ice():
        logger.info("ICE state: %s", pc.iceConnectionState)
        if pc.iceConnectionState == "failed":
            await pc.close()
            pcs.discard(pc)

    await pc.setRemoteDescription(RTCSessionDescription(**params))
    pc.addTrack(CameraTrack())

    answer = await pc.createAnswer()
    await pc.setLocalDescription(answer)

    return web.json_response({
        "sdp": pc.localDescription.sdp,
        "type": pc.localDescription.type
    })

async def cleanup():
    await asyncio.sleep(3600)  # auto stop after 1 hr
    for pc in pcs:
        await pc.close()
    cap.release()

def main():
    app = web.Application()
    app.router.add_get('/', index)
    app.router.add_get('/client.js', client_js)
    app.router.add_post('/offer', offer)

    loop = asyncio.get_event_loop()
    loop.create_task(cleanup())
    web.run_app(app, port=8080)

if __name__ == '__main__':
    main()
