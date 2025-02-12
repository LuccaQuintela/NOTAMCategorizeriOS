//
//  NotamDecoder.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 11/19/24.
//

import Foundation
//import LibTorch

class NotamDecoder {
    
    @MainActor
    static let shared: NotamDecoder = NotamDecoder()
    private var isRunning: Bool = false
    
    private var moduleSubject: NLPTorchModule = {
        guard let filePath = Bundle.main.path(forResource: "optimizedMiniLM_subject", ofType:"pte") else {
            fatalError("CANNOT LOAD SUBJECT MODEL")
        }
        
        let module = NLPTorchModule(fileAtPath: filePath)
        if let module {
            Logger.log(tag: .success, "Subject model successfully loaded")
            return module
        }
        fatalError("CANNOT INSTANTIATE SUBJECT MODEL")
    }()
    
    private var labels: [String] = {
        guard let filePath = Bundle.main.path(forResource: "labels", ofType: "txt") else {
            Logger.log(tag: .error, "CRITICAL ERROR: CANNOT LOAD LABELS")
            return []
        }
        
        do {
            let labels = try String(contentsOfFile: filePath, encoding: .utf8)
            Logger.log(tag: .success, "Labels successfully loaded")
            Logger.log(tag: .success, labels)
            return labels.components(separatedBy: .newlines)
        }
        catch {
            return []
        }
    }()
    
    @MainActor
    private init() {}
    
    func categorize(_ input: String, resultCount: Int) -> [InferenceResult]? {
        if isRunning {
            return nil
        }
        isRunning = true
        Logger.log(tag: .debug, "categorizing: \(input)")
        guard let outputs = moduleSubject.predict(text: input) else {
            Logger.log(tag: .error, "Outputs could not be predicted")
            isRunning = false
            return nil
        }
        isRunning = false
        return topK(scores: outputs, labels: labels, count: resultCount)
    }
    
    func topK(scores: [NSNumber], labels: [String], count: Int) -> [InferenceResult] {
        let zippedResults = zip(labels.indices, scores)
        let sortedResults = zippedResults.sorted{ $0.1.floatValue > $1.1.floatValue }.prefix(count)
        return sortedResults.map { InferenceResult(score: $0.1.floatValue, label: labels[$0.0]) }
    }
    
}

struct InferenceResult {
    let score: Float
    let label: String
}
