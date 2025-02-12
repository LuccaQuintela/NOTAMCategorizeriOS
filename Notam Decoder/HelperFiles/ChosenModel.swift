//
//  ChosenModel.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 2/12/25.
//

import Foundation

class ChosenModel {
    @MainActor
    static let shared: ChosenModel = ChosenModel()
    public let model: Model? = Model.FAASequentialDecoderMiniLM
    
    @MainActor
    private init() {}
}
