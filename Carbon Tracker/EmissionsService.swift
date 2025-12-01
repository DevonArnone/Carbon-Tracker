import Foundation

enum EmissionsError: Error {
    case invalidURL
    case invalidResponse
    case decodingError(String)
}

struct EmissionsService {
    private static var apiKey: String {
        return Config.apiKey
    }
    
    private static let baseURL = URL(string: "https://api.climatiq.io/data/v1/estimate")!
    
    static func estimateEmissions(distanceKm: Double,
                                  mode: TransportMode) async throws -> EmissionResponse {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let passengers = mode == .air ? 1 : nil
        
        let activityId = mode.activityId(forDistanceKm: distanceKm)
        
        let body = EmissionRequest(
            emission_factor: EmissionFactor(
                activity_id: activityId,
                data_version: "28.28"
            ),
            parameters: EmissionParameters(
                distance: distanceKm,
                distance_unit: "km",
                passengers: passengers
            )
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let requestBody = try encoder.encode(body)
        request.httpBody = requestBody
        
        // Log request for debugging
        if let requestString = String(data: requestBody, encoding: .utf8) {
            print("API Request URL: \(baseURL)")
            print("API Request Body: \(requestString)")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw EmissionsError.invalidResponse
        }
        
        // Log response for debugging
        let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode response"
        print("API Response Status: \(http.statusCode)")
        print("API Response Body: \(responseString)")
        
        guard 200..<300 ~= http.statusCode else {
            // For flights, if API doesn't support distance-based queries, use fallback calculation
            if mode == .air && http.statusCode == 400 {
                // Use generic emission factor for flights: ~0.255 kg CO2e per passenger-km (average)
                // This is a fallback when Climatiq doesn't have a matching activity ID
                let fallbackCo2e = distanceKm * 0.255
                print("Using fallback calculation for flight: \(fallbackCo2e) kg CO2e for \(distanceKm) km")
                return EmissionResponse(co2e: fallbackCo2e, co2e_unit: "kg")
            }
            
            var errorMsg = "HTTP \(http.statusCode)"
            if http.statusCode == 401 {
                errorMsg += ": Unauthorized - Check your API key"
            } else if http.statusCode == 400 {
                errorMsg += ": Bad Request - Check request format"
            } else if http.statusCode == 404 {
                errorMsg += ": Not Found - Check API endpoint"
            }
            print("API Error Status: \(http.statusCode), Message: \(responseString)")
            throw EmissionsError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            let emissionResponse = try decoder.decode(EmissionResponse.self, from: data)
            print("Successfully decoded response: co2e=\(emissionResponse.co2e), unit=\(emissionResponse.co2e_unit)")
            return emissionResponse
        } catch let decodingError {
            let errorMessage = "Decoding error: \(decodingError.localizedDescription). Response was: \(responseString)"
            print(errorMessage)
            if let jsonError = decodingError as? DecodingError {
                print("Detailed decoding error: \(jsonError)")
            }
            throw EmissionsError.decodingError(errorMessage)
        }
    }
}

