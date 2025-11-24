# CarbonTrack – Carbon Footprint Tracker

## Screenshots

## Brief Description

CarbonTrack is a SwiftUI iOS app that helps users track their carbon footprint by calculating CO₂ emissions for various transportation activities. Users can log trips by selecting a transport mode (car, air, or rail) and entering the distance traveled. The app uses the Climatiq API to fetch real-time emission estimates based on the selected transportation method.

**Purpose:** To raise awareness about personal carbon emissions and help users make more environmentally conscious transportation choices.

## Tools Used

- **Swift** - Programming language
- **SwiftUI** - UI framework
- **URLSession** - Network requests
- **async/await** - Asynchronous programming
- **Climatiq API** - Carbon emission calculation service
- **Codable** - JSON encoding/decoding

## Setup Instructions

1. **Clone or download this repository**
2. **Add your Climatiq API key:**
   - Go to `Config.example.swift`
   - Replace `YOUR_API_KEY_HERE` with your actual Climatiq API key
3. **Open the project in Xcode**
4. **Build and run** (⌘R)

## Features

### 1. ForEach with Reusable Subviews
- The app uses `ForEach` to iterate through activity entries
- `ActivityRowView` is a reusable subview component that displays each entry in a consistent format
- This promotes code reusability and maintainability

### 2. @State Property
- `@State` is used throughout the app to manage local view state:
  - `entries` array in `ContentView` to store all logged activities
  - `showingAdd` boolean to control sheet presentation
  - Form fields (`title`, `distanceText`, `selectedMode`) in `AddActivityView`
  - Loading and error states

### 3. Multiple User Input Components
- **TextField**: Two text fields for entering trip title and distance
- **Picker**: A picker component for selecting transport mode (car, air, or rail)
- Both components are bound to `@State` properties using the `$` binding syntax

### 4. @Binding
- `AddActivityView` receives a `@Binding` for the `entries` array
- This allows the child view to modify the parent's state directly
- When a new activity is saved, it's appended to the entries array in `ContentView`

### 5. API Integration with Service Class
- **Service Class**: `EmissionsService` is a static struct that manages all network requests
- **JSON Decoding**: Uses `Codable` protocol for automatic JSON encoding/decoding
- **Codable Structs**: 
  - `EmissionRequest` - Request body structure
  - `EmissionResponse` - Response structure
  - `ActivityEntry` - Local data model
- **Error Handling**: Implements proper error handling with custom `EmissionsError` enum
- **async/await**: Uses modern Swift concurrency for network calls

## Obstacles

1. **Type Conversion**: Converting `TextField` string input to `Double` for distance calculations required careful validation
2. **Error Handling**: Managing network errors and displaying user-friendly error messages
3. **API Response Parsing**: Ensuring the JSON response structure matches the `Codable` models
4. **State Management**: Coordinating state between parent and child views using `@Binding`
5. **Async Operations**: Properly handling async API calls within SwiftUI views using `Task`

## Future Additions

1. **Filtering & Sorting**: Add filters to view entries by week, month, or transport mode
2. **Charts & Visualizations**: Display emissions data in charts showing trends over time
3. **Goal Setting**: Allow users to set monthly or yearly emission reduction goals
4. **Export Data**: Enable users to export their emission data as CSV or PDF
5. **More Transport Modes**: Add additional transportation options (bus, bike, walking, etc.)
6. **Location Integration**: Automatically calculate distance using MapKit
7. **Social Features**: Share achievements and compare with friends
