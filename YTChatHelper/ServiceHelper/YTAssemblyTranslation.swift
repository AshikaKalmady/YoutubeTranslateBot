//
//  YTAssemblyTranslation.swift
//  YTChatHelper
//
//  Created by ashika kalmady on 4/25/24.
//

import Foundation



struct AssemblyAIResponse: Codable {
    let upload_url: String
}

struct TranscriptRequest: Codable {
    let audio_url: String
}

struct TranscriptResponse: Codable {
    let id: String
    let text: String?
    let status: String
}

func uploadAudioAndTranscribe(audioData: Data) async throws -> String? {
    let uploadURL = URL(string: "https://api.assemblyai.com/v2/upload")!
    var request = URLRequest(url: uploadURL)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(YTconstant.apiKey)", forHTTPHeaderField: "Authorization")

    // Notice the absence of request.httpBody = audioData

    // Properly using the upload method
    let (data, _) = try await URLSession.shared.upload(for: request, from: audioData)
    let decoder = JSONDecoder()
    if let uploadResponse = try? decoder.decode(AssemblyAIResponse.self, from: data) {
        return await requestTranscription(audioURL: uploadResponse.upload_url, apiKey: YTconstant.apiKey)
    } else {
        print("Failed to decode upload response")
        return nil
    }
}

func requestTranscription(audioURL: String, apiKey: String) async -> String? {
    let transcriptionURL = URL(string: "https://api.assemblyai.com/v2/transcript")!
    var request = URLRequest(url: transcriptionURL)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    
    let encoder = JSONEncoder()
    guard let requestData = try? encoder.encode(TranscriptRequest(audio_url: audioURL)) else { return nil }
    request.httpBody = requestData

    do {
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        if let transcriptResponse = try? decoder.decode(TranscriptResponse.self, from: data),
           transcriptResponse.status == "completed" {
            return transcriptResponse.text
        } else {
            print("Failed to complete transcription")
            return nil
        }
    } catch {
        print("Error during transcription request: \(error.localizedDescription)")
        return nil
    }
}


// Example usage



