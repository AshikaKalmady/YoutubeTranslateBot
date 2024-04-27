//
//  YTChatMessageView.swift
//  YTChatHelper
//
//  Created by ashika kalmady on 4/25/24.
//

import SwiftUI

struct ChatMessageView: View {
    var message: ChatMessages
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 15) {
            if message.isUser {
                Spacer()
                Text(message.content)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            } else {
                Text(message.content)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.black)
                    .cornerRadius(15)
                Spacer()
            }
        }
    }
}

#Preview {
    ChatMessageView(message: ChatMessages(content: "hello sadbajshgj dsahdjhfdjdhf jhdsgfjadhsf hsadjkhdfkdj hadjshkfad", isUser: true))
}
