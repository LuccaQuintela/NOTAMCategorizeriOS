//
//  EvanModel.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 2/25/25.
//

import Foundation
import CoreML
import Tokenizers

class EvanModel: MLModelNotamDecoder {
    typealias ModelType = Evan_DistilBERT
    let model: Evan_DistilBERT?
    var tokenizer: (any Tokenizer)? = nil
    
    let modelName = "distilbert-base-uncased"
    private let inputIdsSize = (1, 128)
    private let attentionMaskSize = (1, 128)
    private let outputSize = (1, 479)
    
    @MainActor
    static var shared: any NotamDecoder = EvanModel()
    
    @MainActor
    private init() {
        do {
            model = try Evan_DistilBERT(configuration: .init())
            Task { await importTokenizer() }
        } catch {
            Logger.log(tag: .error, "EVAN DISTILBERT MODEL COULD NOT BE INSTANTIATED")
            model = nil
        }
    }
    
    func categorize(_ input: String) -> InferenceResult? {
        guard let model else {
            Logger.log(tag: .error, "EVAN DISTILBERT MODEL NOT INSTANTIATED::CAN'T CATEGORIZE")
            return nil
        }
        
        do {
            let (inputIds, attentionMask) = try convertStringToMLArray(input)
            let processedInput = Evan_DistilBERTInput(input_ids: inputIds, attention_mask: attentionMask)
            let output = try model.prediction(input: processedInput)
            return convertOutputToInference(output.var_411)
        } catch let error {
            Logger.log(tag: .error, "EVAN DISTILBERT MODEL COULD NOT CATEGORIZE: \(error)")
            return nil
        }
    }
    
    func convertStringToMLArray(_ input: String) throws -> (MLMultiArray, MLMultiArray) {
        let inputIds = tokenize(input, dimensions: inputIdsSize)
        let attentionMask = createAttentionMask()
        
        guard let inputIds, let attentionMask else {
            Logger.log(tag: .error, "EITHER INPUTIDS OR ATTENTIONMASK NIL: COULD PROCESS INPUT")
            throw MLError.ProcessingError
        }
        
        return (inputIds, attentionMask)
    }
    
    func convertOutputToInference(_ output: MLMultiArray) -> InferenceResult {
        return InferenceResult(score: 0, label: "XX")
    }
    
    func importTokenizer() async {
        do {
            tokenizer = try await AutoTokenizer.from(pretrained: modelName)
        } catch {
            Logger.log(tag: .error, "TOKENIZER COULD NOT BE INSTANTIATED")
        }
    }
    
    func tokenize(_ input: String, dimensions: (Int, Int)) -> MLMultiArray? {
        guard let tokenizer else {
            Logger.log(tag: .error, "TOKENIZER NOT INSTANTIATED")
            return nil
        }
        
        guard let multiArray = try? MLMultiArray(shape: [dimensions.0, dimensions.1] as [NSNumber],
                                                 dataType: .float32) else {
            Logger.log(tag: .error, "MULTIARRAY COULD NOT BE INSTANTIATED")
            return nil
        }
        
        let encoding = tokenizer.encode(text: input)
        
        for (index, value) in encoding.enumerated() {
            if (index >= dimensions.1) {
                Logger.log(tag: .warning, "INPUT STRING TOO LONG FOR MODEL'S ARRAY INPUT: CATEGORIZATION MAY SUFFER ISSUES")
                break
            }
            multiArray[index] = NSNumber(value: value)
        }
        
        return multiArray
    }
    
    func createAttentionMask() -> MLMultiArray? {
        return MLMultiArray()
    }
}
