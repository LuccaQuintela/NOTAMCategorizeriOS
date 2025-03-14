//
//  FAAMiniLMDecoder.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 3/12/25.
//

import Foundation
import CoreML
import Tokenizers

class FAAMiniLMDecoder: SequentialNotamDecoder {
    typealias SubjectModelType = FAASubjectMiniLM
    typealias SubjectModelInputType = FAASubjectMiniLMInput
    
    typealias StatusModelType = FAAStatusMiniLM
    typealias StatusModelInputType = FAAStatusMiniLMInput
    
    var subjectModel: SubjectModelType? = nil
    let statusModel: StatusModelType?
    
    let inputSize = (1, 512)
    let subjectOutputSize = (1, 103)
    let statusOutputSize = (1, 34)
    var tokenizer: (any Tokenizer)? = nil
    let modelName = "distilbert-base-uncased"
    
    let subjects: [String]?
    let statuses: [String]?
    var subjectLabel: String? = nil
    
    @MainActor
    static let shared: any NotamDecoder = FAAMiniLMDecoder()
    
    @MainActor
    private init () {
        guard let subjectFilePath = Bundle.main.path(forResource: "FAAMLM_Subject_Labels", ofType: "txt") else {
            Logger.log(tag: .error, "CRITICAL ERROR: CANNOT LOAD \(type(of: self)) SUBJECT LABELS")
            subjectModel = nil
            statusModel = nil
            subjects = nil
            statuses = nil
            return
        }
        
        guard let statusFilePath = Bundle.main.path(forResource: "FAAMLM_Status_Labels", ofType: "txt") else {
            Logger.log(tag: .error, "CRITICAL ERROR: CANNOT LOAD \(type(of: self)) STATUS LABELS")
            subjectModel = nil
            statusModel = nil
            subjects = nil
            statuses = nil
            return
        }
        
        do {
            let subjectLabels = try String(contentsOfFile: subjectFilePath, encoding: .utf8)
            let statusLabels = try String(contentsOfFile: statusFilePath, encoding: .utf8)
            Logger.log(tag: .success, "\(type(of: self)) Q-Codes successfully loaded")
            subjectModel = try SubjectModelType(configuration: .init())
            statusModel = try StatusModelType(configuration: .init())
            Logger.log(tag: .success, "\(type(of: self)) models successfully initialized")
            subjects = subjectLabels.components(separatedBy: .newlines)
            statuses = statusLabels.components(separatedBy: .newlines)
            Task { await importTokenizer() }
        }
        catch let error {
            subjectModel = nil
            statusModel = nil
            subjects = nil
            statuses = nil
            Logger.log(tag: .error, "\(type(of: self)) Instantiation Error: \(error) - \(error.localizedDescription)")
        }
    }
    
    func categorize(_ input: String) throws -> InferenceResult {
        guard let subjectModel, let statusModel else {
            Logger.log(tag: .error, "\(type(of: self)): SUBJECT AND/OR STATUS MODEL NOT INSTANTIATED::CAN'T CATEGORIZE")
            throw MLError.VoidModel
        }
        
        do {
            let (subjectInputIds, subjectAttentionMask) = try convertStringToMLArray(input)
            let subjectProcessedInput = SubjectModelInputType(input_ids: subjectInputIds, attention_mask: subjectAttentionMask)
            let subjectOutput = try subjectModel.prediction(input: subjectProcessedInput)
            let subject = try convertOutputToInference(subjectOutput.var_504, section: .Subject).label
            let transformedInput = transformInput(string: input, code: subject)
            let (statusInputIds, statusAttentionMask) = try convertStringToMLArray(transformedInput)
            let statusProcessedInput = StatusModelInputType(input_ids: statusInputIds, attention_mask: statusAttentionMask)
            let statusOutput = try statusModel.prediction(input: statusProcessedInput)
            return try convertOutputToInference(statusOutput.var_504, section: .Status)
        } catch let error {
            Logger.log(tag: .error, "\(type(of: self)) MODEL COULD NOT CATEGORIZE: \(error)")
            throw error
        }
    }
}
