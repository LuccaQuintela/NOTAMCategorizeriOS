//
//  NotamInputView.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 11/19/24.
//

import SwiftUI

struct NotamInputView: View {
    
    @State private var input: String = ""
    
    var body: some View {
        VStack {
            Text("Paste NOTAM Below")
            
            HStack {
                Text(input)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .textFieldStyle()
                
            
            HStack {
                Button(action: {
                    guard let pasted = UIPasteboard.general.string else {
                        return
                    }
                    input = pasted
                }) {
                    Text("Paste")
                        .defaultButtonStyle()
                }
                
                NavigationLink{
                    DecodedNotamView(Notam(input))
                } label: {
                    Text("Categorize")
                        .defaultButtonStyle()
                }
            }
            .padding()
        }
        .addNavBar("Input NOTAM")
    }
}

#Preview {
    NotamInputView()
}
