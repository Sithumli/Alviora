import subprocess

def start_ffmpeg_stream():
    ffmpeg_path = r'C:\ffmpeg\bin\ffmpeg.exe'
    video_device = 'video="USB2.0 HD UVC WebCam"'
    audio_device = 'audio="Microphone Array (Realtek(R) Audio)"'
    
    device_input = f'{video_device}:{audio_device}'

    cmd = [
        ffmpeg_path,
        '-f', 'dshow',
        '-i', device_input,
        '-f', 'mpegts',
        'http://localhost:8090/feed.ts'
    ]

    print("Running command:", ' '.join(cmd))

    process = subprocess.Popen(cmd)
    print("Streaming started. Press Ctrl+C to stop.")

    try:
        process.wait()
    except KeyboardInterrupt:
        print("Stopping stream...")
        process.terminate()
        process.wait()
        print("Stream stopped.")

if __name__ == "__main__":
    start_ffmpeg_stream()
