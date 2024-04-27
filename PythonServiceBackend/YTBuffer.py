from flask import Flask, request, jsonify
import io
import base64
import requests
from pytube import YouTube

app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, World!'

def get_audio_transcript(video_url, assemblyai_api_key):
    yt = YouTube(video_url)
    stream = yt.streams.filter(only_audio=True).first()
    
    if stream:
        buffer = io.BytesIO()
        stream.stream_to_buffer(buffer)
        buffer.seek(0) 

        headers = {
            'authorization': assemblyai_api_key,
            'content-type': 'application/json'
        }
        
        response = requests.post('https://api.assemblyai.com/v2/upload', headers=headers, data=buffer.read())
        if response.status_code != 200:
            return None, "Failed to upload audio for transcription."

        audio_url = response.json()['upload_url']
        
        json = {"audio_url": audio_url}
        transcription_response = requests.post('https://api.assemblyai.com/v2/transcript', json=json, headers=headers)
        if transcription_response.status_code != 200:
            return None, "Failed to initiate transcription."

        transcript_id = transcription_response.json()['id']
        
        while True:
            check_response = requests.get(f'https://api.assemblyai.com/v2/transcript/{transcript_id}', headers=headers)
            if check_response.status_code != 200:
                return None, "Failed to get transcription status."
                
            status = check_response.json()['status']
            if status == 'completed':
                return check_response.json()['text'], None
            elif status == 'failed':
                return None, 'Transcription failed.'
    else:
        return None, 'Failed to stream audio.'

@app.route('/transcribe', methods=['POST'])
def transcribe_audio():
    data = request.get_json()
    video_url = data.get('video_url')
    assemblyai_api_key = data.get('api_key')
    if not video_url or not assemblyai_api_key:
        return jsonify({'error': 'Missing video URL or AssemblyAI API key'}), 400

    transcript, error = get_audio_transcript(video_url, assemblyai_api_key)
    if error:
        return jsonify({'error': error}), 500

    return jsonify({'transcript': transcript})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)

# if __name__ == '__main__':
#     app.run(debug=True)
