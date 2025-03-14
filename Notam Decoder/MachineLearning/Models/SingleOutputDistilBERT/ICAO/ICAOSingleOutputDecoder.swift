//
//  ICAOSingleOutputDecoder.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 3/12/25.
//

import Foundation
import CoreML
import Tokenizers

class ICAOSingleOutputDecoder: SingularNotamDecoder {
    typealias ModelType = ICAOSingleOutputDistilBERT
    typealias ModelInputType = ICAOSingleOutputDistilBERTInput
    let model: ModelType?
    var tokenizer: (any Tokenizer)? = nil
    
    var modelName = "distilbert-base-uncased"
    let inputSize = (1, 512)
    let outputSize = (1, 1004)
    
    let qcodes: [String]?
    
    @MainActor
    static let shared: any NotamDecoder = ICAOSingleOutputDecoder()
    
    @MainActor
    private init() {
        guard let filePath = Bundle.main.path(forResource: "ICAOSOD_Labels", ofType: "txt") else {
            Logger.log(tag: .error, "CRITICAL ERROR: CANNOT LOAD \(type(of: self)) Q CODES")
            model = nil
            qcodes = nil
            return
        }
        
        do {
            let labels = try String(contentsOfFile: filePath, encoding: .utf8)
            Logger.log(tag: .success, "\(type(of: self)) Q-Codes successfully loaded")
            model = try ModelType(configuration: .init())
            Logger.log(tag: .success, "\(type(of: self)) model successfully initialized")
            qcodes = labels.components(separatedBy: .newlines)
            Task { await importTokenizer() }
        }
        catch let error {
            model = nil
            qcodes = nil
            Logger.log(tag: .error, "\(type(of: self)) Instantiation Error: \(error) - \(error.localizedDescription)")
        }
    }
    
    func categorize(_ input: String) throws -> InferenceResult {
        guard let model else {
            Logger.log(tag: .error, "\(type(of: self)) MODEL NOT INSTANTIATED::CAN'T CATEGORIZE")
            throw MLError.VoidModel
        }
        
        do {
            let (inputIds, attentionMask) = try convertStringToMLArray(input)
            let processedInput = ModelInputType(input_ids: inputIds, attention_mask: attentionMask)
            let output = try model.prediction(input: processedInput)
            return try convertOutputToInference(output.var_411)
        } catch let error {
            Logger.log(tag: .error, "\(type(of: self)) MODEL COULD NOT CATEGORIZE: \(error)")
            throw error
        }
    }
}
