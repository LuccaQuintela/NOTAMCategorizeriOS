//
//  DecodedNotamView.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 11/19/24.
//

import SwiftUI

struct DecodedNotamView: View {
    @EnvironmentObject var decodedNotamViewModel: DecodedNotamViewModel
    
    private let notam: Notam
    private let errorMessage:String = "err: could not categorize NOTAM"
    
    var body: some View {
        ZStack {
            
            ExecuteCode {
                guard let _ = notam.decoded else {
                    notam.decoded = decodedNotamViewModel.categorize(notam)
                    return
                }
            }
            
            List {
                Section {
                    Text(notam.decoded ?? errorMessage)
                        .displayNotam(isList: false)
                } header: {
                    Text("Q-Code Classification")
                        .sectionHeaderStyle()
                }
                
                Section {
                    Text(notam.content)
                        .displayNotam(isList: false)
                } header: {
                    Text("Original NOTAM")
                        .sectionHeaderStyle()
                }
                
                logoListFooter()
                
            }
            
            VStack {
                Spacer()
                
                if (!notam.isSaved) {
                    Button(action:{
                        decodedNotamViewModel.saveNotam(notam)
                    }) {
                        Text("Save NOTAM")
                            .defaultButtonStyle(large: true)
                    }
                }
            }
            
        }
        .addNavBar("Translated NOTAM")
    }
    
    init(_ notam: Notam) {
        self.notam = notam
    }
    
}

#Preview {
    DecodedNotamView(
        Notam("""
              (A5598/24 NOTAMN
              Q) MMFR/QMXLC//M/A/000/999/1926N09904W002 
              A) MMMX 
              B) 2407190600 
              C) 2407191200
              E) TWY B BTN TWYS H1 AND D CLSD )
              """))
    .environmentObject(DecodedNotamViewModel.shared)
}
