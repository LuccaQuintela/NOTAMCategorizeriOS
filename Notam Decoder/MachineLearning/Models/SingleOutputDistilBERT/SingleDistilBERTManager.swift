//
//  SingleDistilBERTManager.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 3/12/25.
//

import Foundation

class SingleDistilBERTManager: DecoderManager {
    @MainActor
    static let shared: any DecoderManager = SingleDistilBERTManager()
    
    let IcaoDecoder: any NotamDecoder
    let FaaDecoder: any NotamDecoder
    
    @MainActor
    private init() {
        FaaDecoder = FAASingleOutputDecoder.shared
        IcaoDecoder = ICAOSingleOutputDecoder.shared
    }
}
