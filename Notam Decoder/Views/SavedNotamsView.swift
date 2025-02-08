//
//  SavedNotamsView.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 11/19/24.
//

import SwiftUI

struct SavedNotamsView: View {
    @EnvironmentObject var savedNotamsViewModel: SavedNotamsViewModel
    
    var body: some View {
        HStack {
            let savedNotams = savedNotamsViewModel.fetch()
            
            if savedNotams.isEmpty {
                Text("No Notams Saved")
            } else {
                List {
                    ForEach(savedNotams, id: \.id) { notam in
                        NavigationLink {
                            DecodedNotamView(notam)
                        } label: {
                            Text(notam.content)
                                .displayNotam(isList: true)
                        }
                    }
                    
                    logoListFooter()
                    
                }
            }
        }
        .addNavBar("Saved Notams")
    }
}

#Preview {
    SavedNotamsView()
        .environmentObject(SavedNotamsViewModel.shared)
}
