//
//  EvanModel.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 2/25/25.
//

import Foundation
import CoreML

class EvanModel: MLModelNotamDecoder {
    typealias ModelType = Evan_DistilBERT
    var model: Evan_DistilBERT?
    
    @MainActor
    static var shared: any NotamDecoder = EvanModel()
    
    @MainActor
    private init() {
        do {
            model = try Evan_DistilBERT(configuration: .init())
        } catch {
            Logger.log(tag: .error, "EVAN DISTILBERT MODEL COULD NOT BE INSTANTIATED")
        }
    }
    
    func categorize(_ input: String) -> InferenceResult? {
        guard let model else {
            Logger.log(tag: .error, "EVAN DISTILBERT MODEL NOT INSTANTIATED::CAN'T CATEGORIZE")
            return nil
        }
        
        do {
            let (inputIds, attentionMask) = convertStringToMLArray(input)
            let processedInput = Evan_DistilBERTInput(input_ids: inputIds, attention_mask: attentionMask)
            let output = try model.prediction(input: processedInput)
            return convertOutputToInference(output.var_411)
        } catch let error {
            Logger.log(tag: .error, "EVAN DISTILBERT MODEL COULD NOT CATEGORIZE: \(error)")
            return nil
        }
    }
    
    // TODO: Actually implement conversion logic
    func convertStringToMLArray(_ input: String) -> (MLMultiArray, MLMultiArray) {
        let inputIds = MLMultiArray()
        let attentionMask = MLMultiArray()
        
        return (inputIds, attentionMask)
    }
    
    // TODO: Actually implement conversion logic
    func convertOutputToInference(_ output: MLMultiArray) -> InferenceResult {
        return InferenceResult(score: 0, label: "XX")
    }
}
