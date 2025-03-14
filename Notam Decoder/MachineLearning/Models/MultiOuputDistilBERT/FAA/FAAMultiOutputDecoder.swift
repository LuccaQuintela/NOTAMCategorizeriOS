//
//  FAAMultiOutputDecoder.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 3/12/25.
//

import Foundation
import CoreML
import Tokenizers

class FAAMultiOutputDecoder: MultiNotamDecoder {
    typealias ModelType = FAAMultiOutputDistilBERT
    typealias ModelInputType = FAAMultiOutputDistilBERTInput
    let model: ModelType?
    var tokenizer: (any Tokenizer)? = nil
    
    var modelName = "distilbert-base-uncased"
    let inputSize = (1, 128)
    let subjectOutputSize = (1, 103)
    let statusOutputSize = (1, 34)
    
    let subjects: [String]?
    let statuses: [String]?
    
    @MainActor
    static let shared: any NotamDecoder = FAAMultiOutputDecoder()
    
    @MainActor
    private init() {
        guard let subjectFilePath = Bundle.main.path(forResource: "FAAMOD_Subject_Labels", ofType: "txt") else {
            Logger.log(tag: .error, "CRITICAL ERROR: CANNOT LOAD \(type(of: self)) SUBJECT LABELS")
            model = nil
            subjects = nil
            statuses = nil
            return
        }
        
        guard let statusFilePath = Bundle.main.path(forResource: "FAAMOD_Status_Labels", ofType: "txt") else {
            Logger.log(tag: .error, "CRITICAL ERROR: CANNOT LOAD \(type(of: self)) STATUS LABELS")
            model = nil
            subjects = nil
            statuses = nil
            return
        }
        
        do {
            let subjectLabels = try String(contentsOfFile: subjectFilePath, encoding: .utf8)
            let statusLabels = try String(contentsOfFile: statusFilePath, encoding: .utf8)
            Logger.log(tag: .success, "\(type(of: self)) Q-Codes successfully loaded")
            model = try ModelType(configuration: .init())
            Logger.log(tag: .success, "\(type(of: self)) model successfully initialized")
            subjects = subjectLabels.components(separatedBy: .newlines)
            statuses = statusLabels.components(separatedBy: .newlines)
            Task { await importTokenizer() }
        }
        catch let error {
            model = nil
            subjects = nil
            statuses = nil
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
            return try convertOutputToInference(subject: output.last_hidden_state, status: output.last_hidden_state)
        } catch let error {
            Logger.log(tag: .error, "\(type(of: self)) MODEL COULD NOT CATEGORIZE: \(error)")
            throw error
        }
    }
}
