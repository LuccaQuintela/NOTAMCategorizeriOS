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
    private(set) var model: Model = Model.SingleOutputDistilBERT
    
    @MainActor
    private init() {}
    
    public func switchModel(to newModel: Model) {
        model = newModel
        Logger.log(tag: .success, "Selected model successfully switched to \(String(describing: model))")
    }
    
    @MainActor
    public func getModel() -> (any DecoderManager)? {
        switch model {
        case .EvanModel:
            return EvanModelManager.shared
        case .SingleOutputDistilBERT:
            return SingleDistilBERTManager.shared
        case .MultiOutputDistilBERT:
            return MultiDistilBERTManager.shared
        case .MiniLM:
            return MiniLMManager.shared
        }
    }
}
