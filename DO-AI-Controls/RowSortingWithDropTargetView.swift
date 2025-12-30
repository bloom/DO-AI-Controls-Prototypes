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
            if let index = findFolderIndex(id: id),
               case .folder(var folder) = rootItems[index] {
                folder.isExpanded.toggle()
                updateFolder(folder)
            }
        }
    }

    // MARK: - Helper Functions

    func findFolderIndex(id: UUID) -> Int? {
        rootItems.firstIndex { item in
            if case .folder(let f) = item, f.id == id {
                return true
            }
            return false
        }
    }

    func updateFolder(_ folder: FolderNode) {
        folders[folder.id] = folder
        if let index = findFolderIndex(id: folder.id) {
            rootItems[index] = .folder(folder)
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
    @State private var renamingFolderId: UUID?
    @FocusState private var renameFocused: Bool

    // Display list cache for performance
    @State private var displayListCache: (stateHash: Int, result: [DisplayNode])? = nil

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
                            isRenaming: renamingFolderId == folder.id,
                            renameFocused: $renameFocused,
                            onTap: { toggleFolder(id: folder.id) },
                            onRename: {
                                renamingFolderId = folder.id
                                renameFocused = true
                            },
                            onDelete: { deleteFolder(id: folder.id) },
                            onRenameSave: { newName in
                                saveFolderName(id: folder.id, newName: newName)
                                renamingFolderId = nil
                            }
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
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        addNewFolder()
                    } label: {
                        Image(systemName: "folder.badge.plus")
                            .foregroundColor(accentColor)
                    }
                }
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

    /// Builds the editable list with caching for performance
    /// Only rebuilds if the underlying state (rootItems or folders) has changed
    func buildEditableList() {
        // Calculate hash of current state
        let currentHash = calculateStateHash()

        // Check cache
        if let cache = displayListCache, cache.stateHash == currentHash {
            editableItems = cache.result
            return
        }

        // Build new list
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

        // Update cache and items
        displayListCache = (currentHash, result)
        editableItems = result
    }

    /// Calculates a hash representing the current state of rootItems and folders
    /// Used for cache invalidation
    private func calculateStateHash() -> Int {
        var hasher = Hasher()

        // Hash root items count and IDs
        hasher.combine(rootItems.count)
        for item in rootItems {
            hasher.combine(item.id)
        }

        // Hash folder states (expanded, contents count)
        for (id, folder) in folders {
            hasher.combine(id)
            hasher.combine(folder.isExpanded)
            hasher.combine(folder.contents.count)
            hasher.combine(folder.name)
        }

        return hasher.finalize()
    }

    /// Handles drag-and-drop operations for items in the list
    ///
    /// This function orchestrates all move operations with the following priority:
    /// 1. Drop zones snap back to their correct position (not movable)
    /// 2. Folders can only be moved at root level
    /// 3. Files check destination in order:
    ///    - Within expanded folder contents (specific position)
    ///    - On drop zone (add to folder or move to root if from same folder)
    ///    - Root level (between other root items)
    ///
    /// - Parameters:
    ///   - source: IndexSet of the source item(s) being moved
    ///   - destination: Target index in the display list
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

    /// Determines if a destination index falls within an expanded folder's contents
    ///
    /// This function maps display indices (which include expanded contents and drop zones)
    /// to folder positions. It walks through rootItems calculating display indices and
    /// checking if the destination falls within any expanded folder's range.
    ///
    /// **Display Index Calculation:**
    /// - Collapsed folder: 1 (folder) + 1 (drop zone) = 2 indices
    /// - Expanded folder: 1 (folder) + N (contents) + 1 (drop zone) = N+2 indices
    /// - File at root: 1 index
    ///
    /// **Example:**
    /// ```
    /// rootItems: [File1, FolderA, File2]
    /// FolderA (expanded): [A.1, A.2, A.3]
    ///
    /// Display indices:
    /// 0: File1
    /// 1: FolderA
    /// 2: A.1  ← folderStartIndex
    /// 3: A.2
    /// 4: A.3
    /// 5: ← folderInsertEndIndex (allows inserting after last item)
    /// 6: DropZone
    /// 7: File2
    /// ```
    ///
    /// - Parameter destinationIndex: The target index in editableItems
    /// - Returns: Tuple of (folderId, positionWithinFolder) if destination is in a folder, nil otherwise
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

    /// Finds the parent folder of an item at a given display index
    ///
    /// This function determines if an item in editableItems is within a folder's contents.
    /// Unlike `findFolderAtDestination`, this checks existing item positions only (not insertion points).
    ///
    /// **Key Difference from findFolderAtDestination:**
    /// - `findFolderAtDestination`: Includes insertion point after last item (for dropping)
    /// - `findParentFolder`: Only existing item positions (for identifying source)
    ///
    /// **Use Cases:**
    /// - Determining where a dragged item came from
    /// - Checking if item is already in a folder before moving
    /// - Preventing items from moving back into their source folder
    ///
    /// - Parameter displayIndex: The index in editableItems to check
    /// - Returns: Tuple of (folder, positionWithinFolder) if the item is in a folder, nil if at root level
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
        guard var folder = getFolder(id: folderId) else { return }
        if let position = position {
            folder.contents.insert(file, at: min(position, folder.contents.count))
        } else {
            folder.contents.append(file)
        }
        updateFolder(folder)
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
                updateFolder(folder)
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
        if let currentIndex = findFolderIndex(id: folder.id) {
            rootItems.remove(at: currentIndex)
        }

        // Insert folder at calculated position
        rootItems.insert(.folder(folder), at: min(rootPosition, rootItems.count))
    }

    /// Maps a display index (editableItems) to a root index (rootItems)
    ///
    /// This function converts indices from the display array (which includes expanded
    /// folder contents and drop zones) back to indices in the rootItems array (which
    /// only contains top-level files and folders).
    ///
    /// **Purpose:**
    /// When moving items to root level, we need to know where to insert them in rootItems.
    /// Since editableItems includes folder contents and drop zones, a display index of 10
    /// might correspond to rootItems index 3.
    ///
    /// **Example:**
    /// ```
    /// rootItems:      [File1, FolderA, File2]  ← indices: 0, 1, 2
    /// editableItems:  [File1, FolderA, A.1, A.2, DropZone, File2]
    ///                   0      1        2    3    4         5
    ///
    /// mapDisplayToRootIndex(5) → 2 (File2's position in rootItems)
    /// mapDisplayToRootIndex(3) → 1 (still inside FolderA's range, maps to folder position)
    /// ```
    ///
    /// - Parameter displayIndex: Index in the editableItems array
    /// - Returns: Corresponding index in the rootItems array
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
        if let index = findFolderIndex(id: id),
           case .folder(var folder) = rootItems[index] {
            folder.isExpanded.toggle()
            updateFolder(folder)
            buildEditableList()
        }
    }

    func addNewFolder() {
        // Find the next folder letter (C, D, E, etc.)
        let existingFolderNames = folders.values.map { $0.name }
        var folderLetter = "C"
        var letterCode = Character("C").asciiValue!

        while existingFolderNames.contains("Folder \(folderLetter)") {
            letterCode += 1
            folderLetter = String(UnicodeScalar(letterCode))
        }

        // Create new folder
        let newFolder = FolderNode(name: "Folder \(folderLetter)", contents: [], isExpanded: false)

        // Add to folders dictionary
        folders[newFolder.id] = newFolder

        // Append to rootItems
        rootItems.append(.folder(newFolder))

        // Rebuild editable list
        withAnimation {
            buildEditableList()
        }

        // Auto-enter rename mode for the new folder
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.renamingFolderId = newFolder.id
            self.renameFocused = true
        }
    }

    func saveAndDismiss() {
        // Changes are already reflected in bindings
        dismiss()
    }

    func deleteFolder(id: UUID) {
        guard let folder = getFolder(id: id) else { return }

        withAnimation {
            // Move all folder contents to root level
            // Insert at the position where the folder currently is
            if let folderIndex = findFolderIndex(id: id) {
                // Insert files at the folder's position (they'll appear where the folder was)
                for (index, file) in folder.contents.enumerated() {
                    rootItems.insert(.file(file), at: folderIndex + index)
                }

                // Remove the folder itself (add offset for inserted files)
                rootItems.remove(at: folderIndex + folder.contents.count)
            }

            // Remove folder from dictionary
            folders.removeValue(forKey: id)

            // Rebuild list
            buildEditableList()
        }
    }

    func saveFolderName(id: UUID, newName: String) {
        guard var folder = getFolder(id: id), !newName.isEmpty else { return }

        withAnimation {
            // Update folder name
            folder.name = newName
            updateFolder(folder)

            // Rebuild list
            buildEditableList()
        }
    }

    // MARK: - Helper Functions (Extracted for Code Reuse)

    /// Finds the index of a folder in rootItems by its ID
    /// - Parameter id: The UUID of the folder to find
    /// - Returns: The index if found, nil otherwise
    func findFolderIndex(id: UUID) -> Int? {
        rootItems.firstIndex { item in
            if case .folder(let f) = item, f.id == id {
                return true
            }
            return false
        }
    }

    /// Updates a folder in both the folders dictionary and rootItems array
    /// - Parameter folder: The updated folder node to save
    func updateFolder(_ folder: FolderNode) {
        folders[folder.id] = folder
        if let index = findFolderIndex(id: folder.id) {
            rootItems[index] = .folder(folder)
        }
    }

    /// Gets the current folder state from the folders dictionary
    /// - Parameter id: The UUID of the folder
    /// - Returns: The current folder node if it exists
    func getFolder(id: UUID) -> FolderNode? {
        folders[id]
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
                .frame(width: 32, height: 32)
                .overlay(
                    Text(String(file.name.prefix(1)))
                        .font(.subheadline)
                        .foregroundColor(.white)
                )
                .accessibilityHidden(true)

            Text(file.name)
                .font(.body)

            Spacer()
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("File: \(file.name)")
        .accessibilityHint("Double-tap to select, drag to move")
        .accessibilityAddTraits(.isButton)
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
    var isRenaming: Bool = false
    var renameFocused: FocusState<Bool>.Binding? = nil
    let onTap: () -> Void
    var onRename: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    var onRenameSave: ((String) -> Void)? = nil

    @State private var editedName: String = ""

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "folder.fill")
                .font(.body)
                .foregroundColor(accentColor)

            VStack(alignment: .leading, spacing: 1) {
                if isRenaming, let renameFocused = renameFocused, let onRenameSave = onRenameSave {
                    TextField("Folder name", text: $editedName, onCommit: {
                        onRenameSave(editedName)
                    })
                    .font(.body)
                    .focused(renameFocused)
                    .onAppear {
                        editedName = folder.name
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            renameFocused.wrappedValue = true
                        }
                    }
                    .onSubmit {
                        onRenameSave(editedName)
                    }
                } else {
                    Text(folder.name)
                        .font(.body)
                }
                Text("\(folder.itemCount) items")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if !isRenaming {
                // Show menu button if rename/delete actions are provided
                if onRename != nil || onDelete != nil {
                    Menu {
                        if let onRename = onRename {
                            Button {
                                onRename()
                            } label: {
                                Label("Rename", systemImage: "pencil")
                            }
                        }
                        if let onDelete = onDelete {
                            Button(role: .destructive) {
                                onDelete()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                            .frame(width: 30, height: 30)
                            .contentShape(Rectangle())
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                    .rotationEffect(.degrees(folder.isExpanded ? 90 : 0))
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onTapGesture {
            if !isRenaming {
                onTap()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(isRenaming ? "Editing folder name" : "\(folder.name), \(folder.itemCount) items")
        .accessibilityHint(isRenaming ? "Type to rename folder" : "Double-tap to \(folder.isExpanded ? "collapse" : "expand")")
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(folder.isExpanded ? "Expanded" : "Collapsed")
        .accessibilityAction(named: "Rename") {
            if let onRename = onRename {
                onRename()
            }
        }
        .accessibilityAction(named: "Delete") {
            if let onDelete = onDelete {
                onDelete()
            }
        }
    }
}

struct DropZoneRowView: View {
    let folderName: String
    let accentColor: Color

    var body: some View {
        VStack(spacing: 0) {
            Text("Drop above here to add to \(folderName)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 4)

            Rectangle()
                .fill(accentColor.opacity(0.4))
                .frame(height: 1)
                .overlay(
                    Rectangle()
                        .stroke(
                            accentColor.opacity(0.4),
                            style: StrokeStyle(lineWidth: 1, dash: [6, 3])
                        )
                )
        }
        .frame(height: 25)
        .padding(.horizontal, 16)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Drop zone for \(folderName)")
        .accessibilityHint("Drop items above this line to add them to \(folderName)")
        .accessibilityAddTraits(.isStaticText)
    }
}

// MARK: - Preview

#Preview {
    RowSortingWithDropTargetView()
}
