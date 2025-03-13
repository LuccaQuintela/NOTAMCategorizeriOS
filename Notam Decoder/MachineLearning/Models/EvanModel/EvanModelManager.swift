//
//  EvanModelManager.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 3/12/25.
//

import Foundation

class EvanModelManager: DecoderManager {
    let IcaoDecoder: any NotamDecoder
    let FaaDecoder: any NotamDecoder
    
    @MainActor
    static var shared: any DecoderManager = EvanModelManager()
    
    @MainActor
    private init () {
        IcaoDecoder = EvanModel.shared
        FaaDecoder = EvanModel.shared
    }
}
