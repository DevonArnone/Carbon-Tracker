import SwiftUI

struct EditActivitySheet: View {
    @Binding var selectedColor: ActivityColor
    @Binding var selectedTitle: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Text("Activity Info")
                    .font(.title)
                    .foregroundStyle(selectedColor.color)
                    .padding(.top, 8)
                
                VStack(spacing: 24) {
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 88))
                        .foregroundStyle(selectedColor.color)
                    
                    TextField("Activity Title", text: $selectedTitle)
                        .textFieldStyle(.plain)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray5))
                        }
                        .foregroundStyle(selectedColor.color)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                
                VStack {
                    Text("Color")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)
                    
                    ColorChooser(selectedColor: $selectedColor)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .navigationTitle("Edit Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(selectedColor.color)
                }
            }
        }
    }
}

struct ColorChooser: View {
    @Binding var selectedColor: ActivityColor
    
    private let colors: [ActivityColor] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .indigo, .teal, .gray]
    
    var body: some View {
        HStack(spacing: 16) {
            ForEach(colors, id: \.self) { color in
                Button {
                    selectedColor = color
                } label: {
                    Circle()
                        .fill(color.color)
                        .frame(width: 50, height: 50)
                        .overlay {
                            if selectedColor == color {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20, weight: .bold))
                            }
                        }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    @Previewable @State var selectedColor: ActivityColor = .green
    @Previewable @State var selectedTitle: String = "Commute to work"
    
    EditActivitySheet(selectedColor: $selectedColor, selectedTitle: $selectedTitle)
        .preferredColorScheme(.light)
}

