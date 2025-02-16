//
//  NetworkManager.swift
//  Treehacks 2025 Project
//
//  Created by Kesavan Ramakrishnan on 2/16/25.
//

import Foundation

/// API Manager to handle network requests
struct NetworkManager {
    static let shared = NetworkManager() // Singleton instance

    /// Sends a GET request and decodes the response into `DetectionResponse`
    func fetchDetections(completion: @escaping (Result<DetectionResponse, NetworkError>) -> Void) {
        // Base URL of the API
        let baseURL = "https://8000-cuy5jl6fd.brevlab.com/latest" // Replace with your API endpoint

        // Ensure the URL is valid
        guard let url = URL(string: baseURL) else {
            completion(.failure(.invalidURL))
            return
        }

        // Create a URL request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // Perform the network request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(.failure(.noDataReceived))
                return
            }

            guard let data = data else {
                completion(.failure(.noDataReceived))
                return
            }

            // Decode the JSON response
            do {
                let decoder = JSONDecoder()
                let detectionResponse = try decoder.decode(DetectionResponse.self, from: data)
                completion(.success(detectionResponse))
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                completion(.failure(.noDataReceived))
            }
        }.resume()
    }
}
