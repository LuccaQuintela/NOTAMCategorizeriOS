//
//  SingleDistilBERTManager.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 3/12/25.
//

import Foundation
import CoreML

class SingleDistilBERTManager: DecoderManager {
    @MainActor
    static let shared: any DecoderManager = SingleDistilBERTManager()
    
    let IcaoDecoder: any NotamDecoder
    let FaaDecoder: any NotamDecoder
    
    @MainActor
    private init() {
        FaaDecoder = FAASingleOutputDecoder.shared
        IcaoDecoder = ICAOSingleOutputDecoder.shared
    }
}

protocol SingularNotamDecoder: NotamDecoder {
    associatedtype ModelType
    associatedtype ModelInputType
    var model: ModelType? { get }
    var outputSize: (Int, Int) { get }
    var qcodes: [String]? { get }
    
    func convertOutputToInference(_ output: MLMultiArray) throws -> InferenceResult
}

extension SingularNotamDecoder {
    func convertOutputToInference(_ output: MLMultiArray) throws -> InferenceResult {
        guard let qcodes else {
            Logger.log(tag: .error, "\(type(of: self)): QCodes are nil, cannot convert output")
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
