import SwiftUI

struct ContentView: View {
    @State private var entries: [ActivityEntry] = []
    @State private var showingAdd = false
    @State private var editingEntry: ActivityEntry?
    
    private var totalEmission: Double {
        entries.reduce(0) { $0 + $1.emissionKg }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                mainContent
            }
            .navigationTitle("CarbonTrack")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    addButton
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddActivityView(entries: $entries)
            }
            .sheet(item: $editingEntry) { entry in
                EditActivitySheet(
                    selectedColor: Binding(
                        get: {
                            entries.first(where: { $0.id == entry.id })?.color ?? .green
                        },
                        set: { newColor in
                            if let index = entries.firstIndex(where: { $0.id == entry.id }) {
                                entries[index].color = newColor
                            }
                        }
                    ),
                    selectedTitle: Binding(
                        get: {
                            entries.first(where: { $0.id == entry.id })?.title ?? ""
                        },
                        set: { newTitle in
                            if let index = entries.firstIndex(where: { $0.id == entry.id }) {
                                entries[index].title = newTitle
                            }
                        }
                    )
                )
            }
        }
    }
        
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(red: 0.95, green: 0.98, blue: 0.95), Color.white],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            summaryCard
            entriesList
        }
    }
    
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                Text("Total Emissions")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(totalEmission, specifier: "%.2f")")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                Text("kg CO₂e")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(cardBackground)
        .overlay(cardBorder)
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white)
            .shadow(color: Color.green.opacity(0.1), radius: 10, x: 0, y: 4)
    }
    
    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(
                LinearGradient(
                    colors: [Color.green.opacity(0.3), Color.green.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 2
            )
    }
    
    @ViewBuilder
    private var entriesList: some View {
        if entries.isEmpty {
            emptyStateView
        } else {
            entriesListView
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "leaf.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green.opacity(0.3))
            VStack(spacing: 8) {
                Text("Start Tracking Your Carbon Footprint")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Tap the + button to add your first trip")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var entriesListView: some View {
        List {
            ForEach(entries) { entry in
                rowView(for: entry)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(Visibility.hidden)
    }
    
    @ViewBuilder
    private func rowView(for entry: ActivityEntry) -> some View {
        ActivityRowView(entry: entry) {
            editingEntry = entry
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                withAnimation {
                    if let index = entries.firstIndex(where: { $0.id == entry.id }) {
                        entries.remove(at: index)
                    }
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private var addButton: some View {
        Button {
            showingAdd = true
        } label: {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .foregroundColor(.green)
        }
    }
}

struct ActivityRowView: View {
    let entry: ActivityEntry
    let onEdit: () -> Void
    
    private var modeIcon: String {
        switch entry.mode {
        case .car:
            return "car.fill"
        case .air:
            return "airplane"
        case .rail:
            return "tram.fill"
        }
    }
    
    private func formatEmission(_ value: Double) -> String {
        if value >= 1000 {
            // For large numbers, use 1 decimal place and add comma formatting
            return String(format: "%.1f", value)
        } else {
            // For smaller numbers, use 2 decimal places
            return String(format: "%.2f", value)
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(entry.color.color.opacity(0.15))
                    .frame(width: 50, height: 50)
                Image(systemName: modeIcon)
                    .foregroundColor(entry.color.color)
                    .font(.title3)
            }
            .fixedSize(horizontal: true, vertical: false)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(entry.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 8) {
                    Image(systemName: "ruler")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(entry.distanceKm, specifier: "%.1f") km")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                    Text("•")
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    Text(entry.mode.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer(minLength: 8)
            
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(formatEmission(entry.emissionKg))
                    .font(entry.emissionKg >= 1000 ? .headline : .title3)
                    .fontWeight(.bold)
                    .foregroundColor(entry.color.color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("kg CO₂e")
                    .font(.caption2)
                    .foregroundColor(entry.color.color.opacity(0.8))
                    .lineLimit(1)
            }
            .fixedSize(horizontal: true, vertical: false)
            
            Button(action: onEdit) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(entry.color.color)
                    .font(.title3)
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

#Preview {
    ContentView()
}

