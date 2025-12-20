//
//  RowSortingWithFoldersView.swift
//  DO-AI-Controls
//
//  Created by Paul Mayne on 12/19/25.
//

import SwiftUI

// MARK: - Models

struct RowItem: Identifiable, Equatable {
    let id: UUID = UUID()
    let letter: String
}

struct FolderItem: Identifiable, Equatable {
    let id: UUID = UUID()
    var name: String
    var contents: [RowItem]
    var isExpanded: Bool = false

    var itemCount: Int { contents.count }
}

enum ListItemType: Identifiable, Equatable {
    case row(RowItem)
    case folder(FolderItem)
    case dropZone(UUID)  // Associated value is the folder's UUID

    var id: UUID {
        switch self {
        case .row(let item):
            return item.id
        case .folder(let item):
            return item.id
        case .dropZone(let folderId):
            // Create a unique ID by combining folder ID with a namespace
            // This ensures drop zones don't collide with folder IDs
            return UUID(uuidString: "00000000-0000-0000-0000-\(folderId.uuidString.suffix(12))")!
        }
    }
}

// MARK: - Drop Intent

enum DropIntent {
    case intoFolder(folderId: UUID, position: InsertPosition)
    case atRootLevel(position: Int)

    enum InsertPosition {
        case at(Int)      // Specific position in array
        case end          // Append to end
    }
}

// MARK: - Main View

struct RowSortingWithFoldersView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var rootItems: [ListItemType] = [] // Source of truth: only top-level items
    @State private var items: [ListItemType] = [] // Display array: flattened with expansions
    @State private var folders: [UUID: FolderItem] = [:]

    let accentColor = Color(hex: "44C0FF")

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    switch item {
                    case .row(let rowItem):
                        RowCellView(
                            letter: rowItem.letter,
                            isInFolder: isItemInExpandedFolder(at: index),
                            accentColor: accentColor
                        )
                    case .folder(let folder):
                        FolderCellView(
                            folder: folder,
                            accentColor: accentColor,
                            onTap: {
                                toggleFolder(id: folder.id)
                            }
                        )
                    case .dropZone:
                        DropZoneView(accentColor: accentColor)
                    }
                }
                .onMove(perform: moveItem)
            }
            .listStyle(.plain)
            .environment(\.editMode, .constant(.active))
            .navigationTitle("Row Sorting")
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
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear {
            if rootItems.isEmpty {
                initializeDefaultState()
            }
        }
    }

    // MARK: - Helper Functions

    func initializeDefaultState() {
        // Create 20 alphabet items A through T
        let letters = Array("ABCDEFGHIJKLMNOPQRST").map { String($0) }
        let allRows = letters.map { RowItem(letter: $0) }

        // Create folder One with rows C and D (indices 2, 3)
        let folderOne = FolderItem(
            name: "One",
            contents: [allRows[2], allRows[3]], // C, D
            isExpanded: false
        )
        folders[folderOne.id] = folderOne

        // Create folder Two with rows F and G (indices 5, 6)
        let folderTwo = FolderItem(
            name: "Two",
            contents: [allRows[5], allRows[6]], // F, G
            isExpanded: false
        )
        folders[folderTwo.id] = folderTwo

        // Build initial root list: A, B, [Folder One], E, [Folder Two], H-T
        var initialItems: [ListItemType] = []
        initialItems.append(.row(allRows[0])) // A
        initialItems.append(.row(allRows[1])) // B
        initialItems.append(.folder(folderOne))
        initialItems.append(.row(allRows[4])) // E
        initialItems.append(.folder(folderTwo))
        // Add H through T (indices 7-19)
        for i in 7..<allRows.count {
            initialItems.append(.row(allRows[i]))
        }

        rootItems = initialItems
        rebuildFlatList()
    }

    func toggleFolder(id: UUID) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            // Find folder in rootItems array
            if let index = rootItems.firstIndex(where: {
                if case .folder(let f) = $0, f.id == id {
                    return true
                }
                return false
            }) {
                if case .folder(var folder) = rootItems[index] {
                    folder.isExpanded.toggle()
                    folders[folder.id] = folder
                    rootItems[index] = .folder(folder)
                    rebuildFlatList()
                }
            }
        }
    }

    func moveItem(from source: IndexSet, to destination: Int) {
        guard let sourceIndex = source.first else { return }
        guard sourceIndex < items.count else { return }

        let movedItem = items[sourceIndex]

        // Don't allow dragging drop zones
        if case .dropZone = movedItem {
            return
        }

        // STEP 1: Determine what the user wants BEFORE modifying anything
        let intent = determineDropIntent(destination: destination, movingFrom: sourceIndex)

        // STEP 2: Remove item from current location
        removeItemFromSource(movedItem)

        // STEP 3: Insert at destination based on intent
        insertItem(movedItem, intent: intent)

        // STEP 4: Rebuild display
        rebuildFlatList()
    }

    func determineDropIntent(destination: Int, movingFrom sourceIndex: Int) -> DropIntent {
        // Use destination directly to see what we're inserting BEFORE
        guard destination < items.count else {
            // Dropping at the end
            return .atRootLevel(position: rootItems.count)
        }

        let targetItem = items[destination]
        let sourceParentFolder = findParentFolder(at: sourceIndex)

        switch targetItem {
        case .dropZone(let folderId):
            // Rule 1: Dropping before a drop zone = add to folder at end
            return .intoFolder(folderId: folderId, position: .end)

        case .row:
            // Rule 2: Check if this row is inside a folder
            if let (folder, positionInFolder) = findParentFolder(at: destination) {
                // Dropping inside a folder at specific position
                // Adjust position if moving within same folder
                var adjustedPosition = positionInFolder
                if let (sourceFolder, sourcePosition) = sourceParentFolder,
                   sourceFolder.id == folder.id,
                   sourcePosition < positionInFolder {
                    // Moving down within same folder - position shifts after removal
                    adjustedPosition -= 1
                }
                return .intoFolder(folderId: folder.id, position: .at(adjustedPosition))
            } else {
                // Row is at root level - insert before it
                var rootPosition = mapDisplayIndexToRootIndex(destination)
                // Adjust if source is at root level and before destination
                if sourceParentFolder == nil, sourceIndex < destination {
                    rootPosition -= 1
                }
                return .atRootLevel(position: rootPosition)
            }

        case .folder:
            // Rule 3: Dropping before a folder = root level
            var rootPosition = mapDisplayIndexToRootIndex(destination)
            // Adjust if source is at root level and before destination
            if sourceParentFolder == nil, sourceIndex < destination {
                rootPosition -= 1
            }
            return .atRootLevel(position: rootPosition)
        }
    }

    func insertItem(_ item: ListItemType, intent: DropIntent) {
        switch intent {
        case .intoFolder(let folderId, let position):
            guard case .row(let row) = item else {
                // Can't put folders inside folders - fall back to root
                rootItems.append(item)
                return
            }

            guard var folder = folders[folderId] else { return }

            switch position {
            case .at(let index):
                folder.contents.insert(row, at: min(index, folder.contents.count))
            case .end:
                folder.contents.append(row)
            }

            // Update folder in both dictionaries and rootItems
            folders[folderId] = folder
            if let rootIndex = rootItems.firstIndex(where: {
                if case .folder(let f) = $0, f.id == folderId { return true }
                return false
            }) {
                rootItems[rootIndex] = .folder(folder)
            }

        case .atRootLevel(let position):
            rootItems.insert(item, at: min(position, rootItems.count))
        }
    }

    func findParentFolder(at displayIndex: Int) -> (FolderItem, Int)? {
        // Check if displayIndex is inside an expanded folder
        // Returns (folder, position within folder) if inside a folder, nil otherwise
        var currentIndex = 0

        for rootItem in rootItems {
            if case .folder(let folder) = rootItem, folder.isExpanded {
                // This folder starts at currentIndex, its contents follow
                currentIndex += 1 // Skip the folder row itself

                // Check if displayIndex falls within this folder's contents
                let folderEndIndex = currentIndex + folder.contents.count - 1
                if displayIndex >= currentIndex && displayIndex <= folderEndIndex {
                    // displayIndex is inside this folder
                    let positionInFolder = displayIndex - currentIndex
                    return (folder, positionInFolder)
                }

                currentIndex += folder.contents.count  // Folder contents
                currentIndex += 1  // Drop zone after expanded folder
            } else if case .folder = rootItem {
                // Collapsed folder
                currentIndex += 1  // Folder row
                currentIndex += 1  // Drop zone after collapsed folder
            } else {
                // Regular row at root level
                currentIndex += 1
            }
        }

        return nil
    }

    func removeItemFromSource(_ item: ListItemType) {
        // Try to remove from rootItems first
        if let rootIndex = rootItems.firstIndex(where: { $0.id == item.id }) {
            rootItems.remove(at: rootIndex)
            return
        }

        // Otherwise, it must be inside a folder - remove from folder contents
        if case .row(let row) = item {
            for (folderId, var folder) in folders {
                if let rowIndex = folder.contents.firstIndex(where: { $0.id == row.id }) {
                    folder.contents.remove(at: rowIndex)
                    folders[folderId] = folder
                    // Update folder in rootItems
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
    }

    func mapDisplayIndexToRootIndex(_ displayIndex: Int) -> Int {
        // Map from items (display) index to rootItems index
        // Count how many rootItems appear before this displayIndex
        var rootCount = 0
        var currentDisplayIndex = 0

        for rootItem in rootItems {
            if currentDisplayIndex >= displayIndex {
                break
            }

            currentDisplayIndex += 1 // Count the root item itself

            // If it's a folder, skip its contents (if expanded) and always skip drop zone
            if case .folder(let folder) = rootItem {
                if folder.isExpanded {
                    currentDisplayIndex += folder.contents.count
                }
                currentDisplayIndex += 1  // Always skip drop zone after folder
            }

            rootCount += 1
        }

        return rootCount
    }

    func rebuildFlatList() {
        // Rebuild the flat list based on expanded state
        var newItems: [ListItemType] = []

        for item in rootItems {
            newItems.append(item)

            if case .folder(let folder) = item {
                if folder.isExpanded {
                    // Expanded: show contents
                    newItems.append(contentsOf: folder.contents.map { .row($0) })
                }
                // Always add drop zone after folder (whether expanded or collapsed)
                // This allows dropping after folder contents to exit the folder
                newItems.append(.dropZone(folder.id))
            }
        }

        items = newItems
    }

    func isItemInExpandedFolder(at index: Int) -> Bool {
        // Walk backwards from index to find if we're inside an expanded folder
        var itemsSeenSinceFolder = 0

        for i in stride(from: index - 1, through: 0, by: -1) {
            if case .folder(let folder) = items[i] {
                if folder.isExpanded {
                    // Check if we're within this folder's contents
                    return itemsSeenSinceFolder < folder.contents.count
                } else {
                    return false
                }
            }
            itemsSeenSinceFolder += 1
        }
        return false
    }

    func gradientForLetter(_ letter: String) -> LinearGradient {
        let colors: [Color] = [
            Color(hex: "FF6B6B"), Color(hex: "4ECDC4"), Color(hex: "45B7D1"),
            Color(hex: "FFA07A"), Color(hex: "98D8C8"), Color(hex: "F7DC6F"),
            Color(hex: "BB8FCE"), Color(hex: "85C1E2"), Color(hex: "F8B88B"),
            Color(hex: "52B788")
        ]

        // Use first character to pick color
        let charValue = letter.unicodeScalars.first?.value ?? 0
        let colorIndex = Int(charValue) % colors.count
        let color = colors[colorIndex]

        return LinearGradient(
            colors: [color, color.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Component Views

struct RowCellView: View {
    let letter: String
    let isInFolder: Bool
    let accentColor: Color

    var body: some View {
        HStack(spacing: 12) {
            if isInFolder {
                Spacer()
                    .frame(width: 20)
            }

            // Letter circle
            Circle()
                .fill(gradientForLetter(letter))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(letter)
                        .font(.headline)
                        .foregroundColor(.white)
                )

            Text("Row \(letter)")
                .font(.body)

            Spacer()
        }
        .padding(.vertical, 8)
    }

    func gradientForLetter(_ letter: String) -> LinearGradient {
        let colors: [Color] = [
            Color(hex: "FF6B6B"), Color(hex: "4ECDC4"), Color(hex: "45B7D1"),
            Color(hex: "FFA07A"), Color(hex: "98D8C8"), Color(hex: "F7DC6F"),
            Color(hex: "BB8FCE"), Color(hex: "85C1E2"), Color(hex: "F8B88B"),
            Color(hex: "52B788")
        ]

        let charValue = letter.unicodeScalars.first?.value ?? 0
        let colorIndex = Int(charValue) % colors.count
        let color = colors[colorIndex]

        return LinearGradient(
            colors: [color, color.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct FolderCellView: View {
    let folder: FolderItem
    let accentColor: Color
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Folder icon
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

            // Chevron
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

struct DropZoneView: View {
    let accentColor: Color

    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(height: 20)
            .overlay(
                Rectangle()
                    .strokeBorder(
                        style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                    )
                    .foregroundColor(accentColor.opacity(0.3))
                    .padding(.horizontal, 16)
            )
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
    }
}

// MARK: - Preview

#Preview {
    RowSortingWithFoldersView()
}
