//
//  MiniLMManager.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 3/12/25.
//

import Foundation

class MiniLMManager: DecoderManager {
    @MainActor
    static let shared: any DecoderManager = MiniLMManager()
    
    let IcaoDecoder: any NotamDecoder
    let FaaDecoder: any NotamDecoder
    
    @MainActor
    private init() {
        FaaDecoder = FAAMiniLMDecoder.shared
        IcaoDecoder = ICAOMiniLMDecoder.shared
    }
}
