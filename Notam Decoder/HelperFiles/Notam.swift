//
//  Notam.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 11/19/24.
//

import Foundation
import SwiftData

@Model
class Notam: Identifiable {
    var id = UUID()
    var content: String
    var decoded: String?
    var isSaved: Bool
    
    init(_ content: String, decoded: String? = nil) {
        self.content = content
        self.decoded = decoded
        self.isSaved = false
    }
}
