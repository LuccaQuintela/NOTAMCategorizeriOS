//
//  MultiDistilBERTManager.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 3/12/25.
//

import Foundation

class MultiDistilBERTManager: DecoderManager {
    @MainActor
    static let shared: any DecoderManager = MultiDistilBERTManager()
    
    let IcaoDecoder: any NotamDecoder
    let FaaDecoder: any NotamDecoder
    
    @MainActor
    private init() {
        FaaDecoder = FAAMultiOutputDecoder.shared
        IcaoDecoder = ICAOMultiOutputDecoder.shared
    }
}
