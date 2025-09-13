# Phase 1: Personal Code Foundation - Technical Implementation Plan

## Overview
This document provides step-by-step instructions for implementing Phase 1 of the Personal Code system. Each step is designed to be small, testable, and non-breaking to existing functionality.

## Implementation Steps (5 Small Steps)

### Step 1: Create PersonalCode Data Model
**Goal**: Add the data structure without affecting existing functionality

**Files to Create/Modify:**
- Create: `/Models/PersonalCode.swift`
- Create: `/Models/PersonalCodePrinciple.swift`
- Modify: `HorizonFrame2App.swift` (add to ModelContainer)

**PersonalCode Model Structure:**
```swift
@Model
final class PersonalCode {
    var createdAt: Date
    var lastModified: Date
    @Relationship(deleteRule: .cascade) var principles: [PersonalCodePrinciple]
    
    init() {
        self.createdAt = Date()
        self.lastModified = Date()
        self.principles = []
    }
}
```

**PersonalCodePrinciple Model Structure:**
```swift
@Model
final class PersonalCodePrinciple {
    var text: String
    var order: Int
    var createdAt: Date
    var isActive: Bool
    @Relationship var personalCode: PersonalCode?
    
    init(text: String, order: Int, personalCode: PersonalCode? = nil) {
        self.text = text
        self.order = order
        self.createdAt = Date()
        self.isActive = true
        self.personalCode = personalCode
    }
}
```

**Success Criteria:**
- App builds and runs without errors
- Existing functionality unchanged
- New models available in SwiftData container

**Testing:**
- Build and run app
- Complete existing daily alignment flow
- Add/edit goals in current Goals tab

---

### Step 2: Rename Goals Tab to "Personal Code"
**Goal**: Update navigation and tab naming

**Files to Modify:**
- `Views/MainTabView.swift` (update tab title and icon)
- `Views/GoalsView.swift` (update navigation title)

**Changes:**
- Tab title: "Goals" → "Personal Code" 
- Tab icon: Keep current or change to "doc.text" for code document feel
- Navigation title: "Your Goals" → "Your Personal Code"

**Success Criteria:**
- Tab shows "Personal Code" instead of "Goals"
- All existing functionality works identically
- Navigation title updated

**Testing:**
- Verify tab name changed
- Test all existing Goals functionality
- Ensure no broken navigation

---

### Step 3: Add Personal Code Section to Goals View
**Goal**: Add principles section above existing goals list

**Files to Modify:**
- `Views/GoalsView.swift` (add principles section)

**UI Changes:**
- Add PersonalCode query: `@Query private var personalCodes: [PersonalCode]`
- Add section above existing goals list:
  ```
  Personal Code Principles
  [List of principles]
  [Add Principle button]
  
  Long-Term Goals  
  [Existing goals list - unchanged]
  ```

**New UI Components Needed:**
- Principle card view (similar to goal card styling)
- Add principle button
- Empty state for no principles

**Success Criteria:**
- Personal Code section appears above goals
- Can display principles (even if empty initially)
- Existing goals section unchanged and functional
- Maintains current visual design consistency

**Testing:**
- Verify new section appears
- Existing goals functionality unaffected
- UI layout looks clean and consistent

---

### Step 4: Implement Add/Edit Principles Functionality
**Goal**: Allow users to create and modify Personal Code principles

**Files to Create:**
- `Views/AddPrincipleView.swift`
- `Views/EditPrincipleView.swift`

**Files to Modify:**
- `Views/GoalsView.swift` (add sheet presentations and principle management)

**Functionality:**
- Add principle: Simple text input with save/cancel
- Edit principle: Tap to edit existing principle text
- Delete principle: Swipe action or edit mode
- Reorder principles: Drag to reorder by importance

**UI Design:**
- Match existing AddGoalView/EditGoalView styling
- Simple text field with character limit (e.g., 100 chars)
- Same button styling as existing goal management

**Success Criteria:**
- Can add new principles
- Can edit existing principles
- Can delete principles
- Can reorder principles
- All changes persist with SwiftData

**Testing:**
- Add several principles
- Edit principle text
- Delete principles
- Reorder principles
- Restart app and verify persistence

---

### Step 5: Add Basic Personal Code Management
**Goal**: Complete basic Personal Code CRUD operations

**Files to Modify:**
- `Views/GoalsView.swift` (complete integration)

**Features to Add:**
- Auto-create PersonalCode instance for new users
- Principle validation (no empty principles)
- Principle ordering and management
- Integration with existing SwiftData context

**Helper Functions:**
```swift
private func getOrCreatePersonalCode() -> PersonalCode
private func addPrinciple(text: String)
private func deletePrinciple(_ principle: PersonalCodePrinciple)
private func movePrinciples(from: IndexSet, to: Int)
```

**Success Criteria:**
- Personal Code automatically created for users
- All CRUD operations work smoothly
- Data persistence reliable
- No impact on existing goals functionality

**Testing:**
- Fresh app install creates PersonalCode
- All principle operations work
- Data survives app restart
- Existing users see new section without issues

---

## LLM Programming Instructions

### Development Rules:
1. **One Step at a Time**: Complete each step fully before moving to next
2. **Test After Each Step**: Verify app builds and runs after each change
3. **Preserve Existing Functionality**: Never break current features
4. **Follow Existing Patterns**: Use same coding style and UI patterns as current codebase
5. **Data Safety**: Always use proper SwiftData relationships and error handling

### Error Handling:
- If any step fails, stop and report the specific error
- Never proceed to next step if current step has issues
- Always test data persistence after model changes

### Code Style:
- Follow existing SwiftUI patterns in codebase
- Use same color scheme and styling as current Goals tab
- Maintain existing navigation patterns
- Use existing button and card styling

### Testing Checklist for Each Step:
- [ ] App builds without errors
- [ ] App runs without crashes
- [ ] Existing functionality unchanged
- [ ] New functionality works as specified
- [ ] Data persists correctly
- [ ] UI matches existing design patterns

## Phase 1 Completion Criteria

When Phase 1 is complete, users should be able to:
- See "Personal Code" tab instead of "Goals"
- View Personal Code principles section above their goals
- Add, edit, delete, and reorder principles
- See their existing goals unchanged in the lower section
- Have all data persist between app sessions

The app should feel like a natural evolution of the existing Goals tab, with Personal Code principles as a new addition that enhances rather than replaces the current functionality.

## Next Phase Preview
Phase 2 will enhance the daily alignment flow to include Personal Code commitment, but Phase 1 focuses purely on the foundation and basic management of Personal Code principles.
