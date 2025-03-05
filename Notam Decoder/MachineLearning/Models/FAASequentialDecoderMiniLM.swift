////
////  FAASequentialDecoderMiniLM.swift
////  Notam Decoder
////
////  Created by Lucca Quintela on 2/12/25.
////
//
//import Foundation
//
//class FAASequentialDecoderMiniLM: SequentialDecoder {
//    
//    @MainActor
//    static var shared: any NotamDecoder = FAASequentialDecoderMiniLM()
//    var isRunning: Bool = false
//    
//    var subjectModule: NLPTorchModule = {
//        guard let filePath = Bundle.main.path(forResource: "optimizedMiniLM_subject", ofType:"pte") else {
//            fatalError("CANNOT LOAD SUBJECT MODEL")
//        }
//        
//        let module = NLPTorchModule(fileAtPath: filePath)
//        if let module {
//            Logger.log(tag: .success, "Subject model successfully loaded")
//            return module
//        }
//        fatalError("CANNOT INSTANTIATE SUBJECT MODEL")
//    }()
//    
//    var statusModule: NLPTorchModule = {
//        guard let filePath = Bundle.main.path(forResource: "optimizedMiniLM_status", ofType:"pte") else {
//            fatalError("CANNOT LOAD STATUS MODEL")
//        }
//        
//        let module = NLPTorchModule(fileAtPath: filePath)
//        if let module {
//            Logger.log(tag: .success, "Status model successfully loaded")
//            return module
//        }
//        fatalError("CANNOT INSTANTIATE STATUS MODEL")
//    }()
//    
//    var subjectLabels: [String] = {
//        guard let filePath = Bundle.main.path(forResource: "subjectLabels", ofType: "txt") else {
//            Logger.log(tag: .error, "CRITICAL ERROR: CANNOT LOAD SUBJECT LABELS")
//            return []
//        }
//        
//        do {
//            let labels = try String(contentsOfFile: filePath, encoding: .utf8)
//            Logger.log(tag: .success, "Subject labels successfully loaded")
//            return labels.components(separatedBy: .newlines)
//        }
//        catch {
//            return []
//        }
//    }()
//    
//    var statusLabels: [String] = {
//        guard let filePath = Bundle.main.path(forResource: "statusLabels", ofType: "txt") else {
//            Logger.log(tag: .error, "CRITICAL ERROR: CANNOT LOAD STATUS LABELS")
//            return []
//        }
//        
//        do {
//            let labels = try String(contentsOfFile: filePath, encoding: .utf8)
//            Logger.log(tag: .success, "Status labels successfully loaded")
//            return labels.components(separatedBy: .newlines)
//        }
//        catch {
//            return []
//        }
//    }()
//    
//    @MainActor
//    private init() {}
//    
//    func categorize(_ input: String) -> InferenceResult? {
//        if isRunning {
//            return nil
//        }
//        isRunning = true
//        Logger.log(tag: .debug, "categorizing: \(input)")
//        
//        var encodedInput = String(describing: input.cString(using: String.Encoding.utf8))
//        let remove: Set<Character> = ["\n"]
//        encodedInput.removeAll(where: { remove.contains($0) })
//        
//        guard let subjectOutput = subjectModule.predict(text: encodedInput) else {
//            Logger.log(tag: .error, "Subject outputs could not be predicted")
//            isRunning = false
//            return nil
//        }
//        
//        
//        guard let completeOutput = statusModule.predict(text: input) else {
//            Logger.log(tag: .error, "Status outputs could not be predicted")
//            isRunning = false
//            return nil
//        }
//        isRunning = false
//        topK(scores: completeOutput, labels: subjectLabels)
//        return nil
//    }
//    
//    func topK(scores: [NSNumber], labels: [String], count: Int = 1) -> [InferenceResult] {
//        let zippedResults = zip(labels.indices, scores)
//        let sortedResults = zippedResults.sorted{ $0.1.floatValue > $1.1.floatValue }.prefix(count)
//        return sortedResults.map { InferenceResult(score: $0.1.floatValue, label: labels[$0.0]) }
//    }
//    
//}
