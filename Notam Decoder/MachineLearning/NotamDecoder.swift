//
//  NotamDecoder.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 11/19/24.
//

import Foundation
import CoreML
import Tokenizers

protocol DecoderManager {
    @MainActor
    static var shared: any DecoderManager { get }
    
    var IcaoDecoder: any NotamDecoder { get }
    var FaaDecoder: any NotamDecoder { get }
    
    func categorize(_ input: String) throws -> InferenceResult
}

extension DecoderManager {
    func categorize(_ input: String) throws -> InferenceResult {
        guard input.count >= 1 else { throw MLError.InputStringEmpty }
        
        if input.first == "!" {
            Logger.log(tag: .debug, "Notam recognized as FAA. Sending to appropriate NotamDecoder")
            return try FaaDecoder.categorize(input)
        } else {
            Logger.log(tag: .debug, "Notam recognized as ICAO. Sending to appropriate NotamDecoder")
            return try IcaoDecoder.categorize(input)
        }
    }
}

protocol NotamDecoder {
    @MainActor
    static var shared: any NotamDecoder { get }
    
    var inputSize: (Int, Int) { get }
    var tokenizer: (any Tokenizer)? { get }
    var modelName: String { get }
    
    func categorize(_ input: String) throws -> InferenceResult
    func convertStringToMLArray(_ input: String) throws -> (MLMultiArray, MLMultiArray)
    func importTokenizer() async
}

protocol SingularNotamDecoder: NotamDecoder {
    associatedtype ModelType
    associatedtype ModelInputType
    var model: ModelType? { get }
    var outputSize: (Int, Int) { get }
    var qcodes: [String]? { get }
    
    func convertOutputToInference(_ output: MLMultiArray) throws -> InferenceResult
}

protocol SequentialNotamDecoder: NotamDecoder {
    associatedtype StatusModelType
    associatedtype StatusModelInputType
    
    associatedtype SubjectModelType
    associatedtype SubjectModelInputType
    
    var statusModel: StatusModelType? { get }
    var subjectModel: SubjectModelType? { get }
    
    var subjects: [String]? { get }
    var statuses: [String]? { get }
    
    func convertOutputToInference(_ output: MLMultiArray, section: QCodeSection) throws -> InferenceResult
}

extension NotamDecoder {
    func convertStringToMLArray(_ input: String) throws -> (MLMultiArray, MLMultiArray) {
        guard let tokenizer else {
            Logger.log(tag: .error, "\(type(of: self)): TOKENIZER NOT INSTANTIATED")
            throw MLError.VoidTokenizer
        }
        
        guard let tokensArray = try? MLMultiArray(shape: [inputSize.0, inputSize.1] as [NSNumber],
                                                  dataType: .int32) else {
            Logger.log(tag: .error, "\(type(of: self)): INPUTIDS MULTIARRAY COULD NOT BE INSTANTIATED")
            throw MLError.ProcessingError
        }
        
        guard let maskArray = try? MLMultiArray(shape: [inputSize.0, inputSize.1] as [NSNumber],
                                                dataType: .int32) else {
            Logger.log(tag: .error, "\(type(of: self)): ATTENTION MASK MULTIARRAY COULD NOT BE INSTANTIATED")
            throw MLError.ProcessingError
        }
        
        let encoding = tokenizer.encode(text: input)
        let encodingSize = encoding.count
        Logger.log(tag: .success, "\(type(of: self)): Successfully created tokenized encoding")

        if encodingSize > inputSize.1 { Logger.log(tag: .warning, "\(type(of: self)): INPUT STRING TOO LONG FOR MODEL'S ARRAY INPUT: CATEGORIZATION MAY SUFFER ISSUES") }
        
        for index in 0 ..< inputSize.1 {
            if index < encodingSize {
                tokensArray[index] = NSNumber(value: encoding[index])
                maskArray[index] = NSNumber(value: 1)
            } else {
                maskArray[index] = NSNumber(value: 0)
                tokensArray[index] = NSNumber(value: 0)
            }
        }
        
        Logger.log(tag: .success, "\(type(of: self)): Succesfully processed input string")
        return (tokensArray, maskArray)
    }
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

struct InferenceResult {
    let score: Float
    let label: String
}

enum Model {
    case EvanModel
    case SingleOutputDistilBERT
    case MultiOutputDistilBERT
    case MiniLM
}

enum MLError: Error {
    case VoidTokenizer
    case ProcessingError
    case VoidModel
    case VoidLabels
    case InputStringEmpty
}

enum QCodeSection {
    case Subject
    case Status
}
