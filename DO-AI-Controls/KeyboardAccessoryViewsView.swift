//
//  KeyboardAccessoryViewsView.swift
//  DO-AI-Controls
//
//  Created by Paul Mayne on 3/28/25.
//

import SwiftUI
import Combine

struct KeyboardAccessoryViewsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory = 0
    @State private var searchText = ""
    
    // Define the categories of keyboard accessories
    let categories = [
        "Text Input Accessories",
        "Formatting Bars",
        "Navigation Controls",
        "Selection Tools",
        "Custom Input Methods"
    ]
    
    // Accent color using the extension from ContentView
    let accentColor = Color(hex: "44C0FF")
    
    // Filter accessories based on search text
    var filteredComponents: [KeyboardAccessoryItem] {
        if searchText.isEmpty {
            return keyboardAccessoryList
        } else {
            return keyboardAccessoryList.filter { component in
                component.name.localizedCaseInsensitiveContains(searchText) ||
                component.category.localizedCaseInsensitiveContains(searchText) ||
                component.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // Components for the selected category
    var categoryComponents: [KeyboardAccessoryItem] {
        if selectedCategory == 0 {
            return filteredComponents
        } else {
            return filteredComponents.filter { $0.category == categories[selectedCategory - 1] }
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
                        NavigationLink(destination: KeyboardAccessoryViewsDetailView(accessory: component)) {
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
            .navigationTitle("Keyboard Accessories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(accentColor)
                }
            }
            .searchable(text: $searchText, prompt: "Search keyboard accessories")
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

// Model for each keyboard accessory
struct KeyboardAccessoryItem: Identifiable {
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

// Detail view for a keyboard accessory
struct KeyboardAccessoryViewsDetailView: View {
    let accessory: KeyboardAccessoryItem
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Accessory name and description
                VStack(alignment: .leading, spacing: 8) {
                    Text(accessory.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Category: \(accessory.category)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(accessory.description)
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
                        .padding(.horizontal)
                    
                    accessory.viewBuilder
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationTitle(accessory.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Keyboard Accessory Helper Views

// Simple Text Field with Accessory View
struct TextFieldWithAccessory: View {
    @State private var text: String = ""
    @FocusState private var isFocused: Bool
    let accessoryView: AnyView
    
    init(accessoryView: some View) {
        self.accessoryView = AnyView(accessoryView)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TextField("Tap to type...", text: $text)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($isFocused)
                .padding(.horizontal)
            
            if isFocused {
                accessoryView
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// Mimics UIKit's UIToolbar
struct ToolbarAccessoryView: View {
    var items: [ToolbarItem]
    var backgroundColor: Color = Color(.systemGray5)
    var height: CGFloat = 44
    var action: (String) -> Void
    
    var body: some View {
        HStack {
            ForEach(items) { item in
                if item.type == .flexibleSpace {
                    Spacer()
                } else if item.type == .fixedSpace {
                    Spacer().frame(width: item.width)
                } else {
                    Button {
                        action(item.id)
                    } label: {
                        if let systemImage = item.systemImage {
                            Image(systemName: systemImage)
                                .frame(height: height)
                                .padding(.horizontal, 12)
                                .contentShape(Rectangle())
                        } else if let title = item.title {
                            Text(title)
                                .frame(height: height)
                                .padding(.horizontal, 12)
                                .contentShape(Rectangle())
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .frame(height: height)
        .background(backgroundColor)
    }
    
    struct ToolbarItem: Identifiable {
        enum ItemType {
            case button, flexibleSpace, fixedSpace
        }
        
        var id: String
        var title: String?
        var systemImage: String?
        var type: ItemType = .button
        var width: CGFloat = 10
        
        static func flexibleSpace() -> ToolbarItem {
            ToolbarItem(id: UUID().uuidString, type: .flexibleSpace)
        }
        
        static func fixedSpace(_ width: CGFloat) -> ToolbarItem {
            ToolbarItem(id: UUID().uuidString, type: .fixedSpace, width: width)
        }
    }
}

// KeyboardAccessoryObserver for detecting keyboard appearance/disappearance
class KeyboardAccessoryObserver: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    @Published var isKeyboardVisible = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    self?.keyboardHeight = keyboardFrame.height
                    self?.isKeyboardVisible = true
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                self?.keyboardHeight = 0
                self?.isKeyboardVisible = false
            }
            .store(in: &cancellables)
    }
}

// MARK: - Example View Components

// Basic Toolbar Example
struct BasicToolbarExample: View {
    @State private var text = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack {
            TextField("Tap to type...", text: $text)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($isTextFieldFocused)
                .padding(.horizontal)
            
            if isTextFieldFocused {
                ToolbarAccessoryView(
                    items: [
                        .init(id: "cancel", title: "Cancel"),
                        .flexibleSpace(),
                        .init(id: "done", title: "Done")
                    ]
                ) { action in
                    if action == "done" || action == "cancel" {
                        isTextFieldFocused = false
                    }
                }
            }
        }
    }
}

// Done Button Bar Example
struct DoneButtonBarExample: View {
    @State private var text = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            TextField("Tap to type...", text: $text)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($isFocused)
                .padding(.horizontal)
            
            if isFocused {
                HStack {
                    Spacer()
                    Button("Done") {
                        isFocused = false
                    }
                    .padding()
                }
                .background(Color(.systemGray5))
            }
        }
    }
}

// Navigation Control Example
struct NavigationControlExample: View {
    @State private var firstField = ""
    @State private var secondField = ""
    @State private var thirdField = ""
    @FocusState private var focusedField: Field?
    
    enum Field: Int, Hashable {
        case first, second, third
    }
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("First Field", text: $firstField)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($focusedField, equals: .first)
                .padding(.horizontal)
            
            TextField("Second Field", text: $secondField)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($focusedField, equals: .second)
                .padding(.horizontal)
            
            TextField("Third Field", text: $thirdField)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($focusedField, equals: .third)
                .padding(.horizontal)
            
            if focusedField != nil {
                HStack {
                    Button {
                        if let current = focusedField {
                            switch current {
                            case .second: focusedField = .first
                            case .third: focusedField = .second
                            default: break
                            }
                        }
                    } label: {
                        Image(systemName: "chevron.up")
                            .frame(height: 44)
                            .padding(.horizontal, 20)
                    }
                    .disabled(focusedField == .first)
                    
                    Button {
                        if let current = focusedField {
                            switch current {
                            case .first: focusedField = .second
                            case .second: focusedField = .third
                            default: break
                            }
                        }
                    } label: {
                        Image(systemName: "chevron.down")
                            .frame(height: 44)
                            .padding(.horizontal, 20)
                    }
                    .disabled(focusedField == .third)
                    
                    Spacer()
                    
                    Button("Done") {
                        focusedField = nil
                    }
                    .padding(.horizontal, 20)
                }
                .foregroundColor(.primary)
                .background(Color(.systemGray5))
            }
        }
    }
}

// Text Formatting Bar Example
struct TextFormattingBarExample: View {
    @State private var text = "Tap to type and format text..."
    @State private var isBold = false
    @State private var isItalic = false
    @State private var isUnderlined = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            TextEditor(text: $text)
                .frame(height: 100)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .font(
                    .system(
                        size: 16,
                        weight: isBold ? .bold : .regular,
                        design: .default
                    ).italic(isItalic)
                )
                .underline(isUnderlined)
                .focused($isFocused)
                .padding(.horizontal)
            
            if isFocused {
                HStack(spacing: 20) {
                    Button {
                        isBold.toggle()
                    } label: {
                        Image(systemName: "bold")
                            .foregroundColor(isBold ? .blue : .primary)
                    }
                    
                    Button {
                        isItalic.toggle()
                    } label: {
                        Image(systemName: "italic")
                            .foregroundColor(isItalic ? .blue : .primary)
                    }
                    
                    Button {
                        isUnderlined.toggle()
                    } label: {
                        Image(systemName: "underline")
                            .foregroundColor(isUnderlined ? .blue : .primary)
                    }
                    
                    Spacer()
                    
                    Button("Done") {
                        isFocused = false
                    }
                }
                .padding()
                .background(Color(.systemGray5))
            }
        }
    }
}

// Character Picker Bar Example
struct CharacterPickerBarExample: View {
    @State private var text = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Tap to type...", text: $text)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($isFocused)
                .padding(.horizontal)
            
            if isFocused {
                let specialChars = ["€", "£", "¥", "©", "®", "™", "°", "•", "★", "♥", "☀", "☁"]
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(specialChars, id: \.self) { char in
                            Button(char) {
                                text += char
                            }
                            .font(.system(size: 20))
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGray5))
            }
        }
    }
}

// Date Picker Accessory Example
struct DatePickerAccessoryExample: View {
    @State private var text = ""
    @State private var selectedDate = Date()
    @FocusState private var isFocused: Bool
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Select a date...", text: $text)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($isFocused)
                .padding(.horizontal)
                .onChange(of: selectedDate) { _, newValue in
                    text = dateFormatter.string(from: newValue)
                }
            
            if isFocused {
                VStack {
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(height: 150)
                    
                    Button("Done") {
                        isFocused = false
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding()
                }
                .background(Color(.systemGray5))
            }
        }
    }
}

// Color Picker Accessory Example
struct ColorPickerAccessoryExample: View {
    @State private var text = "Select a color..."
    @State private var selectedColor = Color.blue
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("", text: $text)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($isFocused)
                .padding(.horizontal)
                .foregroundColor(selectedColor)
            
            if isFocused {
                VStack {
                    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple, .pink, .black, .gray]
                    
                    HStack(spacing: 12) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: selectedColor == color ? 2 : 0)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                    text = color.description.capitalized
                                }
                        }
                    }
                    .padding()
                    
                    HStack {
                        Spacer()
                        Button("Done") {
                            isFocused = false
                        }
                        .padding()
                    }
                }
                .background(Color(.systemGray5))
            }
        }
    }
}

// Emoji Keyboard Example
struct EmojiKeyboardExample: View {
    @State private var text = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Add emojis to your text...", text: $text)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($isFocused)
                .padding(.horizontal)
            
            if isFocused {
                VStack {
                    let emojis = ["😀", "😂", "❤️", "👍", "👋", "🙏", "⭐️", "🔥", "🎉", "✅", "🚀", "💯"]
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: 15) {
                        ForEach(emojis, id: \.self) { emoji in
                            Text(emoji)
                                .font(.title)
                                .onTapGesture {
                                    text += emoji
                                }
                        }
                    }
                    .padding()
                    
                    HStack {
                        Spacer()
                        Button("Done") {
                            isFocused = false
                        }
                        .padding()
                    }
                }
                .background(Color(.systemGray5))
            }
        }
    }
}

// Quick Response Bar Example
struct QuickResponseBarExample: View {
    @State private var text = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Type or select a response...", text: $text)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($isFocused)
                .padding(.horizontal)
            
            if isFocused {
                VStack {
                    let quickResponses = ["Thanks!", "I'll check later", "Sounds good", "On my way", "Can't wait!"]
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(quickResponses, id: \.self) { response in
                                Button(response) {
                                    text = response
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color(.systemGray4))
                                .cornerRadius(16)
                            }
                        }
                        .padding()
                    }
                    
                    HStack {
                        Spacer()
                        Button("Done") {
                            isFocused = false
                        }
                        .padding()
                    }
                }
                .background(Color(.systemGray5))
            }
        }
    }
}

// Segmented Control Accessory Example
struct SegmentedControlAccessoryExample: View {
    @State private var text = ""
    @State private var selectedMode = 0
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Switch between input modes...", text: $text)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($isFocused)
                .padding(.horizontal)
            
            if isFocused {
                VStack {
                    Picker("Input Mode", selection: $selectedMode) {
                        Text("Text").tag(0)
                        Text("Emoji").tag(1)
                        Text("Hashtags").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    if selectedMode == 0 {
                        // Text suggestions
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                Button("Hello") { text += "Hello " }
                                Button("Thanks") { text += "Thanks " }
                                Button("Please") { text += "Please " }
                                Button("Sorry") { text += "Sorry " }
                                Spacer()
                            }
                            .padding()
                        }
                    } else if selectedMode == 1 {
                        // Emoji suggestions
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                Button("😀") { text += "😀" }
                                Button("👍") { text += "👍" }
                                Button("❤️") { text += "❤️" }
                                Button("🎉") { text += "🎉" }
                                Spacer()
                            }
                            .font(.title2)
                            .padding()
                        }
                    } else {
                        // Hashtag suggestions
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                Button("#awesome") { text += "#awesome " }
                                Button("#cool") { text += "#cool " }
                                Button("#fun") { text += "#fun " }
                                Button("#great") { text += "#great " }
                                Spacer()
                            }
                            .padding()
                        }
                    }
                    
                    HStack {
                        Spacer()
                        Button("Done") {
                            isFocused = false
                        }
                        .padding()
                    }
                }
                .background(Color(.systemGray5))
            }
        }
    }
}

// Progress Indicator Bar Example
struct ProgressIndicatorBarExample: View {
    @State private var currentStep = 1
    @State private var field1 = ""
    @State private var field2 = ""
    @State private var field3 = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading) {
                Text("Step \(currentStep) of 3")
                    .font(.headline)
                
                if currentStep == 1 {
                    Text("Enter your name")
                    TextField("Name", text: $field1)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .focused($isFocused)
                } else if currentStep == 2 {
                    Text("Enter your email")
                    TextField("Email", text: $field2)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .focused($isFocused)
                } else {
                    Text("Enter your phone number")
                    TextField("Phone", text: $field3)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .focused($isFocused)
                }
            }
            .padding(.horizontal)
            
            if isFocused {
                VStack {
                    // Progress indicator
                    HStack(spacing: 4) {
                        ForEach(1...3, id: \.self) { step in
                            Capsule()
                                .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                                .frame(height: 4)
                        }
                    }
                    .padding()
                    
                    // Navigation buttons
                    HStack {
                        if currentStep > 1 {
                            Button("Previous") {
                                withAnimation {
                                    currentStep -= 1
                                }
                            }
                        }
                        
                        Spacer()
                        
                        if currentStep < 3 {
                            Button("Next") {
                                withAnimation {
                                    currentStep += 1
                                }
                            }
                        } else {
                            Button("Done") {
                                isFocused = false
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGray5))
            }
        }
    }
}

// Rich Text Editor Bar Example
struct RichTextEditorBarExample: View {
    @State private var text = "Tap to format this text with the rich editor toolbar..."
    @State private var showToolbar = false
    @State private var isBold = false
    @State private var isItalic = false
    @State private var isUnderlined = false
    @State private var textAlignment: TextAlignment = .leading
    @State private var textColor: Color = .primary
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            TextEditor(text: $text)
                .frame(height: 120)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .font(.system(
                    size: 16,
                    weight: isBold ? .bold : .regular,
                    design: .default
                ).italic(isItalic))
                .underline(isUnderlined)
                .foregroundColor(textColor)
                .multilineTextAlignment(textAlignment)
                .focused($isFocused)
                .onChange(of: isFocused) { _, newValue in
                    showToolbar = newValue
                }
                .padding(.horizontal)
            
            if showToolbar {
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            // Bold button
                            Button {
                                isBold.toggle()
                            } label: {
                                Image(systemName: "bold")
                                    .foregroundColor(isBold ? .blue : .primary)
                            }
                            
                            // Italic button
                            Button {
                                isItalic.toggle()
                            } label: {
                                Image(systemName: "italic")
                                    .foregroundColor(isItalic ? .blue : .primary)
                            }
                            
                            // Underline button
                            Button {
                                isUnderlined.toggle()
                            } label: {
                                Image(systemName: "underline")
                                    .foregroundColor(isUnderlined ? .blue : .primary)
                            }
                            
                            Divider()
                                .frame(height: 20)
                            
                            // Alignment buttons
                            Group {
                                Button {
                                    textAlignment = .leading
                                } label: {
                                    Image(systemName: "text.alignleft")
                                        .foregroundColor(textAlignment == .leading ? .blue : .primary)
                                }
                                
                                Button {
                                    textAlignment = .center
                                } label: {
                                    Image(systemName: "text.aligncenter")
                                        .foregroundColor(textAlignment == .center ? .blue : .primary)
                                }
                                
                                Button {
                                    textAlignment = .trailing
                                } label: {
                                    Image(systemName: "text.alignright")
                                        .foregroundColor(textAlignment == .trailing ? .blue : .primary)
                                }
                            }
                            
                            Divider()
                                .frame(height: 20)
                            
                            // Color selector buttons
                            Group {
                                ForEach([Color.primary, .red, .blue, .green], id: \.self) { color in
                                    Button {
                                        textColor = color
                                    } label: {
                                        Circle()
                                            .fill(color)
                                            .frame(width: 20, height: 20)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: textColor == color ? 2 : 0)
                                            )
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    
                    HStack {
                        Spacer()
                        Button("Done") {
                            isFocused = false
                        }
                        .padding()
                    }
                }
                .background(Color(.systemGray5))
            }
        }
    }
}

// MARK: - List of Keyboard Accessory Items

// List of keyboard accessory components
let keyboardAccessoryList: [KeyboardAccessoryItem] = [
    // MARK: - Text Input Accessories
    KeyboardAccessoryItem(
        name: "Basic Toolbar",
        category: "Text Input Accessories",
        description: "A simple toolbar with common text input actions.",
        view: BasicToolbarExample()
    ),
    
    KeyboardAccessoryItem(
        name: "Done Button Bar",
        category: "Text Input Accessories",
        description: "A simple bar with only a 'Done' button to dismiss the keyboard.",
        view: DoneButtonBarExample()
    ),
    
    KeyboardAccessoryItem(
        name: "Previous/Next Navigation",
        category: "Navigation Controls",
        description: "A toolbar with previous and next buttons for navigating between text fields.",
        view: NavigationControlExample()
    ),
    
    // MARK: - Formatting Bars
    KeyboardAccessoryItem(
        name: "Text Formatting Bar",
        category: "Formatting Bars",
        description: "A toolbar with text formatting options like bold, italic, and underline.",
        view: TextFormattingBarExample()
    ),
    
    KeyboardAccessoryItem(
        name: "Character Picker Bar",
        category: "Text Input Accessories",
        description: "A toolbar with special characters that can be inserted into text.",
        view: CharacterPickerBarExample()
    ),
    
    // MARK: - Selection Tools
    KeyboardAccessoryItem(
        name: "Date Picker Accessory",
        category: "Selection Tools",
        description: "An accessory view with a date picker for quick date selection.",
        view: DatePickerAccessoryExample()
    ),
    
    KeyboardAccessoryItem(
        name: "Color Picker Accessory",
        category: "Selection Tools",
        description: "An accessory view with color swatches for quick color selection.",
        view: ColorPickerAccessoryExample()
    ),
    
    // MARK: - Custom Input Methods
    KeyboardAccessoryItem(
        name: "Emoji Keyboard",
        category: "Custom Input Methods",
        description: "A custom emoji selector as a keyboard accessory.",
        view: EmojiKeyboardExample()
    ),
    
    KeyboardAccessoryItem(
        name: "Quick Response Bar",
        category: "Text Input Accessories",
        description: "A bar with preset responses for quick text entry.",
        view: QuickResponseBarExample()
    ),
    
    // MARK: - Navigation Controls
    KeyboardAccessoryItem(
        name: "Segmented Control Accessory",
        category: "Navigation Controls",
        description: "An accessory with a segmented control for switching between different input modes.",
        view: SegmentedControlAccessoryExample()
    ),
    
    KeyboardAccessoryItem(
        name: "Progress Indicator Bar",
        category: "Navigation Controls",
        description: "A bar that shows progress through a multi-step input process.",
        view: ProgressIndicatorBarExample()
    ),
    
    // MARK: - Formatting Bars
    KeyboardAccessoryItem(
        name: "Rich Text Editor Bar",
        category: "Formatting Bars",
        description: "A comprehensive bar for rich text editing with multiple formatting options.",
        view: RichTextEditorBarExample()
    )
]

// Helper extensions for underline
extension View {
    func underline(_ active: Bool = true) -> some View {
        if active {
            return self.underline()
        } else {
            return self
        }
    }
}

#Preview {
    KeyboardAccessoryViewsView()
}