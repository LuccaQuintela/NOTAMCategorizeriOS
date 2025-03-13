//
//  DatabaseManager.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 12/4/24.
//

import Foundation
import SwiftData

class DatabaseManager {
    private let modelContainer: ModelContainer?
    private let modelContext: ModelContext?
    
    @MainActor
    static let shared = DatabaseManager()
    
    @MainActor
    private init() {
        do {
            self.modelContainer = try ModelContainer(for: Notam.self,
                                                     configurations: ModelConfiguration(isStoredInMemoryOnly: false))
            self.modelContext = modelContainer?.mainContext
            Logger.log(tag: .success, "Database instantiated")
        } catch {
            self.modelContainer = nil
            self.modelContext = nil
            Logger.log(tag: .warning, "Model container and model context nil")
        }
    }
    
    func fetchNotams() -> [Notam] {
        do {
            guard let modelContext = modelContext else { throw DatabaseError.instantiationError }
            Logger.log(tag: .success, "Notams fetched from disk")
            return try modelContext.fetch(FetchDescriptor<Notam>())
        } catch {
            Logger.log(tag: .error, "Notams could not be fetched")
            return []
        }
    }
    
    func saveNotams() {
        do {
            guard let modelContext = modelContext else { throw DatabaseError.instantiationError }
            try modelContext.save()
            Logger.log(tag: .success, "Notams saved")
        } catch {
            Logger.log(tag: .error, "Notams could not be saved")
        }
    }
    
    func insertNotam(_ item: Notam) {
        guard let modelContext = modelContext else {
            Logger.log(tag: .error, "ModelContext nil, notam could not be inserted")
            return
        }
        modelContext.insert(item)
        Logger.log(tag: .success, "Notam inserted into model context")
    }
    
    func clearData() {
        do {
            guard let modelContext = modelContext else { throw DatabaseError.instantiationError }
            try modelContext.delete(model: Notam.self)
            Logger.log(tag: .success, "Cleared Notam SwiftData container")
        } catch {
            Logger.log(tag: .error, "Failed to clear Notam SwiftData container")
        }
    }
}

enum DatabaseError: Error {
    case instantiationError
}
