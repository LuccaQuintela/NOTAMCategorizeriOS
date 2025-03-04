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
    private(set) var model: Model? = Model.EvanModel
    
    @MainActor
    private init() {}
    
    public func switchModel(to newModel: Model?) {
        model = newModel
        Logger.log(tag: .success, "Selected model successfully switched to \(String(describing: model))")
    }
    
    @MainActor
    public func getModel() -> (any NotamDecoder)? {
        switch model {
        case .FAASequentialDecoderMiniLM:
            return EvanModel.shared
//            return FAASequentialDecoderMiniLM.shared
        case .EvanModel:
            return EvanModel.shared
        case nil:
            return nil
        }
    }
}
