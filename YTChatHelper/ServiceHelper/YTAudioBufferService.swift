//
//  YTAudioBufferService.swift
//  YTChatHelper
//
//  Created by ashika kalmady on 4/25/24.
//

import Foundation

struct YTconstant {
    static let apiKey = ""
    static let OpenapiKey = ""
}
struct ChatMessage: Codable {
    var role: String
    var content: String
}

struct ChatRequest: Codable {
    var model: String
    var messages: [ChatMessage]
}

struct ChatResponse: Codable {
    var id: String?
    var object: String?
    var created: Int?
    var model: String?
    var choices: [ChatChoice]?
    
    struct ChatChoice: Codable {
        var message: ChatMessage
    }
}

struct YTAudioBufferService {
    
    // custom local service created to get the transcript from Youtube URL , used assembly ai to generate the transcript
    func fetchAudioBuffer(videoUrl: String) async throws -> String? {
        guard let url = URL(string: "http://127.0.0.1:5001/transcribe") else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["video_url": videoUrl, "api_key": YTconstant.apiKey]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        // Make sure to pass 'request' instead of 'url' to the URLSession data task
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decodedResponse = try JSONDecoder().decode(AudioResponse.self, from: data)
        return decodedResponse.transcript
        
    }
    
    // Open api call to get chat response using chatgpt 3.5
    func chatWithGPT(query: String, transcript: String, apiKey: String) async -> String {
        let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let messages = [
            ChatMessage(role: "system", content: "You are a chatbot that responds based on the provided transcript."),
            ChatMessage(role: "assistant", content: transcript),
            ChatMessage(role: "user", content: query)
        ]
        let chatRequest = ChatRequest(model: "gpt-3.5-turbo", messages: messages)
        
        do {
            let requestData = try JSONEncoder().encode(chatRequest)
            request.httpBody = requestData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return "Failed to get valid response from server."
            }
            
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(ChatResponse.self, from: data)
            
            if let firstChoice = decodedResponse.choices?.first {
                return firstChoice.message.content
            } else {
                return "No response choice found."
            }
        } catch {
            print("Error during API request: \(error)")
            return "An error occurred. Please check the logs."
        }
    }

}

struct AudioResponse: Codable {
    var transcript: String?
}


