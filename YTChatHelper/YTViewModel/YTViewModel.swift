//
//  YTViewModel.swift
//  YTChatHelper
//
//  Created by ashika kalmady on 4/27/24.
//

import Foundation

enum ChatState {
    case initial
    case waitingForVideoURL
    case processingVideo
    case readyForQuery
    case displayingResponse(String) // Store the response
}


struct ChatMessages: Identifiable {
    var id = UUID()
    var content: String
    var isUser: Bool // True for user messages, false for bot messages
}


@MainActor
class YTViewModel: ObservableObject {
    @Published var messages: [ChatMessages] = []
    @Published var currentInput: String = ""
    @Published var showActionButtons: Bool = false
    
    private var questionCount = 0
    private var transcript: String = ""
    private var videoUrl: String = ""
    private var queryText: String = ""
    
    @Published var chatState: ChatState = .initial
    
    init() {
        resetChat()
    }
    
    func resetChat() {
        messages.append(ChatMessages(content: "Welcome to the YT Transcript Assistant!", isUser: false))
        messages.append(ChatMessages(content: "Please enter the YouTube video URL:", isUser: false))
        chatState = .waitingForVideoURL
    }
    
    
    func processInput() async {
        guard !currentInput.isEmpty else {
            return
        }
        switch chatState {
        case .waitingForVideoURL:
            videoUrl = currentInput
            currentInput = ""
            messages.append(ChatMessages(content: videoUrl, isUser: true))
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            messages.append(ChatMessages(content: "Processing video...", isUser: false))
            chatState = .processingVideo
            await fetchTranscript()
        case .readyForQuery:
            queryText = currentInput
            currentInput = ""
            messages.append(ChatMessages(content: queryText, isUser: true))
            questionCount += 1
            if questionCount % 2 == 0 { // Every 3 questions, offer more/new video options
                showActionButtons = true
            } else {
                
                showActionButtons = false
            }
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
            await fetchChatResponse()
        default:
            break
        }
    }
    
    func fetchTranscript() async {
        if let transcript = try? await YTAudioBufferService().fetchAudioBuffer(videoUrl: videoUrl) {
            self.transcript = transcript
            messages.append(ChatMessages(content: "Video processed. Please ask your queries now.", isUser: false))
            chatState = .readyForQuery
        } else {
            messages.append(ChatMessages(content: "Failed to process video.", isUser: false))
            resetChat()
        }
    }
    
    func fetchChatResponse() async {
       
        let response = await YTAudioBufferService().chatWithGPT(query: queryText, transcript: transcript, apiKey: YTconstant.OpenapiKey)
        messages.append(ChatMessages(content: "\(response)", isUser: false))
       
        
    }
    
    func handleMoreQuestions() {
           showActionButtons = false
           messages.append(ChatMessages(content: "Please continue with your questions.", isUser: false))
       }

       func handleNewVideo() {
           resetChat()
       }
}
