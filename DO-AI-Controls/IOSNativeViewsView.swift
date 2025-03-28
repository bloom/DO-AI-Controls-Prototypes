//
//  IOSNativeViewsView.swift
//  DO-AI-Controls
//
//  Created by Paul Mayne on 3/28/25.
//

import SwiftUI

struct IOSNativeViewsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory = 0
    @State private var searchText = ""
    
    // Define the categories of UI elements
    let categories = [
        "Basic Controls",
        "Text & Images",
        "Layout & Navigation",
        "Data Entry",
        "Selection & Pickers",
        "Indicators",
        "Containers"
    ]
    
    // Accent color using the extension from ContentView
    let accentColor = Color(hex: "44C0FF")
    
    // Filter components based on search text
    var filteredComponents: [ComponentItem] {
        if searchText.isEmpty {
            return componentsList
        } else {
            return componentsList.filter { component in
                component.name.localizedCaseInsensitiveContains(searchText) ||
                component.category.localizedCaseInsensitiveContains(searchText) ||
                component.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // Components for the selected category
    var categoryComponents: [ComponentItem] {
        if selectedCategory == 0 {
            return filteredComponents
        } else {
            return filteredComponents.filter { $0.category == categories[selectedCategory] }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category selection
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        // All category
                        Button {
                            selectedCategory = 0
                        } label: {
                            Text("All")
                                .font(.subheadline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(selectedCategory == 0 ? accentColor : Color.gray.opacity(0.2))
                                )
                                .foregroundStyle(selectedCategory == 0 ? .white : .primary)
                        }
                        
                        // Other categories
                        ForEach(categories.indices, id: \.self) { index in
                            Button {
                                selectedCategory = index + 1
                            } label: {
                                Text(categories[index])
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(selectedCategory == index + 1 ? accentColor : Color.gray.opacity(0.2))
                                    )
                                    .foregroundStyle(selectedCategory == index + 1 ? .white : .primary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(Color(.systemBackground))
                
                // Component list
                List {
                    ForEach(categoryComponents) { component in
                        NavigationLink(destination: ComponentDetailView(component: component)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(component.name)
                                    .font(.headline)
                                
                                Text(component.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("iOS Native Views")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(accentColor)
                }
            }
            .searchable(text: $searchText, prompt: "Search UI components")
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

// Model for each UI component
struct ComponentItem: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let description: String
    let viewBuilder: AnyView
    
    init(name: String, category: String, description: String, view: some View) {
        self.name = name
        self.category = category
        self.description = description
        self.viewBuilder = AnyView(view)
    }
}

// Detail view for a single component
struct ComponentDetailView: View {
    let component: ComponentItem
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Component name and description
                VStack(alignment: .leading, spacing: 8) {
                    Text(component.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Category: \(component.category)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(component.description)
                        .font(.body)
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                Divider()
                    .padding(.horizontal)
                
                // Component preview
                VStack(spacing: 12) {
                    Text("Preview")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    component.viewBuilder
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationTitle(component.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// List of all available components
let componentsList: [ComponentItem] = [
    // MARK: - Basic Controls
    ComponentItem(
        name: "Button",
        category: "Basic Controls",
        description: "A control that performs an action when triggered.",
        view: VStack(spacing: 20) {
            Button("Standard Button") {
                print("Button tapped")
            }
            .buttonStyle(.bordered)
            
            Button("Prominent Button") {
                print("Prominent button tapped")
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                print("Icon button tapped")
            } label: {
                Image(systemName: "star.fill")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
        }
    ),
    
    ComponentItem(
        name: "Toggle",
        category: "Basic Controls",
        description: "A control that toggles between on and off states.",
        view: VStack(spacing: 20) {
            @State var toggleValue1 = true
            @State var toggleValue2 = false
            @State var toggleValue3 = true
            
            Toggle("Standard Toggle", isOn: $toggleValue1)
            
            Toggle("", isOn: $toggleValue2)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .blue))
            
            Toggle(isOn: $toggleValue3) {
                Label("Custom Toggle", systemImage: "bell.fill")
            }
        }
    ),
    
    ComponentItem(
        name: "Link",
        category: "Basic Controls",
        description: "A control for navigating to a URL.",
        view: VStack(spacing: 16) {
            Link("Apple Website", destination: URL(string: "https://www.apple.com")!)
                .font(.headline)
            
            Link(destination: URL(string: "https://www.apple.com")!) {
                Label("Visit Apple", systemImage: "apple.logo")
                    .foregroundColor(.blue)
            }
        }
    ),
    
    // MARK: - Text & Images
    ComponentItem(
        name: "Text",
        category: "Text & Images",
        description: "A view that displays one or more lines of read-only text.",
        view: VStack(alignment: .leading, spacing: 10) {
            Text("Regular Text")
            
            Text("Custom Font")
                .font(.system(size: 20, weight: .bold, design: .rounded))
            
            Text("Text with color")
                .foregroundColor(.blue)
            
            Text("Long text that demonstrates line wrapping behavior when the text is too long to fit on a single line.")
                .lineLimit(2)
            
            (Text("Combined ").bold() + Text("text ").italic() + Text("styles").foregroundColor(.red))
        }
    ),
    
    ComponentItem(
        name: "Label",
        category: "Text & Images",
        description: "A standard label for user interface items, consisting of an icon with text.",
        view: VStack(alignment: .leading, spacing: 16) {
            Label("Settings", systemImage: "gear")
            
            Label("Favorites", systemImage: "star.fill")
                .font(.title3)
            
            Label {
                Text("Custom Label")
                    .foregroundColor(.purple)
            } icon: {
                Circle()
                    .fill(Color.purple)
                    .frame(width: 20, height: 20)
            }
        }
    ),
    
    ComponentItem(
        name: "Image",
        category: "Text & Images",
        description: "A view that displays an image.",
        view: VStack(spacing: 20) {
            Image(systemName: "photo")
                .font(.largeTitle)
                .foregroundColor(.blue)
            
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
            
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .padding()
                .background(Color.yellow)
                .clipShape(Circle())
        }
    ),
    
    // MARK: - Layout & Navigation
    ComponentItem(
        name: "HStack and VStack",
        category: "Layout & Navigation",
        description: "Views that arrange their children in a horizontal or vertical line.",
        view: VStack(spacing: 20) {
            HStack(spacing: 10) {
                ForEach(1...4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.blue)
                        .frame(width: 30, height: 30)
                }
            }
            
            VStack(spacing: 10) {
                ForEach(1...3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.green)
                        .frame(width: 60, height: 30)
                }
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.purple)
                    .frame(width: 100, height: 100)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 50, height: 50)
                
                Text("ZStack")
                    .foregroundColor(.black)
                    .font(.caption)
            }
        }
    ),
    
    ComponentItem(
        name: "List",
        category: "Layout & Navigation",
        description: "A container that presents rows of data arranged in a single column.",
        view: VStack {
            List {
                Section(header: Text("Section 1")) {
                    ForEach(1...3, id: \.self) { item in
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Item \(item)")
                        }
                    }
                }
                
                Section(header: Text("Section 2")) {
                    ForEach(4...6, id: \.self) { item in
                        Text("Item \(item)")
                    }
                }
            }
            .frame(height: 300)
            .listStyle(InsetGroupedListStyle())
        }
    ),
    
    ComponentItem(
        name: "TabView",
        category: "Layout & Navigation",
        description: "A view that switches between multiple child views using interactive user interface elements.",
        view: VStack {
            @State var selectedTab = 0
            
            TabView(selection: $selectedTab) {
                VStack {
                    Image(systemName: "house.fill")
                        .font(.largeTitle)
                    Text("Home")
                }
                .tag(0)
                
                VStack {
                    Image(systemName: "person.fill")
                        .font(.largeTitle)
                    Text("Profile")
                }
                .tag(1)
                
                VStack {
                    Image(systemName: "gear")
                        .font(.largeTitle)
                    Text("Settings")
                }
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(height: 200)
            .background(Color(.systemGray5))
            .cornerRadius(12)
            
            // Tab indicators
            HStack(spacing: 20) {
                Button {
                    selectedTab = 0
                } label: {
                    VStack {
                        Image(systemName: "house\(selectedTab == 0 ? ".fill" : "")")
                        Text("Home")
                            .font(.caption)
                    }
                    .foregroundColor(selectedTab == 0 ? .blue : .gray)
                }
                
                Button {
                    selectedTab = 1
                } label: {
                    VStack {
                        Image(systemName: "person\(selectedTab == 1 ? ".fill" : "")")
                        Text("Profile")
                            .font(.caption)
                    }
                    .foregroundColor(selectedTab == 1 ? .blue : .gray)
                }
                
                Button {
                    selectedTab = 2
                } label: {
                    VStack {
                        Image(systemName: "gear")
                        Text("Settings")
                            .font(.caption)
                    }
                    .foregroundColor(selectedTab == 2 ? .blue : .gray)
                }
            }
            .padding(.top)
        }
    ),
    
    // MARK: - Data Entry
    ComponentItem(
        name: "TextField",
        category: "Data Entry",
        description: "A control that displays an editable text interface.",
        view: VStack(spacing: 20) {
            @State var text1 = ""
            @State var text2 = ""
            @State var text3 = ""
            
            TextField("Standard text field", text: $text1)
                .textFieldStyle(.roundedBorder)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search", text: $text2)
            }
            .padding(8)
            .background(Color(.systemGray5))
            .cornerRadius(8)
            
            TextField("Secure text field", text: $text3)
                .textFieldStyle(.roundedBorder)
                .privacySensitive()
        }
    ),
    
    ComponentItem(
        name: "TextEditor",
        category: "Data Entry",
        description: "A view that displays a full multiline text editor.",
        view: VStack {
            @State var longText = "This is a TextEditor view that allows multiline text editing with scrolling and various text editing capabilities."
            
            TextEditor(text: $longText)
                .frame(height: 150)
                .border(Color.gray, width: 1)
                .padding(.horizontal)
        }
    ),
    
    ComponentItem(
        name: "Slider",
        category: "Data Entry",
        description: "A control for selecting a value from a bounded linear range of values.",
        view: VStack(spacing: 20) {
            @State var sliderValue1 = 0.5
            @State var sliderValue2 = 0.7
            
            Slider(value: $sliderValue1)
                .padding(.horizontal)
            
            HStack {
                Image(systemName: "speaker.fill")
                Slider(value: $sliderValue2)
                Image(systemName: "speaker.wave.3.fill")
            }
            .padding(.horizontal)
            
            Text("Value: \(Int(sliderValue1 * 100))")
                .font(.caption)
        }
    ),
    
    ComponentItem(
        name: "Stepper",
        category: "Data Entry",
        description: "A control for incrementing and decrementing a value.",
        view: VStack(spacing: 20) {
            @State var stepperValue1 = 5
            @State var stepperValue2 = 0
            
            Stepper("Value: \(stepperValue1)", value: $stepperValue1, in: 0...10)
                .padding(.horizontal)
            
            Stepper {
                stepperValue2 += 1
            } onDecrement: {
                stepperValue2 -= 1
            } label: {
                Text("Custom Stepper: \(stepperValue2)")
            }
            .padding(.horizontal)
        }
    ),
    
    // MARK: - Selection & Pickers
    ComponentItem(
        name: "Picker",
        category: "Selection & Pickers",
        description: "A control for selecting from a set of mutually exclusive values.",
        view: VStack(spacing: 25) {
            @State var selectedOption1 = 0
            @State var selectedOption2 = "Red"
            
            Picker("Options", selection: $selectedOption1) {
                Text("Option 1").tag(0)
                Text("Option 2").tag(1)
                Text("Option 3").tag(2)
            }
            .pickerStyle(.segmented)
            
            let colors = ["Red", "Green", "Blue", "Yellow"]
            Picker("Colors", selection: $selectedOption2) {
                ForEach(colors, id: \.self) { color in
                    Text(color).tag(color)
                }
            }
            .pickerStyle(.menu)
            
            Text("Selected: \(colors[selectedOption1]), \(selectedOption2)")
                .font(.caption)
        }
    ),
    
    ComponentItem(
        name: "DatePicker",
        category: "Selection & Pickers",
        description: "A control for picking a date from a calendar interface.",
        view: VStack(spacing: 20) {
            @State var date1 = Date()
            @State var date2 = Date()
            
            DatePicker("Select Date", selection: $date1)
                .datePickerStyle(.compact)
                .padding(.horizontal)
            
            DatePicker("Date & Time", selection: $date2, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.compact)
                .padding(.horizontal)
        }
    ),
    
    ComponentItem(
        name: "ColorPicker",
        category: "Selection & Pickers",
        description: "A control for picking a color from the system color picker UI.",
        view: VStack {
            @State var selectedColor = Color.blue
            
            ColorPicker("Select Color", selection: $selectedColor)
                .padding()
            
            Rectangle()
                .fill(selectedColor)
                .frame(height: 100)
                .cornerRadius(8)
                .padding()
        }
    ),
    
    // MARK: - Indicators
    ComponentItem(
        name: "ProgressView",
        category: "Indicators",
        description: "A view that shows the progress towards completion of a task.",
        view: VStack(spacing: 30) {
            @State var progress = 0.6
            
            ProgressView()
                .scaleEffect(1.5)
            
            ProgressView("Loading...", value: progress, total: 1.0)
                .padding(.horizontal)
            
            ProgressView(value: progress, total: 1.0) {
                Text("Downloading...")
            } currentValueLabel: {
                Text("\(Int(progress * 100))%")
            }
            .padding(.horizontal)
            
            Button("Update Progress") {
                progress = progress < 0.9 ? progress + 0.1 : 0
            }
        }
    ),
    
    ComponentItem(
        name: "Gauge",
        category: "Indicators",
        description: "A view that shows a value within a range.",
        view: VStack(spacing: 25) {
            @State var gaugeValue = 0.7
            
            Gauge(value: gaugeValue, in: 0...1) {
                Text("Speed")
            } currentValueLabel: {
                Text("\(Int(gaugeValue * 100))%")
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("100")
            }
            .gaugeStyle(.accessoryCircular)
            .tint(.blue)
            
            Gauge(value: gaugeValue, in: 0...1) {
                Image(systemName: "speedometer")
            }
            .gaugeStyle(.accessoryLinear)
            .tint(.green)
            
            Button("Update Value") {
                gaugeValue = gaugeValue > 0.9 ? 0.1 : gaugeValue + 0.1
            }
        }
    ),
    
    ComponentItem(
        name: "Label Badge",
        category: "Indicators",
        description: "Small visual indicators for showing status or counts.",
        view: VStack(spacing: 20) {
            HStack(spacing: 30) {
                // Text with badge
                ZStack(alignment: .topTrailing) {
                    Text("Messages")
                        .font(.headline)
                    Text("5")
                        .font(.caption2)
                        .padding(5)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .offset(x: 10, y: -10)
                }
                
                // Icon with badge
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .font(.title2)
                    Circle()
                        .fill(Color.red)
                        .frame(width: 12, height: 12)
                        .offset(x: 5, y: -5)
                }
            }
            
            // Label with background badge
            Text("New")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(20)
        }
    ),
    
    // MARK: - Containers
    ComponentItem(
        name: "GroupBox",
        category: "Containers",
        description: "A container that groups controls with a visual styling.",
        view: VStack(spacing: 20) {
            GroupBox(label: Label("Settings", systemImage: "gear")) {
                VStack(alignment: .leading) {
                    Toggle("Wi-Fi", isOn: .constant(true))
                    Toggle("Bluetooth", isOn: .constant(false))
                    Toggle("Airplane Mode", isOn: .constant(false))
                }
                .padding(.top, 5)
            }
            .padding(.horizontal)
        }
    ),
    
    ComponentItem(
        name: "Form",
        category: "Containers",
        description: "A container for grouping controls used for data entry.",
        view: VStack {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: .constant("John Doe"))
                    TextField("Email", text: .constant("john@example.com"))
                }
                
                Section(header: Text("Preferences")) {
                    Toggle("Receive Notifications", isOn: .constant(true))
                    Toggle("Dark Mode", isOn: .constant(false))
                }
            }
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    ),
    
    ComponentItem(
        name: "ScrollView",
        category: "Containers",
        description: "A scrollable view.",
        view: VStack {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 15) {
                    ForEach(1...10, id: \.self) { index in
                        Text("Item \(index)")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .frame(height: 250)
            .border(Color.gray, width: 1)
        }
    ),
    
    ComponentItem(
        name: "Menu",
        category: "Containers",
        description: "A control for presenting a menu of actions.",
        view: VStack {
            Menu {
                Button("New", action: {})
                Button("Open", action: {})
                Button("Save", action: {})
                Divider()
                Button("Delete", action: {})
            } label: {
                Label("Menu", systemImage: "ellipsis.circle")
                    .font(.title2)
            }
        }
    )
]

#Preview {
    IOSNativeViewsView()
}