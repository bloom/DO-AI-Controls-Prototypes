//
//  SinglePageRowsAndFoldersView.swift
//  DO-AI-Controls
//
//  Created by Paul Mayne on 12/30/25.
//

import SwiftUI

// MARK: - Single Page View

struct SinglePageRowsAndFoldersView: View {
    // MARK: - Layout Constants
    private enum Layout {
        static let nestedIndentation: CGFloat = 32
        static let rowVerticalPadding: CGFloat = 2
        static let iconSize: CGFloat = 28
        static let rowSpacing: CGFloat = 12
        static let fabTrailing: CGFloat = 20
        static let fabBottom: CGFloat = 20
        static let fabHorizontalPadding: CGFloat = 20
        static let fabVerticalPadding: CGFloat = 14
        static let fabIconSize: CGFloat = 16
    }

    // MARK: - Configuration
    private enum Config {
        static let autoDeleteEmptyFolders = false // Set to true to auto-delete empty folders
    }

    @Environment(\.dismiss) private var dismiss

    // MARK: - Dual State Management
    // We maintain folder data in two places for performance:
    // 1. rootItems: Array maintaining display order and hierarchy
    // 2. folders: Dictionary providing O(1) lookup by UUID
    //
    // Why both?
    // - rootItems: Preserves order (critical for display and drag-drop)
    // - folders: Fast lookups (used in moveItem, updateFolder, etc.)
    //
    // Synchronization:
    // - updateFolder() keeps both in sync
    // - Always modify folders through updateFolder() to maintain consistency
    // - validateStateSync() can verify they're in sync (DEBUG only)
    @State private var rootItems: [DisplayNode] = []
    @State private var folders: [UUID: FolderNode] = [:]
    @State private var isEditMode = false

    // Cached computed properties for performance
    @State private var cachedDisplayedItems: [DisplayNode] = []
    @State private var cachedOrderedFolders: [FolderNode] = []

    let accentColor = Color(hex: "44C0FF")

    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(cachedDisplayedItems) { item in
                        switch item {
                        case .file(let file, let isNested):
                            SinglePageFileRowView(
                                file: file,
                                isNested: isNested,
                                isEditMode: isEditMode,
                                orderedFolders: cachedOrderedFolders,
                                accentColor: accentColor,
                                onMoveToFolder: { folderId in
                                    moveFileToFolder(file: file, folderId: folderId)
                                },
                                onRemoveFromFolder: {
                                    removeFileFromFolder(file: file)
                                }
                            )
                        case .folder(let folder):
                            SinglePageFolderRowView(
                                folder: folder,
                                isEditMode: isEditMode,
                                accentColor: accentColor,
                                onTap: { toggleFolder(id: folder.id) }
                            )
                        case .dropZone:
                            EmptyView()
                        }
                    }
                    .onMove(perform: isEditMode ? moveItem : nil)
                }
                .listStyle(.plain)
                .environment(\.editMode, isEditMode ? .constant(.active) : .constant(.inactive))

                // FAB for New Journal
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            addNewFile()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                    .font(.system(size: Layout.fabIconSize, weight: .semibold))
                                Text("New Journal")
                                    .font(.system(size: Layout.fabIconSize, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, Layout.fabHorizontalPadding)
                            .padding(.vertical, Layout.fabVerticalPadding)
                            .background(
                                Capsule()
                                    .fill(Color(white: 0.2))
                            )
                            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .accessibilityLabel("New Journal")
                        .accessibilityHint("Creates a new journal entry")
                        .padding(.trailing, Layout.fabTrailing)
                        .padding(.bottom, Layout.fabBottom)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 12) {
                        Button {
                            addNewFolder()
                        } label: {
                            Image(systemName: "folder.badge.plus")
                                .foregroundColor(accentColor)
                        }
                        .accessibilityLabel("New Folder")
                        .accessibilityHint("Creates a new folder for organizing journal entries")

                        Button(isEditMode ? "Done" : "Edit") {
                            withAnimation {
                                isEditMode.toggle()
                            }
                        }
                        .foregroundColor(accentColor)
                        .accessibilityLabel(isEditMode ? "Done editing" : "Edit")
                        .accessibilityHint(isEditMode ? "Exits edit mode" : "Enables drag and drop to reorder items")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundColor(accentColor)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear {
            if rootItems.isEmpty {
                initializeDefaultData()
            }
            rebuildCache()
        }
    }

    // MARK: - Cache Management

    private func rebuildCache() {
        // Rebuild displayed items
        var result: [DisplayNode] = []
        for item in rootItems {
            result.append(item)
            if case .folder(let folder) = item, folder.isExpanded {
                result.append(contentsOf: folder.contents.map { .file($0, isNested: true) })
            }
        }
        cachedDisplayedItems = result

        // Rebuild ordered folders
        cachedOrderedFolders = rootItems.compactMap { item in
            if case .folder(let folder) = item {
                return folder
            }
            return nil
        }
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

    func toggleFolder(id: UUID) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if let index = findFolderIndex(id: id),
               case .folder(var folder) = rootItems[index] {
                folder.isExpanded.toggle()
                updateFolder(folder)
                rebuildCache()
            }
        }
    }

    func addNewFolder() {
        withAnimation {
            // Find the next available folder name
            let newFolderName = generateNextFolderName()

            // Create new folder
            let newFolder = FolderNode(name: newFolderName, contents: [], isExpanded: false)

            // Add to folders dictionary
            folders[newFolder.id] = newFolder

            // Append to rootItems
            rootItems.append(.folder(newFolder))
            rebuildCache()
        }
    }

    private func generateNextFolderName() -> String {
        let existingNames = Set(folders.values.map { $0.name })

        // Start with 'C' (since A and B are in default data)
        var suffix = "C"

        // Keep incrementing until we find an unused name
        while existingNames.contains("Folder \(suffix)") {
            suffix = incrementFolderSuffix(suffix)
        }

        return "Folder \(suffix)"
    }

    private func incrementFolderSuffix(_ suffix: String) -> String {
        // Handle letter incrementing: C -> D -> ... -> Z -> AA -> AB -> ...
        var chars = Array(suffix)
        var index = chars.count - 1

        while index >= 0 {
            if chars[index] < "Z" {
                // Increment current character
                chars[index] = Character(UnicodeScalar(chars[index].asciiValue! + 1))
                return String(chars)
            } else {
                // Current character is 'Z', wrap to 'A' and carry
                chars[index] = "A"
                index -= 1
            }
        }

        // If we get here, all characters were 'Z', so add 'A' at the front
        // Z -> AA, ZZ -> AAA, etc.
        return "A" + String(chars)
    }

    func addNewFile() {
        withAnimation {
            // Find the next row number using Set for O(n) lookup
            let existingRowNumbers = getAllFileNumbers()

            // Find next available number
            var nextNumber = 1
            while existingRowNumbers.contains(nextNumber) {
                nextNumber += 1
            }

            // Create new file
            let newFile = FileNode(name: "Row \(nextNumber)")

            // Append to rootItems
            rootItems.append(.file(newFile, isNested: false))
            rebuildCache()
        }
    }

    private func getAllFileNumbers() -> Set<Int> {
        var numbers = Set<Int>()

        // Check root-level files
        for item in rootItems {
            if case .file(let file, _) = item {
                if let number = extractRowNumber(from: file.name) {
                    numbers.insert(number)
                }
            }
        }

        // Check files in folders
        for folder in folders.values {
            for file in folder.contents {
                if let number = extractRowNumber(from: file.name) {
                    numbers.insert(number)
                }
            }
        }

        return numbers
    }

    private func extractRowNumber(from name: String) -> Int? {
        if name.hasPrefix("Row ") {
            let numberString = name.dropFirst(4)
            return Int(numberString)
        }
        return nil
    }

    func findFolderIndex(id: UUID) -> Int? {
        rootItems.firstIndex { item in
            if case .folder(let f) = item, f.id == id {
                return true
            }
            return false
        }
    }

    func updateFolder(_ folder: FolderNode) {
        #if DEBUG
        print("updateFolder called: \(folder.name), contents: \(folder.contents.map { $0.name })")
        #endif

        // Check if folder is empty and should be auto-deleted
        if Config.autoDeleteEmptyFolders && folder.contents.isEmpty {
            deleteFolder(folder.id)
            return
        }

        folders[folder.id] = folder
        if let index = findFolderIndex(id: folder.id) {
            rootItems[index] = .folder(folder)
            #if DEBUG
            print("Updated rootItems[\(index)] with folder: \(folder.name)")
            #endif
        } else {
            #if DEBUG
            print("WARNING: Could not find folder \(folder.name) in rootItems")
            #endif
        }

        #if DEBUG
        validateStateSync()
        #endif
    }

    #if DEBUG
    /// Validates that rootItems and folders dictionary are in sync
    /// Only runs in DEBUG builds for development-time verification
    private func validateStateSync() {
        // Extract all folders from rootItems
        let foldersInRootItems = rootItems.compactMap { item -> FolderNode? in
            if case .folder(let folder) = item {
                return folder
            }
            return nil
        }

        // Check count matches
        if foldersInRootItems.count != folders.count {
            print("⚠️ SYNC ERROR: rootItems has \(foldersInRootItems.count) folders, but folders dictionary has \(folders.count)")
        }

        // Check each folder in rootItems exists in dictionary with same data
        for rootFolder in foldersInRootItems {
            if let dictFolder = folders[rootFolder.id] {
                // Verify contents match
                if rootFolder.contents.count != dictFolder.contents.count {
                    print("⚠️ SYNC ERROR: Folder \(rootFolder.name) has different content counts: rootItems=\(rootFolder.contents.count), dict=\(dictFolder.contents.count)")
                }
                // Verify expansion state matches
                if rootFolder.isExpanded != dictFolder.isExpanded {
                    print("⚠️ SYNC ERROR: Folder \(rootFolder.name) has different expansion state: rootItems=\(rootFolder.isExpanded), dict=\(dictFolder.isExpanded)")
                }
            } else {
                print("⚠️ SYNC ERROR: Folder \(rootFolder.name) (\(rootFolder.id)) exists in rootItems but not in folders dictionary")
            }
        }

        // Check for orphaned folders in dictionary
        for (id, dictFolder) in folders {
            if !foldersInRootItems.contains(where: { $0.id == id }) {
                print("⚠️ SYNC ERROR: Folder \(dictFolder.name) (\(id)) exists in folders dictionary but not in rootItems")
            }
        }
    }
    #endif

    private func deleteFolder(_ folderId: UUID) {
        #if DEBUG
        print("Deleting empty folder: \(folders[folderId]?.name ?? "unknown")")
        #endif

        // Remove from folders dictionary
        folders.removeValue(forKey: folderId)

        // Remove from rootItems
        rootItems.removeAll { item in
            if case .folder(let folder) = item, folder.id == folderId {
                return true
            }
            return false
        }
    }

    func moveFileToFolder(file: FileNode, folderId: UUID) {
        guard var folder = folders[folderId] else { return }

        withAnimation {
            // Remove from current location
            removeFileFromSource(file)

            // Add to folder
            folder.contents.append(file)

            // Expand folder to show the moved file
            folder.isExpanded = true
            updateFolder(folder)
            rebuildCache()
        }
    }

    func removeFileFromFolder(file: FileNode) {
        withAnimation {
            // Find which folder contains this file
            var parentFolderId: UUID?
            var parentFolderIndex: Int?

            for (index, item) in rootItems.enumerated() {
                if case .folder(let folder) = item {
                    if folder.contents.contains(where: { $0.id == file.id }) {
                        parentFolderId = folder.id
                        parentFolderIndex = index
                        break
                    }
                }
            }

            guard let folderId = parentFolderId,
                  let folderIndex = parentFolderIndex,
                  var folder = folders[folderId] else { return }

            // Remove from folder
            folder.contents.removeAll { $0.id == file.id }
            updateFolder(folder)

            // Insert at root level directly below the folder
            rootItems.insert(.file(file, isNested: false), at: folderIndex + 1)
            rebuildCache()
        }
    }

    func removeFileFromSource(_ file: FileNode) {
        #if DEBUG
        print("removeFileFromSource called for: \(file.name)")
        #endif
        // Try root first
        if let index = rootItems.firstIndex(where: {
            if case .file(let f, _) = $0, f.id == file.id { return true }
            return false
        }) {
            rootItems.remove(at: index)
            #if DEBUG
            print("Removed \(file.name) from rootItems at index \(index)")
            #endif
            return
        }

        // Try folders
        for (_, var folder) in folders {
            if let index = folder.contents.firstIndex(where: { $0.id == file.id }) {
                folder.contents.remove(at: index)
                #if DEBUG
                print("Removed \(file.name) from folder \(folder.name) at index \(index)")
                #endif
                updateFolder(folder)
                return
            }
        }

        #if DEBUG
        print("WARNING: Could not find \(file.name) to remove")
        #endif
    }

    // MARK: - Move Item Helpers

    private func determineMoveOperation(movedItem: DisplayNode, sourceIndex: Int, destination: Int) -> MoveOperation {
        // Don't allow moving drop zones
        if case .dropZone = movedItem {
            return .invalid
        }

        // Handle folder moves
        if case .folder = movedItem {
            let rootIndex = mapDisplayIndexToRootIndex(sourceIndex)
            let destRootIndex = mapDisplayIndexToRootIndex(destination)

            guard rootIndex >= 0 && rootIndex < rootItems.count else { return .invalid }
            guard destRootIndex >= 0 && destRootIndex <= rootItems.count else { return .invalid }

            return .folderMove(fromRootIndex: rootIndex, toRootIndex: destRootIndex)
        }

        // Handle file moves
        guard case .file(let file, _) = movedItem else { return .invalid }

        let sourceContext = getItemContext(at: sourceIndex)
        var destinationContext = getItemContext(at: destination)

        // Edge case: When dragging to position after last item in folder,
        // destination might point to next item outside folder
        if case .inFolder(let sourceFolderId) = sourceContext,
           destinationContext != sourceContext {
            if let folderIndex = cachedDisplayedItems.firstIndex(where: { item in
                if case .folder(let f) = item, f.id == sourceFolderId { return true }
                return false
            }),
               case .folder(let sourceFolder) = cachedDisplayedItems[folderIndex] {
                let folderEndIndex = folderIndex + sourceFolder.contents.count
                if destination == folderEndIndex + 1 {
                    destinationContext = .inFolder(sourceFolderId)
                }
            }
        }

        // Same context move
        if sourceContext == destinationContext {
            return .sameContextMove(sourceContext: sourceContext, fromIndex: sourceIndex, toIndex: destination)
        }

        // Cross-level move
        return .crossLevelMove(file: file, fromContext: sourceContext, toContext: destinationContext, destination: destination)
    }

    private func performFolderMove(fromRootIndex: Int, toRootIndex: Int) {
        #if DEBUG
        print("Moving folder: rootIndex \(fromRootIndex) -> \(toRootIndex)")
        #endif

        rootItems.move(
            fromOffsets: IndexSet(integer: fromRootIndex),
            toOffset: toRootIndex
        )

        #if DEBUG
        print("Folder moved successfully")
        #endif
    }

    private func performSameContextMove(sourceContext: ItemContext, fromIndex: Int, toIndex: Int) {
        if sourceContext == .root {
            // Moving at root level - simple reorder
            let rootIndex = mapDisplayIndexToRootIndex(fromIndex)
            let destRootIndex = mapDisplayIndexToRootIndex(toIndex)

            #if DEBUG
            print("Root-level move: displayIndex \(fromIndex) -> \(toIndex), rootIndex \(rootIndex) -> \(destRootIndex)")
            print("Current rootItems count: \(rootItems.count)")
            #endif

            guard rootIndex >= 0 && rootIndex < rootItems.count else {
                #if DEBUG
                print("Invalid rootIndex: \(rootIndex)")
                #endif
                return
            }

            guard destRootIndex >= 0 && destRootIndex <= rootItems.count else {
                #if DEBUG
                print("Invalid destRootIndex: \(destRootIndex)")
                #endif
                return
            }

            rootItems.move(
                fromOffsets: IndexSet(integer: rootIndex),
                toOffset: destRootIndex
            )
        } else if case .inFolder(let folderId) = sourceContext,
                  var folder = folders[folderId] {
            // Moving within same folder - reorder contents
            let folderStartIndex = cachedDisplayedItems.firstIndex { item in
                if case .folder(let f) = item, f.id == folderId { return true }
                return false
            }

            if let folderStart = folderStartIndex {
                let sourceInFolder = fromIndex - folderStart - 1
                let destInFolder = toIndex - folderStart - 1

                // Validate indices
                guard sourceInFolder >= 0 && sourceInFolder < folder.contents.count else {
                    #if DEBUG
                    print("Invalid sourceInFolder: \(sourceInFolder), folder.contents.count: \(folder.contents.count)")
                    #endif
                    return
                }

                guard destInFolder >= 0 && destInFolder <= folder.contents.count else {
                    #if DEBUG
                    print("Invalid destInFolder: \(destInFolder), folder.contents.count: \(folder.contents.count)")
                    #endif
                    return
                }

                folder.contents.move(
                    fromOffsets: IndexSet(integer: sourceInFolder),
                    toOffset: destInFolder
                )
                updateFolder(folder)
            }
        }
    }

    private func performCrossLevelMove(file: FileNode, fromContext: ItemContext, toContext: ItemContext, destination: Int) {
        // IMPORTANT: Calculate destination positions BEFORE modifying state
        // because removal changes folder item counts and affects index mapping
        var calculatedInsertPosition: Int?
        var calculatedFolderId: UUID?

        if case .inFolder(let destFolderId) = toContext,
           let destFolder = folders[destFolderId] {
            // Calculate position in folder BEFORE any changes
            if let folderStartIndex = cachedDisplayedItems.firstIndex(where: { item in
                if case .folder(let f) = item, f.id == destFolderId { return true }
                return false
            }) {
                let positionInFolder = destination - folderStartIndex - 1
                calculatedInsertPosition = max(0, min(positionInFolder, destFolder.contents.count))
                calculatedFolderId = destFolderId
            }
        } else {
            // Calculate root position BEFORE any changes
            calculatedInsertPosition = mapDisplayIndexToRootIndex(destination)
        }

        // Now remove from source
        removeFileFromSource(file)

        // Add to destination using pre-calculated positions
        if let folderId = calculatedFolderId,
           let insertPos = calculatedInsertPosition,
           var destFolder = folders[folderId] {
            // Moving into a folder
            let finalInsertPosition = min(insertPos, destFolder.contents.count)

            #if DEBUG
            print("Cross-level move into folder: insertPosition=\(finalInsertPosition), folder.contents.count=\(destFolder.contents.count)")
            #endif

            destFolder.contents.insert(file, at: finalInsertPosition)

            // Expand folder to show the moved file
            if !destFolder.isExpanded {
                destFolder.isExpanded = true
            }

            updateFolder(destFolder)
        } else if let insertPos = calculatedInsertPosition {
            // Moving to root level
            let finalInsertPosition = min(insertPos, rootItems.count)

            #if DEBUG
            print("Cross-level move to root: insertPosition=\(finalInsertPosition), rootItems.count=\(rootItems.count)")
            #endif

            rootItems.insert(.file(file, isNested: false), at: finalInsertPosition)
        }
    }

    func moveItem(from source: IndexSet, to destination: Int) {
        guard let sourceIndex = source.first else { return }
        let movedItem = cachedDisplayedItems[sourceIndex]

        #if DEBUG
        print("\n=== MOVE ITEM START ===")
        print("Source index: \(sourceIndex), Destination: \(destination)")
        #endif

        // Determine the type of move operation
        let operation = determineMoveOperation(movedItem: movedItem, sourceIndex: sourceIndex, destination: destination)

        withAnimation {
            // Execute the appropriate move operation
            switch operation {
            case .folderMove(let fromRootIndex, let toRootIndex):
                performFolderMove(fromRootIndex: fromRootIndex, toRootIndex: toRootIndex)

            case .sameContextMove(let sourceContext, let fromIndex, let toIndex):
                performSameContextMove(sourceContext: sourceContext, fromIndex: fromIndex, toIndex: toIndex)

            case .crossLevelMove(let file, _, let toContext, let destination):
                #if DEBUG
                print("Moving file: \(file.name)")
                #endif
                performCrossLevelMove(file: file, fromContext: getItemContext(at: sourceIndex), toContext: toContext, destination: destination)

            case .invalid:
                #if DEBUG
                print("Invalid move operation")
                #endif
                return
            }

            #if DEBUG
            print("=== MOVE ITEM END ===")
            let rootItemsDescription = rootItems.map { item -> String in
                switch item {
                case .file(let f, _): return f.name
                case .folder(let f): return "\(f.name)(\(f.contents.count))"
                case .dropZone: return "dropZone"
                }
            }
            print("Final rootItems: \(rootItemsDescription)")
            print("Final folders contents:")
            for (_, folder) in folders {
                print("  \(folder.name): \(folder.contents.map { $0.name })")
            }
            print()
            #endif

            // Rebuild cache after all moves complete
            rebuildCache()
        }
    }

    func mapDisplayIndexToRootIndex(_ displayIndex: Int) -> Int {
        var rootCount = 0
        var currentDisplayIndex = 0

        for item in rootItems {
            // If we've reached or passed the target display index, return current root count
            if currentDisplayIndex >= displayIndex {
                return rootCount
            }

            // Count this root item
            currentDisplayIndex += 1

            // If it's an expanded folder, skip its contents in the display
            if case .folder(let folder) = item, folder.isExpanded {
                currentDisplayIndex += folder.contents.count
            }

            // Increment root count only after processing this item
            rootCount += 1
        }

        // If we've gone through all items, return the count (append at end)
        return rootCount
    }

    enum ItemContext: Equatable {
        case root
        case inFolder(UUID)
    }

    enum MoveOperation {
        case folderMove(fromRootIndex: Int, toRootIndex: Int)
        case sameContextMove(sourceContext: ItemContext, fromIndex: Int, toIndex: Int)
        case crossLevelMove(file: FileNode, fromContext: ItemContext, toContext: ItemContext, destination: Int)
        case invalid
    }

    func getItemContext(at index: Int) -> ItemContext {
        guard index < cachedDisplayedItems.count else { return .root }

        // Walk backwards to find the containing folder
        for i in stride(from: index, through: 0, by: -1) {
            if case .folder(let folder) = cachedDisplayedItems[i] {
                // Check if we're within this folder's expanded contents
                if folder.isExpanded && i < index {
                    // Check if index is within the folder's content range
                    let folderEndIndex = i + folder.contents.count
                    if index > i && index <= folderEndIndex {
                        return .inFolder(folder.id)
                    }
                    // If we're past this folder's contents, continue searching backwards
                }
                // If folder is collapsed or we're at/before the folder, we're at root
                if i == index {
                    return .root
                }
            }
        }

        return .root
    }
}

// MARK: - Single Page File Row View

struct SinglePageFileRowView: View {
    let file: FileNode
    let isNested: Bool
    let isEditMode: Bool
    let orderedFolders: [FolderNode]
    let accentColor: Color
    let onMoveToFolder: (UUID) -> Void
    let onRemoveFromFolder: () -> Void

    private enum Layout {
        static let iconSize: CGFloat = 28
        static let rowSpacing: CGFloat = 12
        static let rowVerticalPadding: CGFloat = 2
        static let nestedIndentation: CGFloat = 32
    }

    var body: some View {
        HStack(spacing: Layout.rowSpacing) {
            Circle()
                .fill(gradientForFile(file.name))
                .frame(width: Layout.iconSize, height: Layout.iconSize)
                .overlay(
                    Text(String(file.name.prefix(1)))
                        .font(.caption)
                        .foregroundColor(.white)
                )
                .accessibilityHidden(true)

            Text(file.name)
                .font(.body)

            Spacer()

            if isEditMode {
                // Show folder add/remove icon
                if isNested {
                    // In a folder - show remove icon
                    Button {
                        onRemoveFromFolder()
                    } label: {
                        Image(systemName: "folder.badge.minus")
                            .foregroundColor(accentColor)
                            .font(.body)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Remove \(file.name) from folder")
                    .accessibilityHint("Moves this item to the root level")
                } else {
                    // At root - show add to folder menu
                    Menu {
                        ForEach(orderedFolders, id: \.id) { folder in
                            Button {
                                onMoveToFolder(folder.id)
                            } label: {
                                Label(folder.name, systemImage: "folder")
                            }
                            .accessibilityLabel("Move to \(folder.name)")
                            .accessibilityHint("Moves \(file.name) into \(folder.name) folder")
                        }
                    } label: {
                        Image(systemName: "folder.badge.plus")
                            .foregroundColor(accentColor)
                            .font(.body)
                    }
                    .accessibilityLabel("Add \(file.name) to folder")
                    .accessibilityHint("Choose a folder to move this item into")
                }
            }
        }
        .padding(.vertical, Layout.rowVerticalPadding)
        .padding(.leading, isNested ? Layout.nestedIndentation : 0)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(file.name)
        .accessibilityHint(isEditMode ? "Drag to reorder" : "")
        .accessibilityValue(isNested ? "In folder" : "At root level")
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

// MARK: - Single Page Folder Row View

struct SinglePageFolderRowView: View {
    let folder: FolderNode
    let isEditMode: Bool
    let accentColor: Color
    let onTap: () -> Void

    private enum Layout {
        static let rowSpacing: CGFloat = 12
        static let rowVerticalPadding: CGFloat = 2
    }

    var body: some View {
        HStack(spacing: Layout.rowSpacing) {
            Image(systemName: "folder.fill")
                .font(.callout)
                .foregroundColor(accentColor)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 0) {
                Text(folder.name)
                    .font(.body)
                Text("\(folder.itemCount) items")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
                .rotationEffect(.degrees(folder.isExpanded ? 90 : 0))
                .accessibilityHidden(true)
        }
        .padding(.vertical, Layout.rowVerticalPadding)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(folder.name) folder")
        .accessibilityValue("\(folder.itemCount) items, \(folder.isExpanded ? "expanded" : "collapsed")")
        .accessibilityHint("Tap to \(folder.isExpanded ? "collapse" : "expand") folder\(isEditMode ? ", or drag to reorder" : "")")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Preview

#Preview {
    SinglePageRowsAndFoldersView()
}
