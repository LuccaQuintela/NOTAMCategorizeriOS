//
//  NotamDecoder.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 11/19/24.
//

import Foundation
//import LibTorch

protocol NotamDecoder {
    @MainActor
    static var shared: NotamDecoder { get }
    var isRunning: Bool { get set }
    var subjectLabels: [String] { get set }
    
    func categorize(_ input: String, resultCount: Int) -> [InferenceResult]?
    func topK(scores: [NSNumber], labels: [String], count: Int) -> [InferenceResult]
}

protocol SequentialDecoder: NotamDecoder {
    var subjectModule: NLPTorchModule { get set }
    var statusModule: NLPTorchModule { get set }
    var subjectLabels: [String] { get set }
    var statusLabels: [String] { get }
}

protocol SingularDecoder: NotamDecoder {
    var torchModule: NLPTorchModule { get set }
}

struct InferenceResult {
    let score: Float
    let label: String
}

enum Model {
    case FAASequentialDecoderMiniLM
}
