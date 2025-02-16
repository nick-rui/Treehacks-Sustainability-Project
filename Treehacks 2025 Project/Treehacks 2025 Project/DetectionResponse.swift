//
//  DetectionResponse.swift
//  Treehacks 2025 Project
//
//  Created by Kesavan Ramakrishnan on 2/16/25.
//

import Foundation

/// The response structure for detections
struct DetectionResponse: Decodable {
    let detections: [ClassificationResult]
}

/// A single classification result
struct ClassificationResult: Codable, Hashable {
    let object: String
    let confidence: Double
    let bbox: [Double]
}

/// Custom network error enumeration
enum NetworkError: LocalizedError {
    case invalidURL
    case noDataReceived
    case imageConversionFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .noDataReceived:
            return "No data was received from the server."
        case .imageConversionFailed:
            return "Unable to convert UIImage to Data."
        }
    }
}
