//
//  NotamDecoderApp.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 11/19/24.
//

import SwiftUI

@main
struct NotamDecoderApp: App {
    @StateObject var savedNotamsViewModel = SavedNotamsViewModel.shared
    @StateObject var decodedNotamsViewModel = DecodedNotamViewModel.shared
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(savedNotamsViewModel)
                .environmentObject(decodedNotamsViewModel)
        }
    }
}
