//
//  DecodedNotamViewModel.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 12/9/24.
//

import Foundation

class DecodedNotamViewModel: ObservableObject {
    private let dataService: DatabaseManager
    private var decoder: (any NotamDecoder)? = nil
    
    
    @MainActor
    static let shared = DecodedNotamViewModel()
    
    @MainActor
    private init() {
        dataService = DatabaseManager.shared
        updateModelSelection()
    }
    
    @MainActor
    private func updateModelSelection() {
        decoder = ChosenModel.shared.getModel()
    }
    
    func saveNotam(_ notam: Notam) {
        notam.isSaved = true
        dataService.insertNotam(notam)
    }
    
    func categorize(_ notam: Notam) -> String? {        
        guard let decoder else {
            Logger.log(tag: .error, "No Decoder Selected")
            return nil
        }
        
        do {
            let result = try decoder.categorize(notam.content)
            Logger.log(tag: .success, "Notam successfully categorized")
            Logger.log(tag: .success, "\(result.label): Score of \(result.score)")
            return result.label
        } catch let error {
            Logger.log(tag: .error, "Notam could not be categorized: \(error)")
            return nil
        }
    }
}
