import asyncio
import cv2
import numpy as np
from aiohttp import web
import logging
import time
import json
import aiortc
from aiortc import MediaStreamTrack, RTCPeerConnection, RTCSessionDescription
from aiortc.contrib.media import MediaBlackhole, MediaPlayer, MediaRecorder
from av import VideoFrame
import fractions

logger = logging.getLogger(__name__)

class VideoStreamTrack(MediaStreamTrack):
    kind = "video"

    def __init__(self, frame_queue):
        super().__init__()
        self.frame_queue = frame_queue
        self.frame_count = 0
        self.start_time = time.time()

    async def recv(self):
        if not self.frame_queue.empty():
            frame = self.frame_queue.get_nowait()
            self.frame_count += 1
            
            # Convert frame to VideoFrame
            video_frame = VideoFrame.from_ndarray(frame, format="bgr24")
            video_frame.pts = self.frame_count
            video_frame.time_base = fractions.Fraction(1, 30)
            
            return video_frame
        else:
            # If no frame is available, return a black frame
            black_frame = np.zeros((480, 640, 3), dtype=np.uint8)
            video_frame = VideoFrame.from_ndarray(black_frame, format="bgr24")
            video_frame.pts = self.frame_count
            video_frame.time_base = fractions.Fraction(1, 30)
            return video_frame

class WebRTCStreamer:
    def __init__(self, frame_queue):
        self.frame_queue = frame_queue
        self.app = web.Application()
        self.app.router.add_get("/", self.index)
        self.app.router.add_get("/client.js", self.javascript)
        self.app.router.add_post("/offer", self.offer)
        self.pcs = set()
        logger.info("WebRTCStreamer initialized")

    async def index(self, request):
        content = open("templates/index.html", "r").read()
        return web.Response(content_type="text/html", text=content)

    async def javascript(self, request):
        content = open("templates/client.js", "r").read()
        return web.Response(content_type="application/javascript", text=content)

    async def offer(self, request):
        try:
            params = await request.json()
            logger.info(f"Received offer: {params}")
            
            offer = RTCSessionDescription(
                sdp=params["sdp"],
                type=params["type"]
            )

            pc = RTCPeerConnection()
            self.pcs.add(pc)

            @pc.on("connectionstatechange")
            async def on_connectionstatechange():
                logger.info(f"Connection state changed: {pc.connectionState}")
                if pc.connectionState == "failed":
                    await pc.close()
                    self.pcs.discard(pc)

            @pc.on("iceconnectionstatechange")
            async def on_iceconnectionstatechange():
                logger.info(f"ICE connection state changed: {pc.iceConnectionState}")
                if pc.iceConnectionState == "failed":
                    await pc.close()
                    self.pcs.discard(pc)

            # Add video track
            video_track = VideoStreamTrack(self.frame_queue)
            pc.addTrack(video_track)

            # Handle the offer
            await pc.setRemoteDescription(offer)
            answer = await pc.createAnswer()
            await pc.setLocalDescription(answer)

            response_data = {
                "sdp": pc.localDescription.sdp,
                "type": pc.localDescription.type
            }
            logger.info(f"Sending answer: {response_data}")
            return web.json_response(response_data)
            
        except Exception as e:
            logger.error(f"Error handling offer: {str(e)}")
            return web.json_response({
                "error": str(e)
            }, status=500)

    def run(self, host="0.0.0.0", port=8080):
        logger.info(f"Starting WebRTC server at http://{host}:{port}")
        web.run_app(self.app, host=host, port=port) 