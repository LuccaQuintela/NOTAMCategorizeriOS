//
//  EvanModel.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 2/25/25.
//

import Foundation
import CoreML
import Tokenizers

class EvanModel: SingularNotamDecoder {
    typealias ModelType = Evan_DistilBERT
    typealias ModelInputType = Evan_DistilBERTInput
    let model: ModelType?
    var tokenizer: (any Tokenizer)? = nil
    
    let modelName = "distilbert-base-uncased"
    let inputSize = (1, 128)
    let outputSize = (1, 479)
    
    let qcodes: [String]?
    
    @MainActor
    static var shared: any NotamDecoder = EvanModel()
    
    @MainActor
    private init() {
        guard let filePath = Bundle.main.path(forResource: "EvanModelQCodes", ofType: "csv") else {
            Logger.log(tag: .error, "CRITICAL ERROR: CANNOT LOAD EVAN MODEL Q CODES")
            model = nil
            qcodes = nil
            return
        }
        
        do {
            let labels = try String(contentsOfFile: filePath, encoding: .utf8)
            Logger.log(tag: .success, "EvanModel Q Codes successfully loaded")
            model = try ModelType(configuration: .init())
            Logger.log(tag: .success, "Evan_DistilBERT model successfully initialized")
            qcodes = labels.components(separatedBy: .newlines)
            Task { await importTokenizer() }
        }
        catch let error {
            model = nil
            qcodes = nil
            Logger.log(tag: .error, "EvanModel Instantiation Error: \(error) - \(error.localizedDescription)")
        }
    }
    
    func importTokenizer() async {
        do {
            tokenizer = try await AutoTokenizer.from(pretrained: modelName)
            Logger.log(tag: .success, "Successfully instantiated tokenizer")
        } catch {
            Logger.log(tag: .error, "TOKENIZER COULD NOT BE INSTANTIATED")
        }
    }
    
    func categorize(_ input: String) throws -> InferenceResult {
        guard let model else {
            Logger.log(tag: .error, "EVAN DISTILBERT MODEL NOT INSTANTIATED::CAN'T CATEGORIZE")
            throw MLError.VoidModel
        }
        
        do {
            let (inputIds, attentionMask) = try convertStringToMLArray(input)
            let processedInput = ModelInputType(input_ids: inputIds, attention_mask: attentionMask)
            let output = try model.prediction(input: processedInput)
            return try convertOutputToInference(output.var_411)
        } catch let error {
            Logger.log(tag: .error, "EVAN DISTILBERT MODEL COULD NOT CATEGORIZE: \(error)")
            throw error
        }
    }
    
    func convertStringToMLArray(_ input: String) throws -> (MLMultiArray, MLMultiArray) {
        guard let tokenizer else {
            Logger.log(tag: .error, "TOKENIZER NOT INSTANTIATED")
            throw MLError.VoidTokenizer
        }
        
        guard let tokensArray = try? MLMultiArray(shape: [inputSize.0, inputSize.1] as [NSNumber],
                                                 dataType: .float32) else {
            Logger.log(tag: .error, "INPUTIDS MULTIARRAY COULD NOT BE INSTANTIATED")
            throw MLError.ProcessingError
        }
        
        guard let maskArray = try? MLMultiArray(shape: [inputSize.0, inputSize.1] as [NSNumber],
                                                 dataType: .float32) else {
            Logger.log(tag: .error, "ATTENTION MASK MULTIARRAY COULD NOT BE INSTANTIATED")
            throw MLError.ProcessingError
        }
        
        let encoding = tokenizer.encode(text: input)
        let encodingSize = encoding.count
        Logger.log(tag: .success, "Successfully created tokenized encoding")

        if encodingSize > inputSize.1 { Logger.log(tag: .warning, "INPUT STRING TOO LONG FOR MODEL'S ARRAY INPUT: CATEGORIZATION MAY SUFFER ISSUES") }
        
        for index in 0 ..< inputSize.1 {
            if index < encodingSize {
                tokensArray[index] = NSNumber(value: encoding[index])
                maskArray[index] = 1
            } else {
                maskArray[index] = 0
            }
        }
        
        Logger.log(tag: .success, "Succesfully processed input string")
        return (tokensArray, maskArray)
    }
    
    func convertOutputToInference(_ output: MLMultiArray) throws -> InferenceResult {
        guard let qcodes else {
            Logger.log(tag: .error, "QCodes are nil, cannot convert output")
            throw MLError.VoidLabels
        }
        
        var maxVal: Float32 = Float.greatestFiniteMagnitude * -1
        var predictionIndex: Int = 0
        
        for index in 0 ..< outputSize.1 {
            if (output[index].floatValue > maxVal) {
                maxVal = output[index].floatValue
                predictionIndex = index
            }
        }
        
        let label = qcodes[predictionIndex]
        return InferenceResult(score: maxVal, label: label)
    }
}
