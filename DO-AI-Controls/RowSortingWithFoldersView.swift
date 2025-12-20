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

    var id: UUID {
        switch self {
        case .row(let item): return item.id
        case .folder(let item): return item.id
        }
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

        // Step 1: Remove item from its current location (rootItems or a folder)
        removeItemFromSource(movedItem)

        // Step 2: Determine destination and add item there
        // Adjust destination index after removal
        let adjustedDestination = sourceIndex < destination ? destination - 1 : destination

        // Determine where we're dropping
        // First check if destination is inside an expanded folder
        if let (parentFolder, positionInFolder) = findParentFolder(at: adjustedDestination) {
            // Dropping inside an expanded folder
            if case .row(let row) = movedItem {
                var updatedFolder = parentFolder
                updatedFolder.contents.insert(row, at: min(positionInFolder, updatedFolder.contents.count))
                folders[updatedFolder.id] = updatedFolder
                // Update folder in rootItems
                if let rootIndex = rootItems.firstIndex(where: {
                    if case .folder(let f) = $0, f.id == updatedFolder.id { return true }
                    return false
                }) {
                    rootItems[rootIndex] = .folder(updatedFolder)
                }
            } else if case .folder = movedItem {
                // Can't put folder inside folder - add it to rootItems after the parent folder
                if let rootIndex = rootItems.firstIndex(where: {
                    if case .folder(let f) = $0, f.id == parentFolder.id { return true }
                    return false
                }) {
                    rootItems.insert(movedItem, at: rootIndex + 1)
                }
            }
        } else if adjustedDestination < items.count,
                  case .folder(var targetFolder) = items[adjustedDestination],
                  !targetFolder.isExpanded {
            // Drop ON a collapsed folder: add to folder's contents
            if case .row(let row) = movedItem {
                targetFolder.contents.append(row)
                folders[targetFolder.id] = targetFolder
                // Update folder in rootItems
                if let rootIndex = rootItems.firstIndex(where: {
                    if case .folder(let f) = $0, f.id == targetFolder.id { return true }
                    return false
                }) {
                    rootItems[rootIndex] = .folder(targetFolder)
                }
            } else if case .folder = movedItem {
                // Can't put folder inside folder - add it to rootItems after the target folder
                if let rootIndex = rootItems.firstIndex(where: {
                    if case .folder(let f) = $0, f.id == targetFolder.id { return true }
                    return false
                }) {
                    rootItems.insert(movedItem, at: rootIndex + 1)
                }
            }
        } else {
            // Dropping in the list (not on/in a folder) - add to rootItems
            let rootDestIndex = mapDisplayIndexToRootIndex(adjustedDestination)
            rootItems.insert(movedItem, at: min(rootDestIndex, rootItems.count))
        }

        rebuildFlatList()
    }

    func findParentFolder(at displayIndex: Int) -> (FolderItem, Int)? {
        // Check if displayIndex is inside an expanded folder
        // Returns (folder, position within folder) if inside a folder, nil otherwise
        var currentIndex = 0

        for rootItem in rootItems {
            if case .folder(let folder) = rootItem, folder.isExpanded {
                // This folder starts at currentIndex, its contents follow
                let folderStartIndex = currentIndex
                currentIndex += 1 // Skip the folder row itself

                // Check if displayIndex falls within this folder's contents
                let folderEndIndex = currentIndex + folder.contents.count - 1
                if displayIndex >= currentIndex && displayIndex <= folderEndIndex + 1 {
                    // displayIndex is inside this folder
                    let positionInFolder = displayIndex - currentIndex
                    return (folder, positionInFolder)
                }

                currentIndex += folder.contents.count
            } else {
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

            // If it's an expanded folder, skip its contents in the display
            if case .folder(let folder) = rootItem, folder.isExpanded {
                currentDisplayIndex += folder.contents.count
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

            if case .folder(let folder) = item, folder.isExpanded {
                // Add folder contents
                newItems.append(contentsOf: folder.contents.map { .row($0) })
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

            // Drag handle
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.secondary)
                .font(.system(size: 16))
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

            // Drag handle
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.secondary)
                .font(.system(size: 16))
                .padding(.leading, 8)
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Preview

#Preview {
    RowSortingWithFoldersView()
}
