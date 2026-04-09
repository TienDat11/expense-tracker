# STRICT DESIGN & CODE STANDARDS - Phase 3

## Purpose

This document is a **non-negotiable contract** for Phase 3 implementation. Every line of code, every widget, every interaction MUST comply with these standards. A junior developer following this document cannot accidentally destroy the UX.

**Enforcement:** Any violation of these standards requires refactoring before the task is considered complete.

---

## 1. Color System

### Brand Colors (LOCKED)

| Color | Hex | Usage | CSS Variable Equivalent |
|-------|-----|-------|------------------------|
| Primary | `#6C63FF` | CTAs, active states, emphasis | `--primary` |
| Primary Variant | `#8B85FF` | Gradient end, hover states | `--primary-variant` |
| Accent | `#6584FF` | Secondary CTAs | `--accent` |

### Semantic Colors (LOCKED)

| Color | Hex | Usage |
|-------|-----|-------|
| Success (Income) | `#00D9A3` | Income amounts, success states |
| Error (Expense) | `#FF4D4F` | Expense amounts, errors, destructive actions |
| Warning | `#FFA940` | Warnings, alerts |
| Info | `#4DA3FF` | Informational content |

### Light Theme Colors

| Color | Hex | Usage |
|-------|-----|-------|
| Background | `#F8F9FB` | Screen backgrounds |
| Surface | `#FFFFFF` | Cards, sheets, dialogs |
| Text Primary | `#1A1A1A` | Headlines, body text |
| Text Secondary | `#757575` | Captions, hints |
| Outline | `#E0E0E0` | Borders, dividers |
| Input Fill | `#F5F5F5` | Text field backgrounds |

### Dark Theme Colors

| Color | Hex | Usage |
|-------|-----|-------|
| Background | `#121212` | Screen backgrounds |
| Surface | `#1E1E1E` | Cards, sheets, dialogs |
| Card Elevated | `#252525` | Elevated cards |
| Text Primary | `#FFFFFF` | Headlines, body text |
| Text Secondary | `#B0B0B0` | Captions, hints |
| Outline | `#333333` | Borders, dividers |
| Input Fill | `#2A2A2A` | Text field backgrounds |

### Color Rules

**REQUIRED:**
- Access colors via `Theme.of(context).colorScheme` or `AppColors` constants
- Use semantic colors for semantic meaning (success for positive, error for negative)
- Minimum contrast ratio: 4.5:1 for text, 3:1 for large text/icons

**FORBIDDEN:**
- Hardcoded hex values in widgets: `Color(0xFF...)`
- Using `Colors.grey` directly (use theme colors)
- Primary color for negative/error states
- Semantic colors for non-semantic purposes

---

## 2. Typography

### Font Family (LOCKED)
- **Poppins** for all text (already configured via google_fonts)

### Type Scale

| Style | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| Headline Large | 32 | 700 | 1.2 | Screen titles (rare) |
| Headline Medium | 28 | 600 | 1.2 | Section headers |
| Headline Small | 24 | 600 | 1.3 | Card titles |
| Title Large | 22 | 500 | 1.3 | Modal titles |
| Title Medium | 18 | 500 | 1.4 | List group headers |
| Title Small | 16 | 500 | 1.4 | Card subtitles |
| Body Large | 16 | 400 | 1.5 | Primary body text |
| Body Medium | 14 | 400 | 1.5 | Secondary body text |
| Body Small | 12 | 400 | 1.4 | Captions, hints |
| Label Large | 14 | 500 | 1.0 | Button text |
| Label Medium | 12 | 500 | 1.0 | Chips, tabs |
| Label Small | 11 | 500 | 1.0 | Badges |

### Typography Rules

**REQUIRED:**
- Access text styles via `Theme.of(context).textTheme`
- Use semantic style names (bodyLarge, not fontSize: 16)
- Vietnamese text uses same font (Poppins supports Latin extended)

**FORBIDDEN:**
- Inline TextStyle definitions: `TextStyle(fontSize: 16)`
- Font sizes not in the type scale
- Font weights not in the scale (only 400, 500, 600, 700)
- Letter spacing modifications (use defaults)

---

## 3. Spacing & Layout

### Spacing Scale (8dp grid)

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4dp | Icon-to-text gaps, tight lists |
| sm | 8dp | Related element spacing |
| md | 12dp | Component internal padding |
| lg | 16dp | Section spacing, card padding |
| xl | 24dp | Screen edge padding, section breaks |
| 2xl | 32dp | Major section separation |
| 3xl | 48dp | Hero spacing (rare) |

### Layout Constants

| Constant | Value | Usage |
|----------|-------|-------|
| Screen horizontal padding | 16dp | `EdgeInsets.symmetric(horizontal: 16)` |
| Card padding | 16dp | Internal card padding |
| List item height | 72dp minimum | Single-line list items |
| Bottom sheet handle height | 4dp | Drag handle |
| Bottom navigation height | 60dp | Navigation bar |
| FAB bottom margin | 16dp | Above bottom nav |
| AppBar height | 56dp (default) | Standard app bar |

### Layout Rules

**REQUIRED:**
- All spacing values from spacing scale
- Horizontal screen padding: 16dp (consistent across all screens)
- Vertical rhythm based on 8dp grid
- Content area accounts for safe areas (SafeArea widget)

**FORBIDDEN:**
- Random spacing values: `SizedBox(height: 13)`
- Padding less than 4dp between elements
- Inconsistent horizontal padding between screens
- Ignoring safe areas (notches, navigation bars)

---

## 4. Border Radius

### Radius Scale

| Token | Value | Usage |
|-------|-------|-------|
| none | 0dp | Square elements |
| sm | 8dp | Small chips, badges |
| md | 12dp | **Cards, buttons, inputs** (PRIMARY) |
| lg | 16dp | Modals, bottom sheets |
| xl | 24dp | Pills, rounded containers |
| full | 9999dp | Circular elements |

### Border Radius Rules

**REQUIRED:**
- Cards: 12dp
- Buttons: 12dp
- Text inputs: 12dp
- Bottom sheets: 16dp top corners
- Dialogs: 16dp
- Chips: 8dp

**FORBIDDEN:**
- Mismatched radii on related elements
- BorderRadius.circular(10) or other non-scale values
- Square corners on interactive cards

---

## 5. Elevation & Shadows

### Elevation Scale

| Level | Elevation | Usage |
|-------|-----------|-------|
| 0 | 0dp | Flat surfaces, list items |
| 1 | 1dp | Subtle cards |
| 2 | 2dp | **Standard cards** (PRIMARY) |
| 3 | 4dp | Elevated cards, FAB resting |
| 4 | 8dp | Modals, sheets |
| 5 | 12dp | FAB pressed |

### Shadow Rules

**REQUIRED:**
- Use Material elevation system
- Standard cards: elevation 2
- Modal surfaces: elevation 8
- FAB: elevation 4 resting, 8 pressed

**FORBIDDEN:**
- Custom BoxShadow (use Material elevation)
- Elevation > 12 (over-designed)
- Colored shadows (always use grey/black)
- Elevation without surface color change

---

## 6. Icons

### Icon System

| Property | Value |
|----------|-------|
| Default size | 24dp |
| Touch target minimum | 48x48dp |
| Icon color | Theme-aware (primary, onSurface, etc.) |
| Icon set | Material Icons (built-in) |

### Icon Rules

**REQUIRED:**
- All icons from Material Icons set
- Icon buttons: minimum 48x48dp touch target
- Semantic icons (check for success, close for dismiss)
- Icon color from theme, not hardcoded

**FORBIDDEN:**
- Mixing icon sets (no FontAwesome + Material)
- Touch targets below 48dp
- Decorative icons without semantic meaning
- Icon-only buttons without tooltip/label

---

## 7. Buttons

### Button Variants

| Variant | Usage | Style |
|---------|-------|-------|
| Primary (Filled) | Main CTA, submit | Purple fill, white text |
| Secondary | Alternative action | Light purple fill |
| Tertiary (Text) | Subtle action, cancel | Text only |
| Destructive | Delete, remove | Red fill or red text |

### Button Sizing

| Size | Height | Horizontal Padding | Font Size |
|------|--------|-------------------|-----------|
| Large | 52dp | 24dp | 16 medium |
| Medium (default) | 48dp | 16dp | 14 medium |
| Small | 36dp | 12dp | 12 medium |

### Button Rules

**REQUIRED:**
- Full-width buttons for primary actions in forms
- Minimum touch target: 48dp height
- Loading state: show spinner, disable interaction
- Button text: Sentence case ("Thêm giao dịch", not "THÊM GIAO DỊCH")

**FORBIDDEN:**
- Primary + Primary buttons side by side (one must be secondary)
- Buttons without loading state for async actions
- Destructive actions without confirmation
- Custom button implementations (use CustomButton widget)

---

## 8. Forms & Inputs

### Text Field Anatomy

| Component | Specification |
|-----------|---------------|
| Height | 56dp minimum |
| Border radius | 12dp |
| Background | Input fill color from theme |
| Label | Above field, not floating |
| Hint | Inside field, grey text |
| Border | 1dp outline on focus |

### Form Rules

**REQUIRED:**
- Labels ABOVE fields (not floating, not placeholder-only)
- Error messages below field in red
- Keyboard type matches input (email, number, etc.)
- TextInputAction for keyboard button (next, done)
- Loading overlay during form submission
- Success toast after successful submission

**FORBIDDEN:**
- Placeholder as only label
- Form submission without validation
- Multiple forms on same screen
- Auto-submitting on last field

---

## 9. Dialogs & Modals

### Dialog Types

| Type | Usage | Style |
|------|-------|-------|
| Alert | Information only | Single "OK" button |
| Confirm | Yes/No decision | Two buttons (cancel left, confirm right) |
| Destructive | Delete/Remove | Two buttons, destructive in red |
| Form | Input collection | Bottom sheet preferred |

### Modal Rules

**REQUIRED:**
- Use AppDialog for all confirmations
- Destructive confirmations: red confirm button
- Title: Clear, concise question
- Body: Explain consequences
- Buttons: Cancel always on left, action on right

**FORBIDDEN:**
- Native dialogs (showDialog with AlertDialog)
- Destructive action without confirmation
- More than 2 buttons in confirm dialogs
- Long body text (max 3 lines)

---

## 10. Bottom Sheets

### Bottom Sheet Anatomy

| Component | Specification |
|-----------|---------------|
| Border radius | 16dp top corners |
| Handle | 4dp height, 40dp width, centered, grey |
| Initial height | 50-90% based on content |
| Max height | 90% of screen |
| Background | Surface color |

### Bottom Sheet Rules

**REQUIRED:**
- Drag handle visible at top
- DraggableScrollableSheet for form content
- Keyboard avoidance (sheet rises with keyboard)
- Dismiss on tap outside (when appropriate)

**FORBIDDEN:**
- Full-screen sheets (use screen navigation instead)
- Sheets without drag handle
- Nested bottom sheets
- Sheets under 30% screen height (use dialog instead)

---

## 11. Toast Notifications

### Toast Anatomy

| Component | Specification |
|-----------|---------------|
| Position | Top of screen, below safe area |
| Width | Screen width - 32dp (16dp each side) |
| Border radius | 12dp |
| Icon | Left side, semantic icon |
| Duration | 3 seconds (auto-dismiss) |
| Animation | Slide down + fade in |

### Toast Types

| Type | Color | Icon | Usage |
|------|-------|------|-------|
| Success | Green tint | check_circle | Action completed |
| Error | Red tint | error | Action failed |
| Warning | Orange tint | warning | Caution needed |
| Info | Blue tint | info | Informational |

### Toast Rules

**REQUIRED:**
- Use AppToast for all notifications
- One toast at a time (queue if needed)
- Success after: save, delete, update operations
- Error with: retry guidance when possible

**FORBIDDEN:**
- SnackBar (use AppToast)
- Multiple simultaneous toasts
- Toast for loading states
- Toast without icon

---

## 12. Lists & Scrolling

### List Item Anatomy

| Component | Specification |
|-----------|---------------|
| Height | 72dp minimum for single line with icon |
| Padding | 16dp horizontal |
| Leading icon area | 40dp width |
| Trailing area | 48dp minimum for touch target |
| Divider | 1dp, indent matches content |

### Scrolling Rules

**REQUIRED:**
- CustomScrollView with Slivers for complex layouts
- Pull-to-refresh where data is fetched
- Scroll position preservation on navigation
- Loading indicator during fetch

**FORBIDDEN:**
- SingleChildScrollView for lists (not performant)
- ListView inside Column without constraints
- Infinite scroll without pagination
- Scroll without physics (always bouncing or clamping)

---

## 13. Charts (fl_chart)

### Chart Colors

| Data Type | Color |
|-----------|-------|
| Income data | #00D9A3 (Success) |
| Expense data | #FF4D4F (Error) |
| Neutral data | #6C63FF (Primary) |
| Grid lines | Theme outline color, 20% opacity |
| Labels | Theme text secondary |

### Chart Rules

**REQUIRED:**
- Donut chart: 6 slices maximum (group rest as "Khác")
- Line chart: labeled axes, grid lines
- Bar chart: value labels on or above bars
- Loading state: skeleton or spinner
- Empty state: "Không có dữ liệu" message

**FORBIDDEN:**
- 3D charts
- Pie chart with >6 slices
- Charts without legends
- Animation duration > 300ms
- Continuous chart animation

---

## 14. Navigation

### Bottom Navigation

| Specification | Value |
|---------------|-------|
| Height | 60dp |
| Items | 3-5 maximum |
| Icon size | 24dp |
| Label size | 12dp |
| Active color | Primary |
| Inactive color | Text secondary |

### Navigation Rules

**REQUIRED:**
- Bottom navigation for main sections
- Navigation state preserved (IndexedStack)
- FAB visible only on primary transaction screen
- Consistent back navigation behavior

**FORBIDDEN:**
- Drawer navigation (use bottom nav)
- Tab bar + bottom nav simultaneously
- Deep nesting (max 3 levels)
- Navigation without animation

---

## 15. Loading States

### Loading Patterns

| Pattern | Usage |
|---------|-------|
| Circular spinner | Buttons, small actions |
| Loading overlay | Full-screen blocking operations |
| Skeleton | List items, cards while loading |
| Progress indicator | Long operations with known progress |

### Loading Rules

**REQUIRED:**
- Loading state for every async operation
- Disable interactions during loading
- Skeleton matching content shape
- Timeout handling (show error after 30s)

**FORBIDDEN:**
- Blank screen during load
- Multiple spinners simultaneously
- Loading without timeout
- Spinner on static content

---

## 16. Empty States

### Empty State Anatomy

| Component | Specification |
|-----------|---------------|
| Icon/Illustration | 64-80dp, centered |
| Title | Headline small, centered |
| Body | Body medium, secondary color, centered |
| CTA button | Primary or secondary |
| Position | Centered in available space |

### Empty State Rules

**REQUIRED:**
- Every list has an empty state
- Distinction between "no data ever" vs "no results for filter"
- CTA to add first item (when applicable)
- Encouraging, not error-like tone

**FORBIDDEN:**
- "No data" without explanation
- Empty state without visual element
- Error styling for empty states
- Hiding empty state with scroll

---

## 17. Animations & Transitions

### Duration Scale

| Type | Duration | Curve |
|------|----------|-------|
| Micro-interaction | 100-150ms | easeOut |
| State change | 200ms | easeOut |
| Page transition | 300ms | easeInOut |
| Modal appearance | 250ms | easeOut |

### Animation Rules

**REQUIRED:**
- Purposeful animation only (feedback, guidance)
- Consistent durations within category
- Respect system reduced motion preference
- EaseOut for entering, EaseIn for exiting

**FORBIDDEN:**
- Decorative infinite animations
- Bounce effects (except intentional playfulness)
- Duration > 500ms for UI animations
- Linear easing for UI transitions
- Animation on every interaction

---

## 18. State Management (Riverpod)

### Provider Types

| Type | Usage |
|------|-------|
| Provider | Computed values, services |
| StateNotifierProvider | Complex mutable state |
| AsyncNotifierProvider | Async data with loading/error |
| FutureProvider | One-shot async data |
| StreamProvider | Realtime data |

### State Rules

**REQUIRED:**
- All shared state via Riverpod providers
- AsyncNotifier for data with loading/error states
- Optimistic updates for perceived performance
- Proper disposal of streams and subscriptions

**FORBIDDEN:**
- Global mutable state outside providers
- StatefulWidget for business logic
- setState for shared state
- Providers without proper error handling

---

## 19. Error Handling

### Error Types

| Type | Handling |
|------|----------|
| Network error | Toast + retry option |
| Validation error | Inline field error |
| Server error | Toast with generic message |
| Auth error | Redirect to login |
| Unknown error | Toast + log for debugging |

### Error Rules

**REQUIRED:**
- Every error displays user-friendly message
- Network errors suggest checking connection
- Retry option where possible
- Error logging for debugging (not visible to user)

**FORBIDDEN:**
- Technical error messages shown to user
- Stack traces in UI
- Silent failures
- Errors without recovery path

---

## 20. Code Quality

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Files | snake_case | `transaction_list_screen.dart` |
| Classes | PascalCase | `TransactionListScreen` |
| Variables | camelCase | `transactionList` |
| Constants | camelCase or SCREAMING_SNAKE | `appPrimaryColor` or `APP_PRIMARY_COLOR` |
| Providers | camelCase + Provider suffix | `transactionProvider` |

### Code Rules

**REQUIRED:**
- `flutter analyze` returns zero issues
- Dartdoc comments on public APIs
- const constructors where possible
- Explicit types (no `var` for public APIs)
- Single responsibility per file

**FORBIDDEN:**
- Magic numbers (use named constants)
- Hardcoded strings in UI (use app_strings.dart)
- Print statements (use proper logging)
- Commented-out code
- TODO comments without GitHub issue reference

---

## 21. Localization

### Vietnamese String Rules

**REQUIRED:**
- All user-facing strings in Vietnamese
- Date format: DD/MM/YYYY
- Currency format: 1.000.000 ₫ (dot separator, đồng symbol)
- Time format: HH:mm (24-hour)
- Polite form: use "bạn" for "you"

**Standard Labels:**

| English | Vietnamese |
|---------|------------|
| Add | Thêm |
| Edit | Sửa |
| Delete | Xóa |
| Save | Lưu |
| Cancel | Hủy |
| Close | Đóng |
| Loading | Đang tải |
| Error | Lỗi |
| Success | Thành công |
| Income | Thu nhập |
| Expense | Chi tiêu |
| Balance | Số dư |
| Category | Danh mục |
| Transaction | Giao dịch |
| Settings | Cài đặt |
| Analytics | Thống kê |

**FORBIDDEN:**
- Mixed Vietnamese/English in same screen
- Hardcoded English strings
- Machine-translated awkward phrases

---

## 22. Performance

### Performance Targets

| Metric | Target |
|--------|--------|
| FPS during scroll | 60 FPS |
| Screen transition | < 300ms |
| Chart render | < 200ms |
| Cold start | < 2 seconds |
| Memory (idle) | < 150MB |

### Performance Rules

**REQUIRED:**
- const constructors for static widgets
- RepaintBoundary for complex isolated widgets
- Lazy loading for below-fold content
- Dispose controllers and subscriptions
- Memoize expensive calculations

**FORBIDDEN:**
- Rebuilding entire lists on item change
- Synchronous heavy computation on UI thread
- Large images without caching
- Unbounded ListView in Column

---

## 23. Testing Checklist (Manual)

Before marking any task complete, verify:

### Visual
- [ ] Matches design system colors
- [ ] Typography uses theme styles
- [ ] Spacing follows 8dp grid
- [ ] Border radius is 12dp for cards
- [ ] Works in light mode
- [ ] Works in dark mode

### Interaction
- [ ] Touch targets ≥ 48dp
- [ ] Loading states visible
- [ ] Error states handled
- [ ] Empty states shown
- [ ] Success feedback (toast)

### Quality
- [ ] `flutter analyze` passes
- [ ] No console errors
- [ ] Smooth 60 FPS scrolling
- [ ] Keyboard dismisses properly
- [ ] Back navigation works

---

## Document Version

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2024-03 | Initial Phase 3 standards |

**This document is authoritative.** Any deviation requires explicit approval and documentation of the exception.
