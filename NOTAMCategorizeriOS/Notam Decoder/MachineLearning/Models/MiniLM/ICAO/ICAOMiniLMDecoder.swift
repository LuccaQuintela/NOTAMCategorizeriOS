//
//  ICAOMiniLMDecoder.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 3/12/25.
//

import Foundation
import CoreML
import Tokenizers

class ICAOMiniLMDecoder: SequentialNotamDecoder {
    typealias SubjectModelType = ICAOSubjectMiniLM
    typealias SubjectModelInputType = ICAOSubjectMiniLMInput
    
    typealias StatusModelType = ICAOStatusMiniLM
    typealias StatusModelInputType = ICAOStatusMiniLMInput
    
    var subjectModel: SubjectModelType? = nil
    let statusModel: StatusModelType?
    
    let inputSize = (1, 512)
    let subjectOutputSize = (1, 103)
    let statusOutputSize = (1, 34)
    var tokenizer: (any Tokenizer)? = nil
    let modelName = "nreimers/MiniLM-L6-H384-uncased"
    
    let subjects: [String]?
    let statuses: [String]?
    
    @MainActor
    static let shared: any NotamDecoder = ICAOMiniLMDecoder()
    
    @MainActor
    private init () {
        guard let subjectFilePath = Bundle.main.path(forResource: "ICAOMLM_Subject_Labels", ofType: "txt") else {
            Logger.log(tag: .error, "CRITICAL ERROR: CANNOT LOAD \(type(of: self)) SUBJECT LABELS")
            subjectModel = nil
            statusModel = nil
            subjects = nil
            statuses = nil
            return
        }
        
        guard let statusFilePath = Bundle.main.path(forResource: "ICAOMLM_Status_Labels", ofType: "txt") else {
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
    
    func importTokenizer() async {
        do {
            tokenizer = try await AutoTokenizer.from(pretrained: modelName)
            Logger.log(tag: .success, "\(type(of: self)): Successfully instantiated tokenizer")
        } catch {
            Logger.log(tag: .error, "\(type(of: self)): TOKENIZER COULD NOT BE INSTANTIATED")
        }
    }
    
    func categorize(_ input: String) throws -> InferenceResult {
        guard let subjectModel, let statusModel else {
            Logger.log(tag: .error, "\(type(of: self)): SUBJECT AND/OR STATUS MODEL NOT INSTANTIATED::CAN'T CATEGORIZE")
            throw MLError.VoidModel
        }
        let subject: InferenceResult
        do {
            let (inputIds, attentionMask) = try convertStringToMLArray(input)
            let processedInput = SubjectModelInputType(input_ids: inputIds, attention_mask: attentionMask)
            let output = try subjectModel.prediction(input: processedInput)
            subject = try convertOutputToInference(output.var_504, section: .Subject)
        } catch let error {
            Logger.log(tag: .error, "\(type(of: self)) MODEL COULD NOT CATEGORIZE: \(error)")
            throw error
        }
        
        return subject
    }
    
    func convertOutputToInference(_ output: MLMultiArray, section: QCodeSection) throws -> InferenceResult {
        guard let subjects, let statuses else {
            Logger.log(tag: .error, "\(type(of: self)): subjects and/or statuses are nil, cannot convert output")
            throw MLError.VoidLabels
        }
        
        var maxVal: Float32 = Float.greatestFiniteMagnitude * -1
        var predictionIndex: Int = 0
        let outputSize = section == .Subject ? subjectOutputSize.1 : statusOutputSize.1
        for index in 0 ..< outputSize {
            if (output[index].floatValue > maxVal) {
                maxVal = output[index].floatValue
                predictionIndex = index
            }
        }
        
        let label = section == .Subject ? subjects[predictionIndex] : statuses[predictionIndex]
        return InferenceResult(score: maxVal, label: label)
    }
}
