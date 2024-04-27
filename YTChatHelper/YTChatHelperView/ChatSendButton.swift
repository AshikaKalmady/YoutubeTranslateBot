//
//  ChatSendButton.swift
//  YTChatHelper
//
//  Created by ashika kalmady on 4/25/24.
//

import SwiftUI

struct ChatSendButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "paperplane.fill")
                .font(.system(size: 22))
                .foregroundColor(.white)
                .padding(10)
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(radius: 3)
        }
    }
}

#Preview {
    ChatSendButton(action: {
    })
}
