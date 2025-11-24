import SwiftUI

struct AddActivityView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var entries: [ActivityEntry]
    
    @State private var title: String = ""
    @State private var distanceText: String = ""
    @State private var selectedMode: TransportMode = .car
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(red: 0.95, green: 0.98, blue: 0.95), Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                Form {
                    Section {
                        HStack {
                            Image(systemName: "text.bubble.fill")
                                .foregroundColor(.green)
                                .font(.title3)
                            TextField("Title (e.g. Commute to work)", text: $title)
                        }
                        
                        HStack {
                            Image(systemName: "ruler.fill")
                                .foregroundColor(.green)
                                .font(.title3)
                            TextField("Distance in km", text: $distanceText)
                                .keyboardType(.decimalPad)
                        }
                        
                        HStack {
                            Image(systemName: transportIcon)
                                .foregroundColor(.green)
                                .font(.title3)
                            Picker("Transport mode", selection: $selectedMode) {
                                ForEach(TransportMode.allCases) { mode in
                                    HStack {
                                        Image(systemName: iconForMode(mode))
                                        Text(mode.displayName)
                                    }
                                    .tag(mode)
                                }
                            }
                        }
                    } header: {
                        HStack {
                            Image(systemName: "leaf.fill")
                                .foregroundColor(.green)
                            Text("Trip Details")
                        }
                        .font(.headline)
                    }
                    .listRowBackground(Color.white.opacity(0.7))
                    
                    if let errorMessage {
                        Section {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(errorMessage)
                                    .foregroundColor(.red)
                            }
                        }
                        .listRowBackground(Color.red.opacity(0.1))
                    }
                    
                    Section {
                        Button {
                            Task {
                                await saveActivity()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    HStack(spacing: 8) {
                                        Image(systemName: "leaf.fill")
                                        Text("Calculate & Save")
                                            .fontWeight(.semibold)
                                    }
                                }
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                        }
                        .disabled(isLoading || distanceText.isEmpty)
                        .background(buttonBackground)
                        .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.green)
                }
            }
        }
    }
    
    private var transportIcon: String {
        switch selectedMode {
        case .car:
            return "car.fill"
        case .air:
            return "airplane"
        case .rail:
            return "tram.fill"
        }
    }
    
    @ViewBuilder
    private var buttonBackground: some View {
        if isLoading || distanceText.isEmpty {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray)
        } else {
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: [Color.green, Color.green.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
    }
    
    private func iconForMode(_ mode: TransportMode) -> String {
        switch mode {
        case .car:
            return "car.fill"
        case .air:
            return "airplane"
        case .rail:
            return "tram.fill"
        }
    }
        
    private func saveActivity() async {
        errorMessage = nil
        
        guard let distance = Double(distanceText) else {
            errorMessage = "Please enter a valid number for distance."
            return
        }
        
        isLoading = true
        
        do {
            let response = try await EmissionsService.estimateEmissions(
                distanceKm: distance,
                mode: selectedMode
            )
            
            let entry = ActivityEntry(
                title: title.isEmpty ? "Untitled Trip" : title,
                mode: selectedMode,
                distanceKm: distance,
                emissionKg: response.co2e,
                date: Date()
            )
            
            entries.append(entry)
            isLoading = false
            dismiss()
        } catch let error as EmissionsError {
            isLoading = false
            switch error {
            case .invalidResponse:
                errorMessage = "Invalid response from server. Check console logs for details."
            case .decodingError(let message):
                errorMessage = "Error processing data. Check console for details."
                print("Decoding Error Details: \(message)")
            case .invalidURL:
                errorMessage = "Invalid request URL. Please try again."
            }
            print("EmissionsError: \(error)")
        } catch {
            isLoading = false
            errorMessage = "Failed to fetch emissions: \(error.localizedDescription)"
            print("Error: \(error)")
        }
    }
}

