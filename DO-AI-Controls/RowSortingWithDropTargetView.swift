//
//  RowSortingWithDropTargetView.swift
//  DO-AI-Controls
//
//  Created by Paul Mayne on 12/20/25.
//

import SwiftUI

// MARK: - Data Models

struct FileNode: Identifiable, Equatable {
    let id: UUID = UUID()
    let name: String
}

struct FolderNode: Identifiable, Equatable {
    let id: UUID = UUID()
    var name: String
    var contents: [FileNode]
    var isExpanded: Bool = false

    var itemCount: Int { contents.count }
}

enum DisplayNode: Identifiable, Equatable {
    case file(FileNode)
    case folder(FolderNode)
    case dropZone(UUID)

    var id: UUID {
        switch self {
        case .file(let item):
            return item.id
        case .folder(let item):
            return item.id
        case .dropZone(let folderId):
            // Create stable ID for drop zones
            return UUID(uuidString: "00000000-0000-0000-0000-\(folderId.uuidString.suffix(12))")!
        }
    }
}

// MARK: - Main View

struct RowSortingWithDropTargetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var rootItems: [DisplayNode] = []
    @State private var folders: [UUID: FolderNode] = [:]
    @State private var isEditModalPresented = false

    let accentColor = Color(hex: "44C0FF")

    var body: some View {
        NavigationStack {
            List {
                ForEach(displayedItems) { item in
                    switch item {
                    case .file(let file):
                        FileRowView(file: file, accentColor: accentColor)
                    case .folder(let folder):
                        FolderRowView(
                            folder: folder,
                            accentColor: accentColor,
                            onTap: { toggleFolder(id: folder.id) }
                        )
                    case .dropZone:
                        EmptyView()
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Folder Sorting")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                        .foregroundColor(accentColor)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") { isEditModalPresented = true }
                        .foregroundColor(accentColor)
                }
            }
        }
        .sheet(isPresented: $isEditModalPresented) {
            EditModalView(
                rootItems: $rootItems,
                folders: $folders,
                accentColor: accentColor
            )
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear {
            if rootItems.isEmpty {
                initializeDefaultData()
            }
        }
    }

    var displayedItems: [DisplayNode] {
        buildDisplayList(includeDropZones: false)
    }

    // MARK: - Helper Functions

    func initializeDefaultData() {
        // Create files
        let row1 = FileNode(name: "Row 1")
        let row2 = FileNode(name: "Row 2")
        let row3 = FileNode(name: "Row 3")
        let row4 = FileNode(name: "Row 4")
        let row5 = FileNode(name: "Row 5")

        // Create Folder A with contents
        let a1 = FileNode(name: "A.1")
        let a2 = FileNode(name: "A.2")
        let a3 = FileNode(name: "A.3")
        let folderA = FolderNode(name: "Folder A", contents: [a1, a2, a3], isExpanded: false)
        folders[folderA.id] = folderA

        // Create Folder B with contents
        let b1 = FileNode(name: "B.1")
        let folderB = FolderNode(name: "Folder B", contents: [b1], isExpanded: false)
        folders[folderB.id] = folderB

        // Build root items array
        rootItems = [
            .file(row1),
            .file(row2),
            .folder(folderA),
            .file(row3),
            .file(row4),
            .folder(folderB),
            .file(row5)
        ]
    }

    func buildDisplayList(includeDropZones: Bool) -> [DisplayNode] {
        var result: [DisplayNode] = []

        for item in rootItems {
            result.append(item)

            if case .folder(let folder) = item {
                // Show contents if expanded
                if folder.isExpanded {
                    result.append(contentsOf: folder.contents.map { .file($0) })
                }

                // Add drop zone in edit mode
                if includeDropZones {
                    result.append(.dropZone(folder.id))
                }
            }
        }

        return result
    }

    func toggleFolder(id: UUID) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if let index = rootItems.firstIndex(where: {
                if case .folder(let f) = $0, f.id == id { return true }
                return false
            }) {
                if case .folder(var folder) = rootItems[index] {
                    folder.isExpanded.toggle()
                    folders[folder.id] = folder
                    rootItems[index] = .folder(folder)
                }
            }
        }
    }
}

// MARK: - Edit Modal View

struct EditModalView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var rootItems: [DisplayNode]
    @Binding var folders: [UUID: FolderNode]
    let accentColor: Color

    @State private var editableItems: [DisplayNode] = []

    var body: some View {
        NavigationStack {
            List {
                ForEach(editableItems) { item in
                    switch item {
                    case .file(let file):
                        FileRowView(file: file, accentColor: accentColor)
                    case .folder(let folder):
                        FolderRowView(
                            folder: folder,
                            accentColor: accentColor,
                            onTap: { toggleFolder(id: folder.id) }
                        )
                    case .dropZone(let folderId):
                        DropZoneRowView(
                            folderName: folders[folderId]?.name ?? "Unknown",
                            accentColor: accentColor
                        )
                    }
                }
                .onMove(perform: moveItem)
            }
            .listStyle(.plain)
            .environment(\.editMode, .constant(.active))
            .navigationTitle("Edit Order")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        saveAndDismiss()
                    }
                    .foregroundColor(accentColor)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear {
            buildEditableList()
        }
    }

    // MARK: - Helper Functions

    func buildEditableList() {
        var result: [DisplayNode] = []

        for item in rootItems {
            result.append(item)

            if case .folder(let folderInRoot) = item {
                // Get the latest folder state from the folders dictionary
                guard let folder = folders[folderInRoot.id] else { continue }

                // Show contents if expanded
                if folder.isExpanded {
                    result.append(contentsOf: folder.contents.map { .file($0) })
                }

                // ALWAYS add drop zone after folder
                result.append(.dropZone(folder.id))
            }
        }

        editableItems = result
    }

    func moveItem(from source: IndexSet, to destination: Int) {
        guard let sourceIndex = source.first else { return }
        let movedItem = editableItems[sourceIndex]

        // Don't allow dragging drop zones - snap back after a short delay
        if case .dropZone = movedItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    // Force state update by clearing first
                    self.editableItems = []
                    self.buildEditableList()
                }
            }
            return
        }

        // Handle folder moves
        if case .folder(let folder) = movedItem {
            moveFolderToRoot(folder: folder, sourceIndex: sourceIndex, destinationIndex: destination)
            buildEditableList()
            return
        }

        // Handle file moves
        guard case .file(let file) = movedItem else { return }

        // Check destination type - prioritize folder position over drop zone
        if let (folderId, position) = findFolderAtDestination(destination) {
            // Destination is within an expanded folder at specific position
            moveFileIntoFolder(file: file, folderId: folderId, position: position)
        } else if destination < editableItems.count,
                  case .dropZone(let folderId) = editableItems[destination] {
            // Destination is explicitly the drop zone - check if dragging from same folder
            let sourceParentFolder = findParentFolder(at: sourceIndex)
            if let (sourceFolder, _) = sourceParentFolder, sourceFolder.id == folderId {
                // Dragging from same folder to its drop zone - move to root level
                moveFileToRoot(file: file, sourceIndex: sourceIndex, destinationIndex: destination)
            } else {
                // Dragging from elsewhere to drop zone - add to end of folder
                moveFileIntoFolder(file: file, folderId: folderId, position: nil)
            }
        } else {
            // Moving at root level
            moveFileToRoot(file: file, sourceIndex: sourceIndex, destinationIndex: destination)
        }

        buildEditableList()
    }

    func findFolderAtDestination(_ destinationIndex: Int) -> (UUID, Int)? {
        // Walk through rootItems to find if destinationIndex falls within an expanded folder
        var currentDisplayIndex = 0

        for rootItem in rootItems {
            if case .folder(let folderInRoot) = rootItem {
                // Get the latest folder state from the folders dictionary
                guard let folder = folders[folderInRoot.id] else {
                    currentDisplayIndex += 1
                    continue
                }

                if folder.isExpanded {
                    currentDisplayIndex += 1 // Skip the folder row itself

                    // Check if destination is within this folder's contents
                    let folderStartIndex = currentDisplayIndex
                    // Allow insertion at any position including after the last item
                    let folderInsertEndIndex = currentDisplayIndex + folder.contents.count

                    if destinationIndex >= folderStartIndex && destinationIndex <= folderInsertEndIndex {
                        // Destination is within this folder
                        let positionInFolder = destinationIndex - folderStartIndex
                        return (folder.id, positionInFolder)
                    }

                    currentDisplayIndex += folder.contents.count  // Skip folder contents
                    currentDisplayIndex += 1  // Skip drop zone
                } else {
                    // Collapsed folder
                    currentDisplayIndex += 1  // Folder row
                    currentDisplayIndex += 1  // Drop zone
                }
            } else {
                // Regular file at root
                currentDisplayIndex += 1
            }
        }

        return nil
    }

    func findParentFolder(at displayIndex: Int) -> (FolderNode, Int)? {
        // Check if displayIndex is inside an expanded folder
        // Returns (folder, position within folder) if inside a folder, nil otherwise
        var currentIndex = 0

        for rootItem in rootItems {
            if case .folder(let folderInRoot) = rootItem {
                // Get the latest folder state from the folders dictionary
                guard let folder = folders[folderInRoot.id] else {
                    currentIndex += 1
                    continue
                }

                if folder.isExpanded {
                    currentIndex += 1 // Skip the folder row itself

                    // Check if displayIndex falls within this folder's contents
                    let folderEndIndex = currentIndex + folder.contents.count - 1
                    if displayIndex >= currentIndex && displayIndex <= folderEndIndex {
                        // displayIndex is inside this folder (existing items only, not insertion points)
                        let positionInFolder = displayIndex - currentIndex
                        return (folder, positionInFolder)
                    }

                    currentIndex += folder.contents.count  // Folder contents
                    currentIndex += 1  // Drop zone
                } else {
                    // Collapsed folder
                    currentIndex += 1  // Folder row
                    currentIndex += 1  // Drop zone
                }
            } else {
                // Regular row at root level
                currentIndex += 1
            }
        }

        return nil
    }

    func moveFileIntoFolder(file: FileNode, folderId: UUID, position: Int?) {
        // Remove from current location
        removeFileFromSource(file)

        // Add to folder at specific position or end
        guard var folder = folders[folderId] else { return }
        if let position = position {
            folder.contents.insert(file, at: min(position, folder.contents.count))
        } else {
            folder.contents.append(file)
        }
        folders[folderId] = folder

        // Update in rootItems
        if let index = rootItems.firstIndex(where: {
            if case .folder(let f) = $0, f.id == folderId { return true }
            return false
        }) {
            rootItems[index] = .folder(folder)
        }
    }

    func removeFileFromSource(_ file: FileNode) {
        // Try root first
        if let index = rootItems.firstIndex(where: {
            if case .file(let f) = $0, f.id == file.id { return true }
            return false
        }) {
            rootItems.remove(at: index)
            return
        }

        // Try folders
        for (folderId, var folder) in folders {
            if let index = folder.contents.firstIndex(where: { $0.id == file.id }) {
                folder.contents.remove(at: index)
                folders[folderId] = folder

                // Update in rootItems
                if let rootIndex = rootItems.firstIndex(where: {
                    if case .folder(let f) = $0, f.id == folderId { return true }
                    return false
                }) {
                    rootItems[rootIndex] = .folder(folder)
                }
                return
            }
        }
    }

    func moveFileToRoot(file: FileNode, sourceIndex: Int, destinationIndex: Int) {
        // Calculate root position BEFORE removing (to avoid index shift issues)
        var rootPosition = mapDisplayToRootIndex(destinationIndex)

        // Check if source is at root level and before destination
        let sourceParentFolder = findParentFolder(at: sourceIndex)
        if sourceParentFolder == nil && sourceIndex < destinationIndex {
            // Source is at root and before destination, so position will shift down after removal
            rootPosition = max(0, rootPosition - 1)
        }

        // Remove from current location
        removeFileFromSource(file)

        // Insert at calculated root position
        rootItems.insert(.file(file), at: min(rootPosition, rootItems.count))
    }

    func moveFolderToRoot(folder: FolderNode, sourceIndex: Int, destinationIndex: Int) {
        // Calculate root position BEFORE removing (to avoid index shift issues)
        var rootPosition = mapDisplayToRootIndex(destinationIndex)

        // Adjust if moving down (source before destination)
        if sourceIndex < destinationIndex {
            rootPosition = max(0, rootPosition - 1)
        }

        // Remove folder from current position in rootItems
        if let currentIndex = rootItems.firstIndex(where: {
            if case .folder(let f) = $0, f.id == folder.id { return true }
            return false
        }) {
            rootItems.remove(at: currentIndex)
        }

        // Insert folder at calculated position
        rootItems.insert(.folder(folder), at: min(rootPosition, rootItems.count))
    }

    func mapDisplayToRootIndex(_ displayIndex: Int) -> Int {
        var rootCount = 0
        var currentDisplayIndex = 0

        for item in rootItems {
            if currentDisplayIndex >= displayIndex {
                break
            }

            currentDisplayIndex += 1  // The item itself

            if case .folder(let folder) = item {
                if folder.isExpanded {
                    currentDisplayIndex += folder.contents.count
                }
                currentDisplayIndex += 1  // Drop zone
            }

            rootCount += 1
        }

        return rootCount
    }

    func toggleFolder(id: UUID) {
        if let index = rootItems.firstIndex(where: {
            if case .folder(let f) = $0, f.id == id { return true }
            return false
        }) {
            if case .folder(var folder) = rootItems[index] {
                folder.isExpanded.toggle()
                folders[folder.id] = folder
                rootItems[index] = .folder(folder)
                buildEditableList()
            }
        }
    }

    func saveAndDismiss() {
        // Changes are already reflected in bindings
        dismiss()
    }
}

// MARK: - Component Views

struct FileRowView: View {
    let file: FileNode
    let accentColor: Color

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(gradientForFile(file.name))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(file.name.prefix(1)))
                        .font(.headline)
                        .foregroundColor(.white)
                )

            Text(file.name)
                .font(.body)

            Spacer()
        }
        .padding(.vertical, 8)
    }

    func gradientForFile(_ name: String) -> LinearGradient {
        let colors: [Color] = [
            Color(hex: "FF6B6B"), Color(hex: "4ECDC4"), Color(hex: "45B7D1"),
            Color(hex: "FFA07A"), Color(hex: "98D8C8"), Color(hex: "F7DC6F"),
            Color(hex: "BB8FCE"), Color(hex: "85C1E2"), Color(hex: "F8B88B"),
            Color(hex: "52B788")
        ]

        let charValue = name.unicodeScalars.first?.value ?? 0
        let colorIndex = Int(charValue) % colors.count
        let color = colors[colorIndex]

        return LinearGradient(
            colors: [color, color.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct FolderRowView: View {
    let folder: FolderNode
    let accentColor: Color
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "folder.fill")
                .font(.title3)
                .foregroundColor(accentColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(folder.name)
                    .font(.headline)
                Text("\(folder.itemCount) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
                .rotationEffect(.degrees(folder.isExpanded ? 90 : 0))
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

struct DropZoneRowView: View {
    let folderName: String
    let accentColor: Color

    var body: some View {
        VStack(spacing: 4) {
            Rectangle()
                .strokeBorder(
                    accentColor.opacity(0.4),
                    style: StrokeStyle(lineWidth: 2, dash: [8, 4])
                )
                .frame(height: 50)
                .overlay(
                    Text("Drop here to add to \(folderName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                )
                .padding(.horizontal, 8)
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
    }
}

// MARK: - Preview

#Preview {
    RowSortingWithDropTargetView()
}
