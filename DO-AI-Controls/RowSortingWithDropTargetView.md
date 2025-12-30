# Row Sorting with Drop Target Implementation

## Overview

This experiment implements an advanced drag-and-drop interface for hierarchical list management in SwiftUI, allowing users to reorganize files and folders with visual drop zones that indicate where items can be placed within folders.

## Problem Statement

Creating an intuitive drag-and-drop interface for hierarchical data in SwiftUI presents several challenges:

1. **Visual Affordance**: Users need clear visual indicators showing where items can be dropped within folders
2. **Drop Zone Constraints**: Drop zones should be visible and functional but not draggable themselves
3. **Cross-Barrier Dragging**: Items positioned after drop zones must be able to move to positions before drop zones
4. **Index Calculation Complexity**: Maintaining correct indices when mixing expanded/collapsed folders, folder contents, and drop zones
5. **State Synchronization**: Keeping multiple data sources (rootItems, folders dictionary, editableItems) in sync

## Solution Architecture

### Data Model Structure

```swift
// Individual file items
struct FileNode: Identifiable, Equatable {
    let id: UUID
    let name: String
}

// Folder containers with expandable contents
struct FolderNode: Identifiable, Equatable {
    let id: UUID
    var name: String
    var contents: [FileNode]
    var isExpanded: Bool = false
}

// Display node union type for rendering
enum DisplayNode: Identifiable, Equatable {
    case file(FileNode)
    case folder(FolderNode)
    case dropZone(UUID)  // Associated with folder ID
}
```

### Dual State Management

The implementation maintains two separate but synchronized data structures:

1. **`rootItems: [DisplayNode]`** - Source of truth for root-level ordering
2. **`folders: [UUID: FolderNode]`** - Dictionary maintaining current folder state and contents
3. **`editableItems: [DisplayNode]`** - Computed display array including expanded contents and drop zones

This dual approach allows:
- Root-level ordering to be independent of folder contents
- Folder contents to be updated without affecting root structure
- Drop zones to be dynamically inserted based on folder positions

### Key Implementation Components

#### 1. Dynamic List Building

```swift
func buildEditableList() {
    var result: [DisplayNode] = []

    for item in rootItems {
        result.append(item)

        if case .folder(let folderInRoot) = item {
            // Always use folders dictionary as source of truth
            guard let folder = folders[folderInRoot.id] else { continue }

            // Add contents if expanded
            if folder.isExpanded {
                result.append(contentsOf: folder.contents.map { .file($0) })
            }

            // Always add drop zone after folder
            result.append(.dropZone(folder.id))
        }
    }

    editableItems = result
}
```

**Benefits:**
- Drop zones automatically positioned after each folder
- Folder state always pulled from authoritative dictionary
- Supports both expanded and collapsed folder states

#### 2. Intelligent Index Calculation

The `findFolderAtDestination()` function maps display indices to folder positions:

```swift
func findFolderAtDestination(_ destinationIndex: Int) -> (UUID, Int)? {
    var currentDisplayIndex = 0

    for rootItem in rootItems {
        if case .folder(let folderInRoot) = rootItem {
            guard let folder = folders[folderInRoot.id] else {
                currentDisplayIndex += 1
                continue
            }

            if folder.isExpanded {
                currentDisplayIndex += 1  // Skip folder row

                let folderStartIndex = currentDisplayIndex
                let folderInsertEndIndex = currentDisplayIndex + folder.contents.count

                // Allow insertion anywhere within folder, including after last item
                if destinationIndex >= folderStartIndex && destinationIndex <= folderInsertEndIndex {
                    let positionInFolder = destinationIndex - folderStartIndex
                    return (folder.id, positionInFolder)
                }

                currentDisplayIndex += folder.contents.count
                currentDisplayIndex += 1  // Skip drop zone
            } else {
                currentDisplayIndex += 1  // Folder row
                currentDisplayIndex += 1  // Drop zone
            }
        } else {
            currentDisplayIndex += 1
        }
    }

    return nil
}
```

**Key Insights:**
- Uses `folders` dictionary to get current folder state (not stale data from rootItems)
- Accounts for expanded vs collapsed folders
- Includes position after last item in folder (`folderInsertEndIndex`)
- Calculates exact position within folder for precise insertions

#### 3. Prioritized Destination Logic

The move handler checks destinations in priority order:

```swift
func moveItem(from source: IndexSet, to destination: Int) {
    // Priority 1: Check if destination is within expanded folder
    if let (folderId, position) = findFolderAtDestination(destination) {
        moveFileIntoFolder(file: file, folderId: folderId, position: position)
    }
    // Priority 2: Check if destination is explicitly the drop zone
    else if case .dropZone(let folderId) = editableItems[destination] {
        // Prevent moving back into same folder
        if let (sourceFolder, _) = findParentFolder(at: sourceIndex),
           sourceFolder.id == folderId {
            moveFileToRoot(file: file, sourceIndex: sourceIndex, destinationIndex: destination)
        } else {
            moveFileIntoFolder(file: file, folderId: folderId, position: nil)
        }
    }
    // Priority 3: Move to root level
    else {
        moveFileToRoot(file: file, sourceIndex: sourceIndex, destinationIndex: destination)
    }
}
```

**Why This Order Matters:**
- Checking folder ranges first allows insertions within folders to work correctly
- Drop zone check only triggers when explicitly landing on the drop zone
- Prevents items from moving back into their source folder when dragged to its drop zone
- Root level is the fallback for all other positions

## Critical Bug Fixes

### Issue 1: Items Jumping Back When Dragged Out of Folders

**Problem:** Items dragged from within a folder to just below the folder's drop zone would immediately jump back into the folder.

**Root Cause:** When destination landed on the drop zone index, the code moved the item back into the folder, even when dragging from that same folder.

**Solution:** Check if source and destination folders are the same:

```swift
if let (sourceFolder, _) = sourceParentFolder, sourceFolder.id == folderId {
    moveFileToRoot(file: file, sourceIndex: sourceIndex, destinationIndex: destination)
}
```

### Issue 2: Cannot Insert After Last Item in Folder

**Problem:** Items could not be dragged to the end of a folder (after the last item).

**Root Cause:** Range check only included existing item positions, not the insertion point after the last item.

**Solution:** Changed `folderEndIndex` to `folderInsertEndIndex`:

```swift
// Before: let folderEndIndex = currentDisplayIndex + folder.contents.count - 1
// After:
let folderInsertEndIndex = currentDisplayIndex + folder.contents.count
```

### Issue 3: Items Below Folders Cannot Be Dragged Into Folders

**Problem:** Row 1 and Row 2 (before folders) could be dragged into folders, but Row 3, 4, 5 (after folders) could not.

**Root Cause:** Using `.moveDisabled(true)` on drop zones created an invisible barrier preventing items from crossing that position.

**Solution:** Removed `.moveDisabled(true)` and relied on early return logic in `moveItem()` to prevent drop zones from actually moving.

### Issue 4: Stale Folder Data

**Problem:** After moving items, folder contents count was incorrect, causing index calculations to fail.

**Root Cause:** Functions were reading folder data from `rootItems` instead of the authoritative `folders` dictionary.

**Solution:** All functions now look up folders from the dictionary:

```swift
// Before: if case .folder(let folder) = rootItem, folder.isExpanded {
// After:
if case .folder(let folderInRoot) = rootItem {
    guard let folder = folders[folderInRoot.id] else { continue }
    if folder.isExpanded {
        // Use folder from dictionary
    }
}
```

### Issue 5: Drop Zones Not Snapping Back

**Problem:** When drop zones were dragged, they would stay in the wrong position instead of snapping back.

**Root Cause:** SwiftUI's `.onMove` is called after the move is applied. Simply rebuilding the list didn't force a UI update.

**Solution:** Clear `editableItems` before rebuilding to force state change detection:

```swift
if case .dropZone = movedItem {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            self.editableItems = []  // Force state update
            self.buildEditableList()
        }
    }
    return
}
```

The 0.1 second delay allows SwiftUI to complete the move operation before we rebuild the list.

## Benefits of This Approach

### 1. **Clear Visual Affordance**
- Drop zones provide obvious targets for adding items to folders
- Dashed borders and descriptive text communicate functionality
- Visible even when folders are collapsed

### 2. **Flexible Drag Operations**
- Items can be dragged to any position: before folder, within folder (any position), or after folder
- No invisible barriers preventing valid moves
- Items can freely move between root level and folders

### 3. **Accurate Position Tracking**
- Dual state management keeps root ordering and folder contents separate
- Dictionary lookup ensures current folder state is always used
- Index calculations handle expanded/collapsed states correctly

### 4. **Robust State Synchronization**
- All state changes update both `rootItems` and `folders` dictionary
- `buildEditableList()` always rebuilds from authoritative sources
- Forced state updates ensure UI reflects current data

### 5. **Natural User Experience**
- Drop zones snap back when dragged (not meant to be movable)
- Smooth spring animations provide tactile feedback
- Reordering feels natural and predictable

## Technical Learnings

### SwiftUI List Drag-and-Drop Constraints

1. **`.moveDisabled(true)` Creates Barriers**: Items with this modifier cannot be crossed during drag operations, making them unsuitable for drop zones that need to allow items to pass through.

2. **`.onMove` Timing**: The callback is invoked after the move is visually applied, not before or during. This means you cannot "cancel" a move, only reverse it afterward.

3. **State Update Detection**: SwiftUI doesn't always detect when an array is rebuilt with the same contents. Clearing the array first forces change detection.

4. **Async UI Updates**: Using `DispatchQueue.main.asyncAfter` with a small delay (0.1s) allows SwiftUI to complete its internal move operations before we modify state.

### Index Calculation Best Practices

1. **Use Authoritative Sources**: Always query the `folders` dictionary rather than stale data in `rootItems`

2. **Account for All Display States**: Calculations must handle:
   - Expanded folders (folder + contents + drop zone)
   - Collapsed folders (folder + drop zone)
   - Root-level files (just the file)

3. **Include Insertion Points**: Range checks should allow insertion after the last item, not just at existing positions

4. **Priority Ordering Matters**: Check folder ranges before drop zones to prevent ambiguity

### State Management Patterns

1. **Dual State Architecture**: Separating root ordering (`rootItems`) from folder contents (`folders` dictionary) allows independent updates

2. **Computed Display Array**: `editableItems` is never modified directly—it's always rebuilt from source data

3. **Dictionary as Source of Truth**: The `folders` dictionary maintains current state, while `rootItems` maintains ordering

## Future Enhancements

### Potential Improvements

1. **Multi-Select Drag**: Support dragging multiple items simultaneously
2. **Folder Nesting**: Allow folders to contain other folders
3. **Drag Preview Customization**: Custom drag previews showing item count or folder hierarchy
4. **Persistence**: Save/restore state across app launches
5. **Undo/Redo**: Track move history for undo operations
6. **Accessibility**: VoiceOver support for drag operations
7. **Haptic Feedback**: Provide tactile feedback when items snap into place
8. **Visual Drop Zone Highlighting**: Highlight drop zones when dragging compatible items
9. **Drag-to-Expand**: Automatically expand folders when hovering during drag
10. **Keyboard Navigation**: Support keyboard-based reordering

### Performance Optimizations

1. **Lazy Loading**: For large lists, only build visible portions of `editableItems`
2. **Diffable Data Source**: Use SwiftUI's diffing to minimize UI updates
3. **Debounced Rebuilds**: Batch multiple state changes before rebuilding list
4. **Virtualization**: For very large datasets, virtualize the list rendering

## Code Organization

### File Structure
- **Data Models**: `FileNode`, `FolderNode`, `DisplayNode` (lines 12-42)
- **Main View**: `RowSortingWithDropTargetView` (lines 46-176)
- **Edit Modal**: `EditModalView` (lines 180-528)
- **Component Views**: `FileRowView`, `FolderRowView`, `DropZoneRowView` (lines 530-616)

### Key Functions
- `buildEditableList()`: Constructs display array from source data
- `moveItem()`: Handles drag-and-drop operations
- `findFolderAtDestination()`: Maps display index to folder position
- `findParentFolder()`: Determines if an item is within a folder
- `moveFileIntoFolder()`: Transfers item into folder at position
- `moveFileToRoot()`: Transfers item to root level
- `removeFileFromSource()`: Removes item from current location

## Conclusion

This implementation demonstrates a sophisticated approach to hierarchical drag-and-drop in SwiftUI, solving numerous edge cases while maintaining clean, maintainable code. The dual state management pattern and careful index calculations enable complex interactions that feel natural to users.

Key takeaways:
- **State synchronization** is critical when managing multiple data structures
- **Index calculations** must account for all possible display states
- **SwiftUI's drag-and-drop limitations** require creative workarounds
- **Visual affordances** like drop zones significantly improve UX
- **Forced state updates** are sometimes necessary to trigger UI refreshes

The result is a robust, production-ready drag-and-drop interface that handles file and folder management with precision and polish.
