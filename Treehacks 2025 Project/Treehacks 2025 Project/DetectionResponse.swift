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

struct entityMap {
    static var map: [String: (
        scale: SIMD3<Float>,
        position: SIMD3<Float>,
        collisionRadius: Float,
        category: String
    )] = [
        "Pizza box": ([0.0001, 0.0001, 0.0001], [0, 1.25, -1.25], 2.2 / 0.0001, "compost"),
        "Robot": ([0.01, 0.01, 0.01], [0, 0, 0], 2.2 / 0.01, "trash"),
        "Disposable plastic cup": ([0.001, 0.001, 0.001], [0, 0, 0], 2.2 / 0.001, "trash"),
        "Paper cup": ([0.001, 0.001, 0.001], [0, 0, 0], 2.2 / 0.001, "compost"),
        "Aerosol": ([0.01, 0.01, 0.01], [0, 0, 0], 2.2 / 0.01, "trash"),
        "Cigarette": ([10000, 10000, 10000], [0, 0, 100], 2.2 / 10000, "trash"),
        "Clear plastic bottle": ([0.01, 0.01, 0.01], [0, 0, 0], 2.2 / 0.01, "recycle"),
        "Crisp packet": ([0.01, 0.01, 0.01], [0, 0, 0], 2.2 / 0.01, "trash"),
        "Drink can": ([0.03, 0.03, 0.03], [0, 0, 0], 2.2 / 0.03, "recycle"),
        "Drink carton": ([0.02, 0.02, 0.02], [0, 0, 0], 2.2 / 0.02, "compost"),
        "Egg carton": ([0.02, 0.02, 0.02], [0, 0, 0], 2.2 / 0.02, "compost"),
        "Foam cup": ([0.03, 0.03, 0.03], [0, 0, 0], 2.2 / 0.03, "trash"),
        "Food can": ([0.002, 0.002, 0.002], [0, 0, 0], 2.2 / 0.002, "recycle"),
        "Food waste": ([0.001, 0.001, 0.001], [0, 0, 0], 2.2 / 0.001, "compost"),
        "Glass bottle": ([0.01, 0.01, 0.01], [0, 0, 0], 2.2 / 0.01, "recycle"),
        "Normal paper": ([0.005, 0.005, 0.005], [0, 0, 0], 2.2 / 0.005, "recycle"),
        "Plastic utensils": ([0.0008, 0.0008, 0.0008], [0, 0, 0], 2.2 / 0.0008, "trash"),
        "Scrap metal": ([0.0008, 0.0008, 0.0008], [0, 0, 0], 2.2 / 0.0008, "recycle"),
        "Single-use carrier bag": ([0.002, 0.002, 0.002], [0, 0, 0], 2.2 / 0.002, "trash"),
        "Squeezable tube": ([0.0001, 0.0001, 0.0001], [0, 0, 0], 2.2 / 0.0001, "trash")
    ]
    
    static let mappedItems: [String: String] = [
        "Aluminium foil" : "Crisp packet",
        "Aerosol": "Aerosol",
        "Cigarette": "Cigarette",
        "Plastic bottle": "Clear plastic bottle",
        "Chip bag": "Crisp packet",
        "Plastic cup": "Disposable plastic cup",
        "Drink can": "Drink can",
        "Drink carton": "Drink carton",
        "Egg carton": "Egg carton",
        "Foam cup": "Foam cup",
        "Food can": "Food can",
        "Food waste": "Food waste",
        "Bottle": "Glass bottle",
        "Normal paper": "Normal paper",
        "Paper cup": "Paper cup",
        "Pizza box": "Pizza box",
        "Plastic straw": "Plastic straw",
        "Plastic utensils": "Plastic utensils",
        "Scrap metal": "Scrap metal",
        "Squeezable tube": "Squeezable tube"
    ]
}

