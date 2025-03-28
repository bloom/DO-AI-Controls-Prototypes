//
//  PresentationMethodsView.swift
//  DO-AI-Controls
//
//  Created by Paul Mayne on 3/28/25.
//

import SwiftUI

struct PresentationMethodsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    // Accent color
    let accentColor = Color(hex: "44C0FF")
    
    // List of presentation methods to display
    let presentationMethods = [
        PresentationMethod(
            name: "Navigation Link",
            category: "Navigation-Based",
            description: "Pushes a new view onto the navigation stack, creating a hierarchical navigation flow.",
            detailView: AnyView(NavigationLinkDemoView())
        ),
        PresentationMethod(
            name: "Sheet",
            category: "Modal Presentation",
            description: "Presents a view modally over the current context as a card that can be swiped down to dismiss.",
            detailView: AnyView(SheetDemoView())
        ),
        PresentationMethod(
            name: "Full Screen Cover",
            category: "Modal Presentation",
            description: "Similar to a sheet but covers the entire screen, ideal when you want to completely replace the current view temporarily.",
            detailView: AnyView(FullScreenCoverDemoView())
        ),
        PresentationMethod(
            name: "Popover",
            category: "Popover Presentation",
            description: "Displays content in a popover style (primarily on iPad, though iPhone behavior may adapt based on context).",
            detailView: AnyView(PopoverDemoView())
        ),
        PresentationMethod(
            name: "Alert",
            category: "Alerts and Dialogs",
            description: "Presents a simple alert dialog to communicate critical information or decisions.",
            detailView: AnyView(AlertDemoView())
        ),
        PresentationMethod(
            name: "Confirmation Dialog",
            category: "Alerts and Dialogs",
            description: "Shows an action sheet-like dialog, typically used for multiple options or confirmation actions.",
            detailView: AnyView(ConfirmationDialogDemoView())
        ),
        PresentationMethod(
            name: "Menu",
            category: "Contextual UI",
            description: "Displays a menu of options when a control is long-pressed or clicked.",
            detailView: AnyView(MenuDemoView())
        ),
        PresentationMethod(
            name: "Context Menu",
            category: "Contextual UI",
            description: "Displays a context menu when a view is long-pressed, showing contextual actions.",
            detailView: AnyView(ContextMenuDemoView())
        ),
        PresentationMethod(
            name: "Inspector",
            category: "Sidebar Presentation",
            description: "Presents a supplementary view as a sidebar, typically used for showing properties or details.",
            detailView: AnyView(InspectorDemoView())
        ),
        PresentationMethod(
            name: "Custom Transitions",
            category: "Animated Presentation",
            description: "Custom transitions between views, allowing for tailored animation and visual effects.",
            detailView: AnyView(CustomTransitionDemoView())
        )
    ]
    
    // Filter methods based on search text
    var filteredMethods: [PresentationMethod] {
        if searchText.isEmpty {
            return presentationMethods
        } else {
            return presentationMethods.filter { method in
                method.name.localizedCaseInsensitiveContains(searchText) ||
                method.category.localizedCaseInsensitiveContains(searchText) ||
                method.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredMethods) { method in
                    NavigationLink(destination: PresentationMethodDetailView(method: method)) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(method.name)
                                    .font(.headline)
                                
                                Spacer()
                                
                                Text(method.category)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color(.systemGray5))
                                    )
                            }
                            
                            Text(method.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Presentation Methods")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(accentColor)
                }
            }
            .searchable(text: $searchText, prompt: "Search presentation methods")
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

// Model for presentation methods
struct PresentationMethod: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let description: String
    let detailView: AnyView
}

// Detail view for a presentation method
struct PresentationMethodDetailView: View {
    let method: PresentationMethod
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with method info
            VStack(alignment: .leading, spacing: 8) {
                Text(method.category)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(method.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(method.description)
                    .font(.body)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            Divider()
                .padding(.horizontal)
            
            // Actual demo view
            VStack(spacing: 12) {
                Text("Demo")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                method.detailView
                    .frame(maxWidth: .infinity)
            }
            
            Spacer()
        }
        .padding(.vertical)
        .navigationTitle(method.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Demo Views for each Presentation Method

// 1. Navigation Link Demo
struct NavigationLinkDemoView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("This is a navigation link demo")
                    .font(.headline)
                
                NavigationLink("Navigate to Detail View") {
                    // Destination view
                    VStack(spacing: 16) {
                        Text("Detail View")
                            .font(.title)
                        
                        Text("This view was presented via NavigationLink")
                            .font(.body)
                        
                        Image(systemName: "arrow.left")
                            .font(.largeTitle)
                            .padding()
                            .foregroundColor(.blue)
                        
                        Text("Tap the back button to return")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .navigationTitle("Detail")
                    .navigationBarTitleDisplayMode(.inline)
                }
                .buttonStyle(.bordered)
                .tint(.blue)
                
                Text("The navigation stack manages a hierarchy of views and provides a standard way to navigate back")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Navigation Demo")
            .navigationBarTitleDisplayMode(.inline)
        }
        .frame(height: 400)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// 2. Sheet Demo
struct SheetDemoView: View {
    @State private var isSheetPresented = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sheet Presentation Demo")
                .font(.headline)
            
            Button("Present Sheet") {
                isSheetPresented = true
            }
            .buttonStyle(.bordered)
            .tint(.blue)
            
            Text("Sheets slide up from the bottom and can be dismissed by dragging down")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .sheet(isPresented: $isSheetPresented) {
            // Sheet content
            VStack(spacing: 20) {
                Text("Sheet Content")
                    .font(.title)
                
                Text("This view is presented as a sheet, which is a common way to present modals in iOS")
                    .multilineTextAlignment(.center)
                    .padding()
                
                Image(systemName: "arrow.down")
                    .font(.largeTitle)
                    .padding()
                
                Text("Drag down to dismiss this sheet")
                    .font(.caption)
                
                Button("Dismiss") {
                    isSheetPresented = false
                }
                .buttonStyle(.bordered)
                .tint(.blue)
                .padding(.top)
            }
            .padding()
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

// 3. Full Screen Cover Demo
struct FullScreenCoverDemoView: View {
    @State private var isFullScreenPresented = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Full Screen Cover Demo")
                .font(.headline)
            
            Button("Present Full Screen") {
                isFullScreenPresented = true
            }
            .buttonStyle(.bordered)
            .tint(.blue)
            
            Text("Full screen covers replace the entire screen and require programmatic dismissal")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .fullScreenCover(isPresented: $isFullScreenPresented) {
            // Full screen content
            ZStack {
                Color.blue.opacity(0.2).ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Full Screen View")
                        .font(.largeTitle)
                        .padding(.top, 40)
                    
                    Text("This modal covers the entire screen and can't be dismissed by swiping")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Spacer()
                    
                    Button("Dismiss") {
                        isFullScreenPresented = false
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .padding(.bottom, 40)
                }
                .padding()
            }
        }
    }
}

// 4. Popover Demo
struct PopoverDemoView: View {
    @State private var isPopoverPresented = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Popover Demo")
                .font(.headline)
            
            Button("Show Popover") {
                isPopoverPresented = true
            }
            .buttonStyle(.bordered)
            .tint(.blue)
            .popover(isPresented: $isPopoverPresented, arrowEdge: .top) {
                // Popover content
                VStack(spacing: 16) {
                    Text("Popover Content")
                        .font(.headline)
                    
                    Text("Popovers are useful for showing contextual information or controls")
                        .font(.body)
                        .multilineTextAlignment(.center)
                    
                    Divider()
                    
                    Button("Close") {
                        isPopoverPresented = false
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                }
                .padding()
                .frame(width: 300, height: 200)
            }
            
            Text("On iPad, popovers appear as floating panels. On iPhone, they typically adapt to a sheet presentation")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// 5. Alert Demo
struct AlertDemoView: View {
    @State private var showBasicAlert = false
    @State private var showActionAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Alert Demo")
                .font(.headline)
            
            // Basic alert button
            Button("Show Basic Alert") {
                showBasicAlert = true
            }
            .buttonStyle(.bordered)
            .tint(.blue)
            
            // Alert with actions button
            Button("Show Alert with Actions") {
                showActionAlert = true
            }
            .buttonStyle(.bordered)
            .tint(.blue)
            
            Text("Alerts are modal dialogs that appear in the center of the screen and require user interaction")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        // Basic alert
        .alert("Information", isPresented: $showBasicAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This is a basic alert with a single button")
        }
        // Alert with actions
        .alert("Confirm Action", isPresented: $showActionAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {}
        } message: {
            Text("Would you like to proceed with this action?")
        }
    }
}

// 6. Confirmation Dialog Demo
struct ConfirmationDialogDemoView: View {
    @State private var showDialog = false
    @State private var selectedOption = "None"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Confirmation Dialog Demo")
                .font(.headline)
            
            Button("Show Confirmation Dialog") {
                showDialog = true
            }
            .buttonStyle(.bordered)
            .tint(.blue)
            
            if selectedOption != "None" {
                Text("You selected: \(selectedOption)")
                    .padding(.vertical)
            }
            
            Text("Confirmation dialogs (formerly action sheets) present a set of options to the user")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .confirmationDialog("Select an Option", isPresented: $showDialog) {
            Button("Option 1") { selectedOption = "Option 1" }
            Button("Option 2") { selectedOption = "Option 2" }
            Button("Option 3") { selectedOption = "Option 3" }
            Button("Cancel", role: .cancel) { selectedOption = "Canceled" }
            Button("Delete", role: .destructive) { selectedOption = "Delete" }
        } message: {
            Text("Please select one of the following options")
        }
    }
}

// 7. Menu Demo
struct MenuDemoView: View {
    @State private var selectedOption = "No selection"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Menu Demo")
                .font(.headline)
            
            Menu {
                Button("Option 1") { selectedOption = "Option 1" }
                Button("Option 2") { selectedOption = "Option 2" }
                Button("Option 3") { selectedOption = "Option 3" }
                
                Menu("Submenu") {
                    Button("Submenu Option 1") { selectedOption = "Submenu Option 1" }
                    Button("Submenu Option 2") { selectedOption = "Submenu Option 2" }
                }
                
                Divider()
                
                Button("Reset") { selectedOption = "No selection" }
            } label: {
                Label("Show Menu", systemImage: "ellipsis.circle")
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Text("Selected: \(selectedOption)")
                .padding(.vertical)
            
            Text("Menus provide a list of actions or choices in a compact UI")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// 8. Context Menu Demo
struct ContextMenuDemoView: View {
    @State private var text = "Long press on this text"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Context Menu Demo")
                .font(.headline)
            
            Text(text)
                .font(.title3)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                .contextMenu {
                    Button {
                        text = "Copied to clipboard"
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    
                    Button {
                        text = "Shared item"
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(role: .destructive) {
                        text = "Deleted item"
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            
            Text("Context menus appear when you long-press on a view, offering contextual actions")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// 9. Inspector Demo
struct InspectorDemoView: View {
    @State private var isInspectorPresented = false
    @State private var selectedColor = Color.blue
    @State private var opacity = 0.8
    @State private var cornerRadius = 8.0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Inspector Demo")
                    .font(.headline)
                
                // Sample content to be modified by inspector
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(selectedColor.opacity(opacity))
                    .frame(width: 150, height: 150)
                
                Button("Toggle Inspector") {
                    isInspectorPresented.toggle()
                }
                .buttonStyle(.bordered)
                .tint(.blue)
                
                Text("Inspectors are sidebars that provide properties or details for selected content")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Inspector")
            .navigationBarTitleDisplayMode(.inline)
            .inspector(isPresented: $isInspectorPresented) {
                // Inspector content
                VStack(alignment: .leading, spacing: 16) {
                    Text("Shape Properties")
                        .font(.headline)
                    
                    Divider()
                    
                    VStack(alignment: .leading) {
                        Text("Color")
                            .font(.subheadline)
                        ColorPicker("", selection: $selectedColor)
                            .labelsHidden()
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Opacity: \(opacity, specifier: "%.2f")")
                            .font(.subheadline)
                        Slider(value: $opacity, in: 0...1)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Corner Radius: \(Int(cornerRadius))")
                            .font(.subheadline)
                        Slider(value: $cornerRadius, in: 0...50)
                    }
                    
                    Spacer()
                }
                .padding()
                .frame(width: 250)
                .background(Color(.systemBackground))
            }
        }
        .frame(height: 400)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// 10. Custom Transition Demo
struct CustomTransitionDemoView: View {
    @State private var showDetail = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Custom Transition Demo")
                .font(.headline)
            
            Button("Show with Custom Transition") {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.65)) {
                    showDetail.toggle()
                }
            }
            .buttonStyle(.bordered)
            .tint(.blue)
            
            if showDetail {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.2))
                    .frame(height: 200)
                    .overlay(
                        VStack {
                            Text("Animated View")
                                .font(.title3)
                            
                            Text("This view appeared with a custom transition")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Button("Dismiss") {
                                withAnimation(.spring(response: 0.55, dampingFraction: 0.65)) {
                                    showDetail.toggle()
                                }
                            }
                            .buttonStyle(.bordered)
                            .tint(.blue)
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.1).combined(with: .opacity),
                        removal: .scale(scale: 0.0).combined(with: .opacity)
                    ))
            }
            
            Text("Custom transitions allow you to define unique animations for view appearances and disappearances")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    PresentationMethodsView()
}