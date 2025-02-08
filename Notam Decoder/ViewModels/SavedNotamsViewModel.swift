//
//  SavedNotamsViewModel.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 12/9/24.
//

import Foundation

class SavedNotamsViewModel: ObservableObject {
    private let dataService: DatabaseManager
    
    @MainActor
    static let shared: SavedNotamsViewModel = SavedNotamsViewModel()
    
    @MainActor
    private init() {
        dataService = DatabaseManager.shared
    }
    
    func fetch() -> [Notam] {
        return dataService.fetchNotams()
    }
}
