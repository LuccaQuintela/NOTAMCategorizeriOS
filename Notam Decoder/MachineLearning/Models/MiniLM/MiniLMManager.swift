//
//  MiniLMManager.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 3/12/25.
//

import Foundation
import CoreML

class MiniLMManager: DecoderManager {
    @MainActor
    static let shared: any DecoderManager = MiniLMManager()
    
    let IcaoDecoder: any NotamDecoder
    let FaaDecoder: any NotamDecoder
    
    @MainActor
    private init() {
        FaaDecoder = FAAMiniLMDecoder.shared
        IcaoDecoder = ICAOMiniLMDecoder.shared
    }
}

protocol SequentialNotamDecoder: NotamDecoder {
    associatedtype StatusModelType
    associatedtype StatusModelInputType
    
    associatedtype SubjectModelType
    associatedtype SubjectModelInputType
    
    var statusModel: StatusModelType? { get }
    var subjectModel: SubjectModelType? { get }
    var subjectOutputSize: (Int, Int) { get }
    var statusOutputSize: (Int, Int) { get }
    
    var subjects: [String]? { get }
    var statuses: [String]? { get }
    var subjectLabel: String? { get set }
    
    func convertOutputToInference(_ output: MLMultiArray, section: QCodeSection) throws -> InferenceResult
    func transformInput(string: String, code: String) -> String
}

extension SequentialNotamDecoder {
    func convertOutputToInference(_ output: MLMultiArray, section: QCodeSection) throws -> InferenceResult {
        guard let subjects, let statuses else {
            Logger.log(tag: .error, "\(type(of: self)): subjects and/or statuses are nil, cannot convert output")
            throw MLError.VoidLabels
        }
        
        if section == .Status {
            guard subjectLabel != nil else {
                Logger.log(tag: .error, "\(type(of: self)): Model tried converting status before subject available")
                throw MLError.OutOfOrderPrediction
            }
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
        
        let label = section == .Subject ? subjects[predictionIndex] : subjectLabel! + statuses[predictionIndex]
        if section == .Subject { subjectLabel = label }
        return InferenceResult(score: maxVal, label: label)
    }
    
    // TODO: Actually transform input String
    func transformInput(string: String, code: String) -> String {
        return string
    }
}
