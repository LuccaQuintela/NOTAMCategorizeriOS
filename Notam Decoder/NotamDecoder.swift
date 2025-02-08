//
//  NotamDecoder.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 11/19/24.
//

import Foundation
//import LibTorch

class NotamDecoder {
    
    @MainActor
    static let shared: NotamDecoder = NotamDecoder()
    
    private init() {
        // initialize model
    }
    
    private func prepData(_ input: String) {
        
    }
    
    private func evalModel() {
        
    }
    
    func categorize(_ input: String) -> String? {
        let output: String? = "testing testing"
        prepData(input)
        evalModel()
        return output
    }
    
}
