//
//  MultiDistilBERTManager.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 3/12/25.
//

import Foundation
import CoreML

class MultiDistilBERTManager: DecoderManager {
    @MainActor
    static let shared: any DecoderManager = MultiDistilBERTManager()
    
    let IcaoDecoder: any NotamDecoder
    let FaaDecoder: any NotamDecoder
    
    @MainActor
    private init() {
        FaaDecoder = FAAMultiOutputDecoder.shared
        IcaoDecoder = ICAOMultiOutputDecoder.shared
    }
}

protocol MultiNotamDecoder: NotamDecoder {
    associatedtype ModelType
    associatedtype ModelInputType
    var model: ModelType? { get }
    var subjectOutputSize: (Int, Int) { get }
    var statusOutputSize: (Int, Int) { get }
    var subjects: [String]? { get }
    var statuses: [String]? { get }
    
    func convertOutputToInference(subject: MLMultiArray, status: MLMultiArray) throws -> InferenceResult
}

extension MultiNotamDecoder {
    func convertOutputToInference(subject: MLMultiArray, status: MLMultiArray) throws -> InferenceResult {
        guard let subjects, let statuses else {
            Logger.log(tag: .error, "\(type(of: self)): QCodes are nil, cannot convert output")
            throw MLError.VoidLabels
        }
        
        var maxVal: Float32 = Float.greatestFiniteMagnitude * -1
        var predictionIndex: Int = 0
        
        for index in 0 ..< subjectOutputSize.1 {
            if (subject[index].floatValue > maxVal) {
                maxVal = subject[index].floatValue
                predictionIndex = index
            }
        }
        
        let subjectLabel = subjects[predictionIndex]
        maxVal = Float.greatestFiniteMagnitude * -1
        predictionIndex = 0
        
        for index in 0 ..< statusOutputSize.1 {
            if (status[index].floatValue > maxVal) {
                maxVal = status[index].floatValue
                predictionIndex = index
            }
        }
        
        let statusLabel = statuses[predictionIndex]
        
        return InferenceResult(score: maxVal, label: subjectLabel + statusLabel)
    }
}
