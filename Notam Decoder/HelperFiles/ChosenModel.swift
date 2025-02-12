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
    private(set) var model: Model? = Model.FAASequentialDecoderMiniLM
    
    @MainActor
    private init() {}
    
    public func switchModel(to newModel: Model?) {
        model = newModel
        Logger.log(tag: .success, "Selected model successfully switched to \(String(describing: model))")
    }
}
