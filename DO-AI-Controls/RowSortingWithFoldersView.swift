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
    @State private var items: [ListItemType] = []
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
            if items.isEmpty {
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

        // Build initial flat list: A, B, [Folder One], E, [Folder Two], H-T
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

        items = initialItems
    }

    func toggleFolder(id: UUID) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            // Find folder in items array
            if let index = items.firstIndex(where: {
                if case .folder(let f) = $0, f.id == id {
                    return true
                }
                return false
            }) {
                if case .folder(var folder) = items[index] {
                    folder.isExpanded.toggle()
                    folders[folder.id] = folder
                    items[index] = .folder(folder)
                    rebuildFlatList()
                }
            }
        }
    }

    func moveItem(from source: IndexSet, to destination: Int) {
        guard let sourceIndex = source.first else { return }

        // Don't allow moving if indices are invalid
        guard sourceIndex < items.count else { return }

        let movedItem = items[sourceIndex]

        // Remove item from source location first
        items.remove(at: sourceIndex)

        // Adjust destination if needed (removal shifts indices)
        let adjustedDestination = sourceIndex < destination ? destination - 1 : destination

        // Determine if we're dropping on a collapsed folder
        if adjustedDestination < items.count,
           case .folder(var targetFolder) = items[adjustedDestination],
           !targetFolder.isExpanded {
            // Drop ON folder: add to folder's contents
            if case .row(let row) = movedItem {
                targetFolder.contents.append(row)
                folders[targetFolder.id] = targetFolder
                items[adjustedDestination] = .folder(targetFolder)
            } else {
                // Can't put folder inside folder, just insert after
                items.insert(movedItem, at: adjustedDestination)
            }
        } else {
            // Standard reorder in list
            items.insert(movedItem, at: adjustedDestination)
        }

        // Clean up: remove rows from folders if they were dragged out
        cleanupFolders()
    }

    func cleanupFolders() {
        // Get all row IDs currently in the flat list
        let rowIdsInList = items.compactMap { item -> UUID? in
            if case .row(let row) = item {
                return row.id
            }
            return nil
        }

        // Remove those rows from folders
        for (folderId, var folder) in folders {
            let originalCount = folder.contents.count
            folder.contents.removeAll { row in
                rowIdsInList.contains(row.id)
            }

            if folder.contents.count != originalCount {
                folders[folderId] = folder
                // Update folder in items array
                if let index = items.firstIndex(where: {
                    if case .folder(let f) = $0, f.id == folderId {
                        return true
                    }
                    return false
                }) {
                    items[index] = .folder(folder)
                }
            }
        }
    }

    func rebuildFlatList() {
        // Rebuild the flat list based on expanded state
        var newItems: [ListItemType] = []

        for item in items {
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
        for i in stride(from: index - 1, through: 0, by: -1) {
            if case .folder(let folder) = items[i] {
                if folder.isExpanded {
                    return true
                } else {
                    return false
                }
            }
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
