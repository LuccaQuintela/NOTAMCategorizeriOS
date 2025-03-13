//
//  ContentView.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 11/19/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    Section {
                        NavigationLink {
                            NotamLibraryView()
                        } label: {
                            Text("Library")
                                .simpleLinkStyle()
                        }
                        
                        NavigationLink {
                            NotamInputView()
                        } label: {
                            Text("Input Text")
                                .simpleLinkStyle()
                        }
                        
                    } header: {
                        Text("Categorize NOTAMs")
                            .sectionHeaderStyle()
                    }
                    
                    Section {
                        NavigationLink{
                            SavedNotamsView()
                        } label: {
                            Text("Saved NOTAMs")
                                .simpleLinkStyle()
                        }
                    } header: {
                        Text("Previous NOTAMs")
                            .sectionHeaderStyle()
                    }
                    
                    logoListFooter()

                }
                
                VStack {
                    Spacer()
                    
                    DropDownMenu()
                }
                
            }
            .addNavBar("NOTAM Decoder")
        }
        .accentColor(.themeAccent)
    }
}

#Preview {
    HomeView()
}
