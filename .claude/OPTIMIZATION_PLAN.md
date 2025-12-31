# SinglePageRowsAndFoldersView - Optimization Plan

**File:** `DO-AI-Controls/SinglePageRowsAndFoldersView.swift`
**Date Created:** 2025-12-30
**Status:** Ready for implementation

---

## 🔴 High Priority - Performance & Production Issues

### Performance Optimizations
- [ ] **Cache computed properties to prevent recalculation**
  - [ ] Convert `displayedItems` to `@State private var cachedDisplayedItems`
  - [ ] Convert `orderedFolders` to `@State private var cachedOrderedFolders`
  - [ ] Add `rebuildCache()` function to rebuild when state changes
  - [ ] Call `rebuildCache()` after `rootItems` or folder expansion changes
  - **Impact:** Eliminates O(n) recalculation on every view render
  - **Lines:** 124-143

- [ ] **Optimize `addNewFile()` number finding algorithm**
  - [ ] Replace O(n²) sequential search with Set-based O(n) lookup
  - [ ] Create helper function `getAllFileNumbers() -> Set<Int>`
  - [ ] Use Set.contains() for gap finding
  - **Impact:** Faster file creation, especially with many files
  - **Lines:** 212-247

### Production Code Quality
- [ ] **Remove/wrap debug logging**
  - [ ] Wrap all print statements in `#if DEBUG` blocks
  - [ ] Or create debug logging helper function
  - [ ] Alternative: Use os.log for structured logging
  - **Impact:** Reduces console noise in production
  - **Lines:** 267, 271, 273, 323, 330, 338, 344, 351-352, 362, 368, 385, 391, 411, 424-425, 428, 433, 455, 460, 505, 519, 525-538

---

## 🟡 Medium Priority - Code Quality & Robustness

### Code Organization
- [x] **Refactor large `moveItem()` function**
  - [x] Extract validation logic into `determineMoveOperation()`
  - [x] Extract folder moves into `performFolderMove()`
  - [x] Extract same-context moves into `performSameContextMove()`
  - [x] Extract cross-level moves into `performCrossLevelMove()`
  - [x] Create `MoveOperation` enum to represent move types
  - **Impact:** Better readability, easier testing, clearer logic flow
  - **Lines:** Reduced from 228 lines to 54 lines, with 184 lines distributed across 4 focused helper functions

- [x] **Simplify dual state management**
  - [x] Document why both are needed (performance: array for order, dictionary for O(1) lookup)
  - [x] Add sync validation with `validateStateSync()` (DEBUG only)
  - [x] Reduce risk of desynchronization bugs
  - **Impact:** Clear rationale documented, validation catches sync errors in development
  - **Lines:** 33-46 (documentation), 370-410 (validation function)

### Edge Case Handling
- [ ] **Handle empty folders explicitly**
  - [ ] Decide policy: delete empty folders or keep them?
  - [ ] Add `shouldDeleteEmptyFolders` configuration
  - [ ] Implement auto-deletion in `updateFolder()` if enabled
  - [ ] Or add visual indicator for empty folders
  - **Impact:** Better UX, clear behavior
  - **Lines:** 314, 337

- [ ] **Fix folder naming overflow**
  - [ ] Current implementation breaks after 'Z' (uses `[`, `\`, etc.)
  - [ ] Implement "Folder AA", "Folder AB" style naming
  - [ ] Or use numeric suffixes: "Folder 3", "Folder 4"
  - **Impact:** Handles unlimited folders gracefully
  - **Lines:** 189-210

### Accessibility
- [x] **Add VoiceOver support**
  - [x] Add `.accessibilityLabel()` to file rows and folder rows
  - [x] Add `.accessibilityHint()` to folder expand/collapse and drag operations
  - [x] Add `.accessibilityLabel()` to move-to-folder menu items
  - [x] Add `.accessibilityValue()` to folders with item count and expansion state
  - [x] Add accessibility to toolbar buttons (New Folder, Edit/Done)
  - [x] Add accessibility to FAB (New Journal button)
  - [ ] Test with VoiceOver enabled on device
  - **Impact:** Makes app usable for vision-impaired users
  - **Lines:** File rows (888-891), Folder rows (955-959), Menu items (873-874), Toolbar (132-133, 141-142), FAB (115-116)

---

## 🟢 Low Priority - Polish & Nice-to-Have

### Code Cleanup
- [ ] **Extract magic numbers to constants**
  - [ ] Create `Layout` enum with static properties
  - [ ] Extract: `nestedIndentation = 32`, `rowVerticalPadding = 2`
  - [ ] Extract: `fabTrailing = 20`, `fabBottom = 20`
  - [ ] Extract: `iconSize = 28`, `spacing = 12`
  - **Impact:** Easier to adjust layout, better maintainability
  - **Lines:** 658, 710, 79-80, 614, 611

- [ ] **Remove duplicate code**
  - [ ] Extract `gradientForFile()` to shared Color extension
  - [ ] Share with other views (RowCellView, etc.)
  - [ ] Create single source of truth for color palette
  - **Impact:** DRY principle, consistent colors across app
  - **Lines:** 661-678

- [ ] **Improve folder finding performance**
  - [ ] Cache folder index lookups in `findFolderIndex()`
  - [ ] Or use dictionary-based lookup instead of array search
  - **Impact:** Faster folder operations
  - **Lines:** 257-264

### User Experience Enhancements
- [ ] **Add undo/redo support**
  - [ ] Port undo stack from `EditModalView`
  - [ ] Add undo/redo buttons to toolbar
  - [ ] Save state snapshots before mutations
  - [ ] Implement `undo()` and `redo()` functions
  - **Impact:** Better UX consistency, mistake recovery
  - **Reference:** RowSortingWithDropTargetView.swift lines 225-226

- [ ] **Add haptic feedback**
  - [ ] Import `CoreHaptics` or use `UIImpactFeedbackGenerator`
  - [ ] Add feedback on folder expand/collapse
  - [ ] Add feedback on successful drag-drop
  - [ ] Add feedback on button taps in edit mode
  - **Impact:** More tactile, polished feel
  - **Lines:** Throughout interaction points

- [ ] **Add empty state handling**
  - [ ] Show placeholder when `rootItems.isEmpty` (not just on first load)
  - [ ] Add "Add your first journal" message
  - [ ] Add illustration or icon
  - **Impact:** Better first-run experience
  - **Lines:** 117-121

### Animation Improvements
- [ ] **Refine animations**
  - [ ] Add spring animations for drag completion
  - [ ] Add matched geometry effects for folder expansion
  - [ ] Fine-tune animation timing curves
  - **Impact:** More polished, native-feeling animations
  - **Lines:** 180, 190, 280, 294, 359

---

## 📋 Implementation Checklist

### Phase 1: Quick Wins (Est. 15-30 min)
- [ ] Wrap debug prints in `#if DEBUG`
- [ ] Extract magic numbers to constants
- [ ] Optimize `addNewFile()` with Set-based lookup
- [ ] Add empty folder handling decision

### Phase 2: Performance (Est. 30-45 min)
- [ ] Implement computed property caching
- [ ] Add cache invalidation logic
- [ ] Test performance with large datasets
- [ ] Profile and measure improvement

### Phase 3: Code Quality (Est. 1-2 hours)
- [ ] Refactor `moveItem()` into smaller functions
- [ ] Extract gradient helper to shared utility
- [ ] Fix folder naming overflow
- [ ] Document dual state rationale

### Phase 4: Polish (Optional, Est. 1-2 hours)
- [ ] Add accessibility labels
- [ ] Add haptic feedback
- [ ] Add undo/redo support
- [ ] Improve animations

---

## 📊 Impact Summary

| Priority | Items | Est. Time | Impact |
|----------|-------|-----------|--------|
| 🔴 High | 3 | 45 min | High performance gain, production-ready |
| 🟡 Medium | 6 | 2-3 hours | Better code quality, fewer bugs |
| 🟢 Low | 9 | 2-3 hours | Polish, UX improvements |
| **Total** | **18** | **5-7 hours** | **Significantly improved codebase** |

---

## 🎯 Success Metrics

After completing this plan, the code should:
- ✅ Run with no debug logging in production
- ✅ Handle 1000+ items without performance degradation
- ✅ Be accessible via VoiceOver
- ✅ Have clear, testable functions under 50 lines
- ✅ Support unlimited folders with proper naming
- ✅ Handle all edge cases gracefully

---

## 📝 Notes

- **Testing:** After each phase, test drag-drop in all scenarios (same folder, cross-level, to root, etc.)
- **Backup:** Consider committing between phases
- **Performance:** Profile with Instruments if working with large datasets
- **Accessibility:** Test with VoiceOver enabled on device

---

**Last Updated:** 2025-12-30
**Next Review:** After Phase 1 completion
