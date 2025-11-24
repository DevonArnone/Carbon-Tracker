import Foundation

enum TransportMode: String, CaseIterable, Identifiable, Codable {
    case car
    case air
    case rail
    
    var id: String { rawValue }
    
    var displayName: String {
        rawValue.capitalized
    }
    
    func activityId(forDistanceKm distanceKm: Double) -> String {
        switch self {
        case .car:
            // medium diesel car
            return "passenger_vehicle-vehicle_type_medium_car-fuel_source_diesel-engine_size_na-vehicle_age_na-vehicle_weight_na"
        case .air:
            // passenger flight - try minimal format
            // Note: Climatiq flight emission factors may require origin/destination airports
            // rather than just distance. This is a fallback that may not work.
            // If this fails, consider using a generic calculation or requiring airport codes.
            return "passenger_flight-route_type_domestic"
        case .rail:
            // generic passenger rail
            return "passenger_train-route_type_na-fuel_source_na"
        }
    }
}

// Send to Climatiq
struct EmissionRequest: Codable {
    let emission_factor: EmissionFactor
    let parameters: EmissionParameters
}

struct EmissionFactor: Codable {
    let activity_id: String
    let data_version: String
}

struct EmissionParameters: Codable {
    let distance: Double
    let distance_unit: String
    let passengers: Int?
    
    init(distance: Double, distance_unit: String, passengers: Int? = nil) {
        self.distance = distance
        self.distance_unit = distance_unit
        self.passengers = passengers
    }
    
    enum CodingKeys: String, CodingKey {
        case distance, distance_unit, passengers
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(distance, forKey: .distance)
        try container.encode(distance_unit, forKey: .distance_unit)
        if let passengers = passengers {
            try container.encode(passengers, forKey: .passengers)
        }
    }
}

// Data from Climatiq
struct EmissionResponse: Codable {
    let co2e: Double
    let co2e_unit: String
}

struct ActivityEntry: Identifiable, Codable {
    let id: UUID
    let title: String
    let mode: TransportMode
    let distanceKm: Double
    let emissionKg: Double
    let date: Date
    
    enum CodingKeys: String, CodingKey {
        case title, mode, distanceKm, emissionKg, date
    }
    
    init(id: UUID = UUID(), title: String, mode: TransportMode, distanceKm: Double, emissionKg: Double, date: Date) {
        self.id = id
        self.title = title
        self.mode = mode
        self.distanceKm = distanceKm
        self.emissionKg = emissionKg
        self.date = date
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.title = try container.decode(String.self, forKey: .title)
        self.mode = try container.decode(TransportMode.self, forKey: .mode)
        self.distanceKm = try container.decode(Double.self, forKey: .distanceKm)
        self.emissionKg = try container.decode(Double.self, forKey: .emissionKg)
        self.date = try container.decode(Date.self, forKey: .date)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(mode, forKey: .mode)
        try container.encode(distanceKm, forKey: .distanceKm)
        try container.encode(emissionKg, forKey: .emissionKg)
        try container.encode(date, forKey: .date)
    }
}

