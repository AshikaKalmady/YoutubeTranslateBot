//
//  ContentView.swift
//  YTChatHelper
//
//  Created by ashika kalmady on 4/25/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = YTViewModel()
    
    var body: some View {
        VStack {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    ForEach(viewModel.messages) { msg in
                        ChatMessageView(message: msg)
                            .id(msg.id)
                    }
                }
                .onChange(of: viewModel.messages.count) { oldValue, newValue in
                    scrollToBottom(using: scrollProxy)
                }
                
            }
            
            // Text field and send button
            HStack {
                ChatTextField(text: $viewModel.currentInput, onCommit: {
                    Task { await viewModel.processInput() }
                })
                
                ChatSendButton {
                    Task { await viewModel.processInput() }
                }
            }
            
            if viewModel.showActionButtons {
                actionButtons
            }
        }
        .padding()
    }
    
    private func scrollToBottom(using proxy: ScrollViewProxy) {
        if let lastMessage = viewModel.messages.last {
            withAnimation {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
    
    var actionButtons: some View {
        HStack {
            Button("Ask More") {
                viewModel.handleMoreQuestions()
            }
            .buttonStyle(InteractiveButtonStyle())  // Apply the custom button style
            
            Button("New Video") {
                viewModel.handleNewVideo()
            }
            .buttonStyle(InteractiveButtonStyle())  // Apply the custom button style
        }
        .padding()
    }
}

struct InteractiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(configuration.isPressed ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(40)
            .shadow(radius: configuration.isPressed ? 2 : 5)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
    }
}


#Preview {
    ContentView()
}
