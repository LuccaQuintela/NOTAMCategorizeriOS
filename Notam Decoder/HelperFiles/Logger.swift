//
//  Logger.swift
//  Notam Decoder
//
//  Created by Lucca Quintela on 12/4/24.
//

import Foundation

struct Logger {
    static func log(tag: LogTag = .debug, _ item: Any) {
        let message = tag.label + retrieveOutput(item)
        print(message)
    }
    
    static private func retrieveOutput(_ item: Any) -> String {
        if let item = item as? CustomStringConvertible {
            return "\(item.description)"
        } else {
            return "\(item)"
        }
    }
}

enum LogTag {
    case error
    case warning
    case success
    case debug
    
    var label: String {
        switch self {
        case .error : return "🟥[ERROR]🟥: "
        case .warning : return "🟨[WARNING]🟨: "
        case .success : return "🟩[SUCCESS]🟩: "
        case .debug : return "[DEBUG]: "
        }
    }
}
