//
//  KeyboardAccessoriesView.swift
//  DO-AI-Controls
//
//  Created by Paul Mayne on 3/28/25.
//

import SwiftUI

struct KeyboardAccessoriesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedExample: KeyboardAccessoryExample? = nil
    @State private var searchText = ""
    
    // Accent color
    let accentColor = Color(hex: "44C0FF")
    
    // List of keyboard accessory examples
    let examples: [KeyboardAccessoryExample] = [
        KeyboardAccessoryExample(
            title: "Basic Done Button",
            subtitle: "A simple Done button to dismiss the keyboard",
            description: "The most common keyboard accessory - a toolbar with a Done button that dismisses the keyboard when tapped.",
            icon: "keyboard"
        ),
        KeyboardAccessoryExample(
            title: "Navigation Controls",
            subtitle: "Previous, Next, and Done buttons for form navigation",
            description: "Navigation controls that allow users to move between text fields in a form without having to dismiss the keyboard.",
            icon: "arrow.up.arrow.down"
        ),
        KeyboardAccessoryExample(
            title: "Text Formatting",
            subtitle: "Text formatting tools like bold, italic, and underline",
            description: "Text formatting controls that allow users to format their text without having to switch to a different view or menu.",
            icon: "textformat"
        ),
        KeyboardAccessoryExample(
            title: "Custom Input Options",
            subtitle: "Quick input buttons for common responses",
            description: "Customized input options that provide quick access to frequently used responses or text patterns.",
            icon: "text.badge.plus"
        ),
        KeyboardAccessoryExample(
            title: "Segmented Control",
            subtitle: "Segmented control for switching input modes",
            description: "A segmented control that allows users to switch between different input modes without dismissing the keyboard.",
            icon: "switch.2"
        ),
        KeyboardAccessoryExample(
            title: "Character Picker",
            subtitle: "Quick access to special characters",
            description: "A character picker that provides access to special characters that might not be easily accessible on the standard keyboard.",
            icon: "character"
        ),
        KeyboardAccessoryExample(
            title: "Multiple Toolbars",
            subtitle: "Multiple toolbar rows for different functions",
            description: "Multiple toolbar rows that provide different functions, such as formatting, navigation, and special characters.",
            icon: "square.stack"
        ),
        KeyboardAccessoryExample(
            title: "Context-Aware Accessories",
            subtitle: "Different accessories based on input type",
            description: "Different accessories based on the type of input, such as a date picker for date fields or a currency picker for amount fields.",
            icon: "arrow.up.doc.on.clipboard"
        )
    ]
    
    // Filtered examples based on search
    var filteredExamples: [KeyboardAccessoryExample] {
        if searchText.isEmpty {
            return examples
        } else {
            return examples.filter { example in
                example.title.localizedCaseInsensitiveContains(searchText) ||
                example.subtitle.localizedCaseInsensitiveContains(searchText) ||
                example.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredExamples) { example in
                    Button {
                        selectedExample = example
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: example.icon)
                                .font(.title2)
                                .foregroundColor(accentColor)
                                .frame(width: 40)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(example.title)
                                    .font(.headline)
                                
                                Text(example.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.plain)
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
            .sheet(item: $selectedExample) { example in
                KeyboardAccessoryDetailView(example: example)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

// Model for keyboard accessory examples
struct KeyboardAccessoryExample: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let description: String
    let icon: String
}

// Detail view for a keyboard accessory example
struct KeyboardAccessoryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let example: KeyboardAccessoryExample
    let accentColor = Color(hex: "44C0FF")
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Example header
                    VStack(spacing: 8) {
                        Image(systemName: example.icon)
                            .font(.system(size: 48))
                            .foregroundColor(accentColor)
                            .padding(.bottom, 8)
                        
                        Text(example.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(example.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text(example.description)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                            .padding(.horizontal)
                    }
                    .padding()
                    
                    Divider()
                    
                    // Example demo
                    VStack(spacing: 16) {
                        Text("Interactive Demo")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        getExampleView(for: example.title)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle(example.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(accentColor)
                }
            }
        }
    }
    
    // Helper to return the appropriate example view
    @ViewBuilder
    func getExampleView(for title: String) -> some View {
        switch title {
        case "Basic Done Button":
            BasicDoneButtonExample()
        case "Navigation Controls":
            NavigationControlsExample()
        case "Text Formatting":
            TextFormattingExample()
        case "Custom Input Options":
            CustomInputOptionsExample()
        case "Segmented Control":
            SegmentedControlExample()
        case "Character Picker":
            CharacterPickerExample()
        case "Multiple Toolbars":
            MultipleToolbarsExample()
        case "Context-Aware Accessories":
            ContextAwareAccessoriesExample()
        default:
            Text("Example not implemented")
                .italic()
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Example Implementations

// 1. Basic Done Button Example
struct BasicDoneButtonExample: View {
    @State private var text = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Tap the text field below to see a simple 'Done' button appear above the keyboard")
                .multilineTextAlignment(.center)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            TextField("Tap to type", text: $text)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($isTextFieldFocused)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()  // This pushes the done button to the right
                        
                        Button("Done") {
                            isTextFieldFocused = false
                        }
                    }
                }
            
            if !isTextFieldFocused && !text.isEmpty {
                Text("You entered: \(text)")
                    .foregroundStyle(.secondary)
                    .padding(.top)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
        .frame(height: 200)
    }
}

// 2. Navigation Controls Example
struct NavigationControlsExample: View {
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @FocusState private var focusedField: FormField?
    
    enum FormField {
        case name, email, phone
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Use the previous and next buttons to navigate between fields")
                .multilineTextAlignment(.center)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Group {
                TextField("Name", text: $name)
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .email
                    }
                
                TextField("Email", text: $email)
                    .focused($focusedField, equals: .email)
                    .keyboardType(.emailAddress)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .phone
                    }
                
                TextField("Phone", text: $phone)
                    .focused($focusedField, equals: .phone)
                    .keyboardType(.phonePad)
                    .submitLabel(.done)
                    .onSubmit {
                        focusedField = nil
                    }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    // Previous button
                    Button(action: focusPreviousField) {
                        Image(systemName: "chevron.up")
                    }
                    .disabled(!canFocusPrevious)
                    
                    // Next button
                    Button(action: focusNextField) {
                        Image(systemName: "chevron.down")
                    }
                    .disabled(!canFocusNext)
                    
                    Spacer()  // This pushes the done button to the right
                    
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
        .frame(height: 230)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = .name
            }
        }
    }
    
    var canFocusPrevious: Bool {
        switch focusedField {
        case .email: return true
        case .phone: return true
        default: return false
        }
    }
    
    var canFocusNext: Bool {
        switch focusedField {
        case .name: return true
        case .email: return true
        default: return false
        }
    }
    
    func focusPreviousField() {
        switch focusedField {
        case .email:
            focusedField = .name
        case .phone:
            focusedField = .email
        default:
            break
        }
    }
    
    func focusNextField() {
        switch focusedField {
        case .name:
            focusedField = .email
        case .email:
            focusedField = .phone
        default:
            break
        }
    }
}

// 3. Text Formatting Example
struct TextFormattingExample: View {
    @State private var text = "Tap here to start typing and formatting..."
    @State private var isBold = false
    @State private var isItalic = false
    @State private var isUnderlined = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Use the formatting buttons to style your text")
                .multilineTextAlignment(.center)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            TextEditor(text: $text)
                .font(.system(
                    size: 16,
                    weight: isBold ? .bold : .regular,
                    design: .default
                ).italic(isItalic))
                .frame(minHeight: 100)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($isTextFieldFocused)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isTextFieldFocused ? Color.blue : Color.clear, lineWidth: 1)
                )
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        // Bold button
                        Button(action: { isBold.toggle() }) {
                            Image(systemName: isBold ? "bold" : "bold")
                                .foregroundColor(isBold ? .blue : .primary)
                        }
                        
                        // Italic button
                        Button(action: { isItalic.toggle() }) {
                            Image(systemName: isItalic ? "italic" : "italic")
                                .foregroundColor(isItalic ? .blue : .primary)
                        }
                        
                        // Underline button
                        Button(action: { isUnderlined.toggle() }) {
                            Image(systemName: isUnderlined ? "underline" : "underline")
                                .foregroundColor(isUnderlined ? .blue : .primary)
                        }
                        
                        Spacer()
                        
                        Button("Done") {
                            isTextFieldFocused = false
                        }
                    }
                }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
        .frame(height: 230)
    }
}

// 4. Custom Input Options Example
struct CustomInputOptionsExample: View {
    @State private var message = ""
    @FocusState private var isTextFieldFocused: Bool
    
    let quickResponses = [
        "Thank you!",
        "I'll check and get back to you.",
        "Sounds good to me.",
        "Could you clarify that?",
        "I'm running late."
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Select from common responses or type your own")
                .multilineTextAlignment(.center)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            TextField("Type or select a message", text: $message)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($isTextFieldFocused)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(quickResponses, id: \.self) { response in
                                    Button(response) {
                                        message = response
                                    }
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(16)
                                    .foregroundColor(.primary)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button("Done") {
                            isTextFieldFocused = false
                        }
                    }
                }
            
            if !isTextFieldFocused && !message.isEmpty {
                Text("Selected message: \(message)")
                    .foregroundStyle(.secondary)
                    .padding(.top)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
        .frame(height: 200)
    }
}

// 5. Segmented Control Example
struct SegmentedControlExample: View {
    @State private var text = ""
    @State private var selectedMode = 0
    @FocusState private var isTextFieldFocused: Bool
    
    let modes = ["Text", "Emoji", "Tags"]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Switch between different input modes")
                .multilineTextAlignment(.center)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            TextField("Type or select input based on mode", text: $text)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($isTextFieldFocused)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        // Mode picker
                        Picker("Mode", selection: $selectedMode) {
                            ForEach(0..<modes.count, id: \.self) { index in
                                Text(modes[index]).tag(index)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        Spacer()
                        
                        Button("Done") {
                            isTextFieldFocused = false
                        }
                    }
                    
                    // Content toolbar based on selected mode
                    ToolbarItemGroup(placement: .keyboard) {
                        switch selectedMode {
                        case 0:  // Text mode
                            Button("Hello") { text += "Hello " }
                            Button("Thanks") { text += "Thanks " }
                            Spacer()
                        case 1:  // Emoji mode
                            Button("😊") { text += "😊" }
                            Button("👍") { text += "👍" }
                            Button("❤️") { text += "❤️" }
                            Spacer()
                        case 2:  // Tags mode
                            Button("#ios") { text += "#ios " }
                            Button("#swift") { text += "#swift " }
                            Button("#swiftui") { text += "#swiftui " }
                            Spacer()
                        default:
                            EmptyView()
                        }
                    }
                }
            
            if !isTextFieldFocused && !text.isEmpty {
                Text("You entered: \(text)")
                    .foregroundStyle(.secondary)
                    .padding(.top)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
        .frame(height: 200)
    }
}

// 6. Character Picker Example
struct CharacterPickerExample: View {
    @State private var text = ""
    @FocusState private var isTextFieldFocused: Bool
    
    let specialCharsGroups = [
        ["€", "£", "¥", "$", "¢"],
        ["©", "®", "™", "℠", "℗"],
        ["°", "′", "″", "±", "≈"],
        ["≠", "≤", "≥", "×", "÷"]
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Insert special characters without switching keyboards")
                .multilineTextAlignment(.center)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            TextField("Tap to type and insert special characters", text: $text)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($isTextFieldFocused)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(specialCharsGroups, id: \.self) { group in
                                    ForEach(group, id: \.self) { char in
                                        Button(char) {
                                            text += char
                                        }
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 8)
                                        .foregroundColor(.primary)
                                        .font(.title3)
                                    }
                                    
                                    if group != specialCharsGroups.last {
                                        Divider()
                                            .frame(height: 20)
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button("Done") {
                            isTextFieldFocused = false
                        }
                    }
                }
            
            if !isTextFieldFocused && !text.isEmpty {
                Text("You entered: \(text)")
                    .foregroundStyle(.secondary)
                    .padding(.top)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
        .frame(height: 200)
    }
}

// 7. Multiple Toolbars Example
struct MultipleToolbarsExample: View {
    @State private var text = "Tap to start editing..."
    @State private var showFormatting = false
    @State private var showSymbols = false
    @State private var isBold = false
    @State private var isItalic = false
    @State private var fontSize = 16.0
    @FocusState private var isTextFieldFocused: Bool
    
    let symbols = ["•", "◦", "→", "←", "✓", "✗", "★", "☆", "♥", "♦", "♠", "♣"]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Multiple toolbar rows with different functions")
                .multilineTextAlignment(.center)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            TextEditor(text: $text)
                .font(.system(
                    size: fontSize,
                    weight: isBold ? .bold : .regular
                ).italic(isItalic))
                .frame(minHeight: 100)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($isTextFieldFocused)
                .toolbar {
                    // Primary toolbar
                    ToolbarItemGroup(placement: .keyboard) {
                        // Format toggle
                        Button(action: { showFormatting.toggle() }) {
                            Image(systemName: showFormatting ? "textformat.fill" : "textformat")
                                .foregroundColor(showFormatting ? .blue : .primary)
                        }
                        
                        // Symbols toggle
                        Button(action: { showSymbols.toggle() }) {
                            Image(systemName: showSymbols ? "character.bubble.fill" : "character.bubble")
                                .foregroundColor(showSymbols ? .blue : .primary)
                        }
                        
                        Spacer()
                        
                        Button("Done") {
                            isTextFieldFocused = false
                        }
                    }
                    
                    // Formatting toolbar
                    if showFormatting {
                        ToolbarItemGroup(placement: .keyboard) {
                            // Bold button
                            Button(action: { isBold.toggle() }) {
                                Image(systemName: isBold ? "bold" : "bold")
                                    .foregroundColor(isBold ? .blue : .primary)
                            }
                            
                            // Italic button
                            Button(action: { isItalic.toggle() }) {
                                Image(systemName: isItalic ? "italic" : "italic")
                                    .foregroundColor(isItalic ? .blue : .primary)
                            }
                            
                            // Font size controls
                            Group {
                                Button(action: { fontSize = max(10, fontSize - 2) }) {
                                    Image(systemName: "minus")
                                }
                                
                                Text("\(Int(fontSize))")
                                    .frame(minWidth: 25)
                                
                                Button(action: { fontSize = min(30, fontSize + 2) }) {
                                    Image(systemName: "plus")
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    
                    // Symbols toolbar
                    if showSymbols {
                        ToolbarItemGroup(placement: .keyboard) {
                            ForEach(symbols, id: \.self) { symbol in
                                Button(symbol) {
                                    text += symbol
                                }
                                .font(.title3)
                            }
                            
                            Spacer()
                        }
                    }
                }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
        .frame(height: 240)
    }
}

// 8. Context-Aware Accessories Example
struct ContextAwareAccessoriesExample: View {
    @State private var date = Date()
    @State private var amount = ""
    @State private var notes = ""
    @FocusState private var focusedField: ExpenseField?
    
    enum ExpenseField {
        case date, amount, notes
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Different accessory views based on input field type")
                .multilineTextAlignment(.center)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Group {
                // Date field
                HStack {
                    Text("Date:")
                        .frame(width: 60, alignment: .leading)
                    
                    TextField("Select date", text: .constant(formatDate(date)))
                        .focused($focusedField, equals: .date)
                }
                .padding()
                .background(focusedField == .date ? Color.blue.opacity(0.1) : Color(.systemGray6))
                .cornerRadius(8)
                .onTapGesture {
                    focusedField = .date
                }
                
                // Amount field
                HStack {
                    Text("Amount:")
                        .frame(width: 60, alignment: .leading)
                    
                    TextField("Enter amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .amount)
                }
                .padding()
                .background(focusedField == .amount ? Color.blue.opacity(0.1) : Color(.systemGray6))
                .cornerRadius(8)
                
                // Notes field
                HStack {
                    Text("Notes:")
                        .frame(width: 60, alignment: .leading)
                    
                    TextField("Add notes", text: $notes)
                        .focused($focusedField, equals: .notes)
                }
                .padding()
                .background(focusedField == .notes ? Color.blue.opacity(0.1) : Color(.systemGray6))
                .cornerRadius(8)
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    // Context-specific toolbar content
                    if focusedField == .date {
                        // Date picker accessory
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    } else if focusedField == .amount {
                        // Currency accessory
                        ForEach(["$", "€", "£", "¥"], id: \.self) { symbol in
                            Button(symbol) {
                                if !amount.hasPrefix(symbol) {
                                    amount = symbol + amount
                                }
                            }
                            .font(.title3)
                        }
                        
                        Spacer()
                        
                        // Quick amount buttons
                        HStack {
                            Button("5") { amount += "5" }
                            Button("10") { amount += "10" }
                            Button("20") { amount += "20" }
                            Button("50") { amount += "50" }
                            Button("100") { amount += "100" }
                        }
                    } else if focusedField == .notes {
                        // Quick notes
                        Button("Lunch") { notes = "Lunch expense" }
                        Button("Travel") { notes = "Travel expense" }
                        Button("Meeting") { notes = "Business meeting" }
                    }
                    
                    Spacer()
                    
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
        .frame(height: 290)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// Helper extension for font italic
extension Font {
    func italic(_ isItalic: Bool) -> Font {
        return isItalic ? self.italic() : self
    }
}

#Preview {
    KeyboardAccessoriesView()
}