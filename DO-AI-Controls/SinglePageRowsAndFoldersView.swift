//
//  SinglePageRowsAndFoldersView.swift
//  DO-AI-Controls
//
//  Created by Paul Mayne on 12/30/25.
//

import SwiftUI

// MARK: - Single Page View

struct SinglePageRowsAndFoldersView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var rootItems: [DisplayNode] = []
    @State private var folders: [UUID: FolderNode] = [:]
    @State private var isEditMode = false

    let accentColor = Color(hex: "44C0FF")

    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(displayedItems) { item in
                        switch item {
                        case .file(let file, let isNested):
                            SinglePageFileRowView(
                                file: file,
                                isNested: isNested,
                                isEditMode: isEditMode,
                                orderedFolders: orderedFolders,
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
                                    .font(.system(size: 16, weight: .semibold))
                                Text("New Journal")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .fill(Color(white: 0.2))
                            )
                            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
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

                        Button(isEditMode ? "Done" : "Edit") {
                            withAnimation {
                                isEditMode.toggle()
                            }
                        }
                        .foregroundColor(accentColor)
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
        }
    }

    var displayedItems: [DisplayNode] {
        var result: [DisplayNode] = []
        for item in rootItems {
            result.append(item)
            if case .folder(let folder) = item, folder.isExpanded {
                result.append(contentsOf: folder.contents.map { .file($0, isNested: true) })
            }
        }
        return result
    }

    var orderedFolders: [FolderNode] {
        // Extract folders in the order they appear in rootItems
        rootItems.compactMap { item in
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
            }
        }
    }

    func addNewFolder() {
        withAnimation {
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
        }
    }

    func addNewFile() {
        withAnimation {
            // Find the next row number by checking all existing files
            var existingRowNumbers: [Int] = []

            // Check root-level files
            for item in rootItems {
                if case .file(let file, _) = item {
                    if let number = extractRowNumber(from: file.name) {
                        existingRowNumbers.append(number)
                    }
                }
            }

            // Check files in folders
            for folder in folders.values {
                for file in folder.contents {
                    if let number = extractRowNumber(from: file.name) {
                        existingRowNumbers.append(number)
                    }
                }
            }

            // Find next available number
            var nextNumber = 1
            while existingRowNumbers.contains(nextNumber) {
                nextNumber += 1
            }

            // Create new file
            let newFile = FileNode(name: "Row \(nextNumber)")

            // Append to rootItems
            rootItems.append(.file(newFile, isNested: false))
        }
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
        print("updateFolder called: \(folder.name), contents: \(folder.contents.map { $0.name })")
        folders[folder.id] = folder
        if let index = findFolderIndex(id: folder.id) {
            rootItems[index] = .folder(folder)
            print("Updated rootItems[\(index)] with folder: \(folder.name)")
        } else {
            print("WARNING: Could not find folder \(folder.name) in rootItems")
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
        }
    }

    func removeFileFromSource(_ file: FileNode) {
        print("removeFileFromSource called for: \(file.name)")
        // Try root first
        if let index = rootItems.firstIndex(where: {
            if case .file(let f, _) = $0, f.id == file.id { return true }
            return false
        }) {
            rootItems.remove(at: index)
            print("Removed \(file.name) from rootItems at index \(index)")
            return
        }

        // Try folders
        for (_, var folder) in folders {
            if let index = folder.contents.firstIndex(where: { $0.id == file.id }) {
                folder.contents.remove(at: index)
                print("Removed \(file.name) from folder \(folder.name) at index \(index)")
                updateFolder(folder)
                return
            }
        }

        print("WARNING: Could not find \(file.name) to remove")
    }

    func moveItem(from source: IndexSet, to destination: Int) {
        guard let sourceIndex = source.first else { return }
        let movedItem = displayedItems[sourceIndex]

        print("\n=== MOVE ITEM START ===")
        print("Source index: \(sourceIndex), Destination: \(destination)")

        // Don't allow moving drop zones
        if case .dropZone = movedItem {
            return
        }

        withAnimation {
            // Handle folder moves (only at root level)
            if case .folder(let folder) = movedItem {
                print("Moving folder: \(folder.name)")

                // Folders can only be moved at root level
                let rootIndex = mapDisplayIndexToRootIndex(sourceIndex)
                let destRootIndex = mapDisplayIndexToRootIndex(destination)

                print("Folder move: displayIndex \(sourceIndex) -> \(destination), rootIndex \(rootIndex) -> \(destRootIndex)")

                guard rootIndex >= 0 && rootIndex < rootItems.count else {
                    print("Invalid rootIndex: \(rootIndex)")
                    return
                }

                guard destRootIndex >= 0 && destRootIndex <= rootItems.count else {
                    print("Invalid destRootIndex: \(destRootIndex)")
                    return
                }

                rootItems.move(
                    fromOffsets: IndexSet(integer: rootIndex),
                    toOffset: destRootIndex
                )

                print("Folder moved successfully")
                return
            }

            // Handle file moves
            guard case .file(let file, _) = movedItem else { return }
            print("Moving file: \(file.name)")
            // Determine context of source and destination
            let sourceContext = getItemContext(at: sourceIndex)
            let destinationContext = getItemContext(at: destination)

            // Case 1: Moving within the same context (same level)
            if sourceContext == destinationContext {
                if sourceContext == .root {
                    // Moving at root level - simple reorder
                    let rootIndex = mapDisplayIndexToRootIndex(sourceIndex)
                    let destRootIndex = mapDisplayIndexToRootIndex(destination)

                    print("Root-level move: displayIndex \(sourceIndex) -> \(destination), rootIndex \(rootIndex) -> \(destRootIndex)")
                    print("Current rootItems count: \(rootItems.count)")

                    guard rootIndex >= 0 && rootIndex < rootItems.count else {
                        print("Invalid rootIndex: \(rootIndex)")
                        return
                    }

                    guard destRootIndex >= 0 && destRootIndex <= rootItems.count else {
                        print("Invalid destRootIndex: \(destRootIndex)")
                        return
                    }

                    rootItems.move(
                        fromOffsets: IndexSet(integer: rootIndex),
                        toOffset: destRootIndex
                    )
                } else if case .inFolder(let folderId) = sourceContext,
                          var folder = folders[folderId] {
                    // Moving within same folder - reorder contents
                    let folderStartIndex = displayedItems.firstIndex { item in
                        if case .folder(let f) = item, f.id == folderId { return true }
                        return false
                    }

                    if let folderStart = folderStartIndex {
                        let sourceInFolder = sourceIndex - folderStart - 1
                        let destInFolder = destination - folderStart - 1

                        // Validate indices
                        guard sourceInFolder >= 0 && sourceInFolder < folder.contents.count else {
                            print("Invalid sourceInFolder: \(sourceInFolder), folder.contents.count: \(folder.contents.count)")
                            return
                        }

                        guard destInFolder >= 0 && destInFolder <= folder.contents.count else {
                            print("Invalid destInFolder: \(destInFolder), folder.contents.count: \(folder.contents.count)")
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
            // Case 2: Moving between different contexts (cross-level move)
            else {
                // Remove from source
                removeFileFromSource(file)

                // Add to destination
                if case .inFolder(let destFolderId) = destinationContext,
                   var destFolder = folders[destFolderId] {
                    // Moving into a folder
                    let folderStartIndex = displayedItems.firstIndex { item in
                        if case .folder(let f) = item, f.id == destFolderId { return true }
                        return false
                    }

                    if let folderStart = folderStartIndex {
                        let positionInFolder = destination - folderStart - 1
                        let insertPosition = max(0, min(positionInFolder, destFolder.contents.count))

                        print("Cross-level move into folder: positionInFolder=\(positionInFolder), insertPosition=\(insertPosition), folder.contents.count=\(destFolder.contents.count)")

                        destFolder.contents.insert(file, at: insertPosition)

                        // Expand folder to show the moved file
                        if !destFolder.isExpanded {
                            destFolder.isExpanded = true
                        }

                        updateFolder(destFolder)
                    }
                } else {
                    // Moving to root level
                    let rootPosition = mapDisplayIndexToRootIndex(destination)
                    let insertPosition = min(rootPosition, rootItems.count)

                    print("Cross-level move to root: rootPosition=\(rootPosition), insertPosition=\(insertPosition), rootItems.count=\(rootItems.count)")

                    rootItems.insert(.file(file, isNested: false), at: insertPosition)
                }
            }

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

    func getItemContext(at index: Int) -> ItemContext {
        guard index < displayedItems.count else { return .root }

        // Walk backwards to find the containing folder
        for i in stride(from: index, through: 0, by: -1) {
            if case .folder(let folder) = displayedItems[i] {
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

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(gradientForFile(file.name))
                .frame(width: 28, height: 28)
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
                } else {
                    // At root - show add to folder menu
                    Menu {
                        ForEach(orderedFolders, id: \.id) { folder in
                            Button {
                                onMoveToFolder(folder.id)
                            } label: {
                                Label(folder.name, systemImage: "folder")
                            }
                        }
                    } label: {
                        Image(systemName: "folder.badge.plus")
                            .foregroundColor(accentColor)
                            .font(.body)
                    }
                }
            }
        }
        .padding(.vertical, 2)
        .padding(.leading, isNested ? 32 : 0)
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

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "folder.fill")
                .font(.callout)
                .foregroundColor(accentColor)

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
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Preview

#Preview {
    SinglePageRowsAndFoldersView()
}
