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
        switch ChosenModel.shared.model {
        case .FAASequentialDecoderMiniLM:
            decoder = FAASequentialDecoderMiniLM.shared
        case nil:
            decoder = nil
        }
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
        
        let qcode = decoder.categorize(notam.content, resultCount: 1)
        
        guard let qcode else {
            return nil
        }
        
        guard !qcode.isEmpty else {
            return nil
        }
        
        let result = qcode[0]
        
        Logger.log(tag: .success, "Notam successfully categorized")
        Logger.log(tag: .success, "\(result.label): Score of \(result.score)")
        
        return result.label
    }
}
