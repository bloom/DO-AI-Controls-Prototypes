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
            List {
                ForEach(displayedItems) { item in
                    switch item {
                    case .file(let file, let isNested):
                        SinglePageFileRowView(
                            file: file,
                            isNested: isNested,
                            isEditMode: isEditMode,
                            folders: folders,
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(isEditMode ? "Done" : "Edit") {
                        withAnimation {
                            isEditMode.toggle()
                        }
                    }
                    .foregroundColor(accentColor)
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
        // Try root first
        if let index = rootItems.firstIndex(where: {
            if case .file(let f, _) = $0, f.id == file.id { return true }
            return false
        }) {
            rootItems.remove(at: index)
            return
        }

        // Try folders
        for (_, var folder) in folders {
            if let index = folder.contents.firstIndex(where: { $0.id == file.id }) {
                folder.contents.remove(at: index)
                updateFolder(folder)
                return
            }
        }
    }

    func moveItem(from source: IndexSet, to destination: Int) {
        guard let sourceIndex = source.first else { return }
        let movedItem = displayedItems[sourceIndex]

        // Don't allow moving drop zones
        if case .dropZone = movedItem {
            return
        }

        // Determine context of source and destination
        let sourceContext = getItemContext(at: sourceIndex)
        let destinationContext = getItemContext(at: destination)

        // Only allow moves within the same context (both at root or both in same folder)
        guard sourceContext == destinationContext else { return }

        if sourceContext == .root {
            // Moving at root level
            rootItems.move(fromOffsets: source, toOffset: destination)
        } else if case .inFolder(let folderId) = sourceContext,
                  var folder = folders[folderId] {
            // Moving within a folder
            // Calculate the actual indices within the folder's contents array
            let folderStartIndex = displayedItems.firstIndex { item in
                if case .folder(let f) = item, f.id == folderId { return true }
                return false
            }

            if let folderStart = folderStartIndex {
                let sourceInFolder = sourceIndex - folderStart - 1
                let destInFolder = destination - folderStart - 1

                folder.contents.move(
                    fromOffsets: IndexSet(integer: sourceInFolder),
                    toOffset: destInFolder
                )
                updateFolder(folder)
            }
        }
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
                    return .inFolder(folder.id)
                } else {
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
    let folders: [UUID: FolderNode]
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
                        ForEach(Array(folders.values.sorted(by: { $0.name < $1.name })), id: \.id) { folder in
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
