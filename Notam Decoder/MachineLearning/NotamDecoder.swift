//
//  NotamDecoder.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 11/19/24.
//

import Foundation
import CoreML
import Tokenizers

protocol NotamDecoder {
    @MainActor
    static var shared: NotamDecoder { get }
    
    func categorize(_ input: String) throws -> InferenceResult
}

protocol MLModelNotamDecoder: NotamDecoder {
    associatedtype ModelType
    var model: ModelType? { get }
    var tokenizer: (any Tokenizer)? { get }
    var modelName: String { get }
    var inputSize: (Int, Int) { get }
    var outputSize: (Int, Int) { get }
    var qcodes: [String]? { get }
    
    func convertStringToMLArray(_ input: String) throws -> (MLMultiArray, MLMultiArray)
    func convertOutputToInference(_ output: MLMultiArray) throws -> InferenceResult
}

struct InferenceResult {
    let score: Float
    let label: String
}

enum Model {
    case FAASequentialDecoderMiniLM
    case EvanModel
}

enum MLError: Error {
    case VoidTokenizer
    case ProcessingError
    case VoidModel
    case VoidLabels
}
