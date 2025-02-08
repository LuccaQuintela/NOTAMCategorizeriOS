//
//  DecodedNotamViewModel.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 12/9/24.
//

import Foundation

class DecodedNotamViewModel: ObservableObject {
    private let dataService: DatabaseManager
    private let decoder: NotamDecoder
    
    @MainActor
    static let shared = DecodedNotamViewModel()
    
    @MainActor
    private init() {
        dataService = DatabaseManager.shared
        decoder = NotamDecoder.shared
    }
    
    func saveNotam(_ notam: Notam) {
        notam.isSaved = true
        dataService.insertNotam(notam)
    }
    
    func categorize(_ notam: Notam) -> String? {
        // TODO: incorporate the logic of the actual model
        
        let qcode = decoder.categorize(notam.content)
        
        Logger.log(tag: .success, "Notam successfully categorized")
        return qcode
    }
}
