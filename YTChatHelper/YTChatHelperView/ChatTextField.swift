//
//  ChatTextField.swift
//  YTChatHelper
//
//  Created by ashika kalmady on 4/25/24.
//

import SwiftUI

struct ChatTextField: View {
    @Binding var text: String
    var onCommit: () -> Void
    
    var body: some View {
        HStack {
            TextField("Type your message here..", text: $text, onCommit: onCommit)
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(20)
                .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.blue, lineWidth: 2)
                )
                .padding(.horizontal)
            
        }
    }
}

#Preview {
    ChatTextField(text: Binding(get: {
        "hello"
    }, set: { _ in
        
    })) {
    
    }
}
