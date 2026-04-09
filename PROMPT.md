# PHASE 3: Task-by-Task Execution Plan

## Overview

This document provides a **sequential, implementable task list** for Phase 3. Each task is designed to be completed by Claude CLI in a single session, with clear goals, file targets, and UX expectations.

**Task numbering continues from Phase 2** (which ended at T12).

---

## Wave 1: Analytics Foundation

### T13: Analytics Summary Card on Transaction List

**Goal:**
Add a summary card at the top of the transaction list showing current month's key metrics: total income, total expenses, and net balance.

**Why it matters:**
- Users currently have no quick overview of their financial status
- Transforms a passive list into an informative dashboard
- Provides immediate value from recorded transactions
- Creates foundation for analytics screen

**Files to create/update:**
- `lib/presentation/widgets/analytics/monthly_summary_card.dart` (CREATE)
- `lib/presentation/providers/analytics_provider.dart` (CREATE)
- `lib/presentation/screens/transactions/transactions_list_screen.dart` (UPDATE)

**UX Expectations:**
- Card positioned ABOVE the filter bar in CustomScrollView
- Purple gradient background (existing brand gradient)
- Three values displayed: Income (green), Expenses (red), Net (primary)
- Vietnamese labels: "Thu nhập", "Chi tiêu", "Số dư"
- Amounts in VND format with currency formatter
- Card has subtle elevation (2dp)
- Loading skeleton while calculating
- Tappable → navigates to full analytics screen (T15)

**Technical Notes:**
- AnalyticsProvider computes values from TransactionProvider
- Use `ref.watch(transactionProvider)` to stay reactive
- Cache computed values to avoid recalculation on every build

---

### T14: Category Breakdown Provider

**Goal:**
Create a provider that calculates spending breakdown by category for charts.

**Why it matters:**
- Foundation for pie/donut chart visualization
- Enables "where does my money go" insights
- Required for T15 analytics screen

**Files to create/update:**
- `lib/data/models/category_stats_model.dart` (CREATE)
- `lib/presentation/providers/category_analytics_provider.dart` (CREATE)

**UX Expectations:**
- (Backend task—no direct UI in this task)
- Model includes: categoryId, categoryName, categoryColor, categoryIcon, totalAmount, transactionCount, percentage
- Provider filters by date range (current month default)
- Provider filters by transaction type (income vs expense separately)
- Sorted by totalAmount descending

**Technical Notes:**
- CategoryStatsModel is immutable with copyWith
- Provider depends on TransactionProvider and CategoryProvider
- Implement efficient groupBy calculation
- Return top 6 categories + "Other" for remaining (chart limit)

---

### T15: Analytics Screen with Charts

**Goal:**
Create a dedicated analytics screen with spending charts and insights.

**Why it matters:**
- Users want to visualize their spending patterns
- Charts communicate complex data at a glance
- Differentiates app from basic expense trackers
- Leverages fl_chart dependency (already added)

**Files to create/update:**
- `lib/presentation/screens/analytics/analytics_screen.dart` (CREATE)
- `lib/presentation/widgets/analytics/spending_pie_chart.dart` (CREATE)
- `lib/presentation/widgets/analytics/spending_trend_chart.dart` (CREATE)
- `lib/presentation/widgets/analytics/category_breakdown_list.dart` (CREATE)
- `lib/routes/app_routes.dart` (UPDATE)

**UX Expectations:**

**Screen Layout (top to bottom):**
1. AppBar with title "Thống kê" and month selector
2. Summary card (reuse from T13)
3. Tab bar: "Chi tiêu" / "Thu nhập"
4. Donut chart showing category breakdown (6 max slices)
5. Category breakdown list below chart (scrollable)
6. Trend line chart showing daily spending for the month

**Visual Design:**
- Donut chart centered, 60% of screen width
- Category colors from CategoryModel
- Legend below or beside chart
- Line chart shows spending over time (x-axis: days, y-axis: amount)
- Empty state if no transactions for selected period

**Interactions:**
- Month selector dropdown or horizontal scroll
- Tap pie slice → highlight corresponding list item
- Tap category item → filter transactions by category
- Pull-to-refresh

**Technical Notes:**
- Use fl_chart PieChart and LineChart widgets
- Chart data comes from category_analytics_provider
- Implement chart loading state (shimmer or skeleton)
- Cache chart data to prevent recalculation on rebuild

---

### T16: Navigation Integration for Analytics

**Goal:**
Add bottom navigation to switch between Transactions and Analytics screens.

**Why it matters:**
- Users need easy access to analytics
- Bottom navigation is standard mobile pattern
- Prepares for future screens (Settings in T17)

**Files to create/update:**
- `lib/presentation/screens/home/home_screen.dart` (CREATE)
- `lib/presentation/widgets/navigation/app_bottom_navigation.dart` (CREATE)
- `lib/presentation/widgets/auth_gate.dart` (UPDATE)
- `lib/routes/app_routes.dart` (UPDATE)

**UX Expectations:**
- Bottom navigation bar with 3 items:
  1. "Giao dịch" (Transactions) - icon: receipt_long
  2. "Thống kê" (Analytics) - icon: pie_chart
  3. "Cài đặt" (Settings) - icon: settings (placeholder for T17)
- Purple accent on selected item
- Smooth page transitions (no animation, instant switch)
- FAB remains visible on transactions screen
- FAB hidden on other screens
- Navigation state preserved when switching tabs

**Technical Notes:**
- HomeScreen uses IndexedStack or PageView for tab content
- AuthGate now navigates to HomeScreen instead of TransactionsListScreen
- Preserve scroll position when switching tabs
- Settings tab shows placeholder until T17

---

## Wave 2: Settings & Personalization

### T17: Settings Screen Foundation

**Goal:**
Create the settings screen with account info and preference sections.

**Why it matters:**
- Users expect settings in any serious app
- Foundation for dark mode toggle, export, and preferences
- Shows user account info (builds trust)

**Files to create/update:**
- `lib/presentation/screens/settings/settings_screen.dart` (CREATE)
- `lib/presentation/widgets/settings/settings_section.dart` (CREATE)
- `lib/presentation/widgets/settings/settings_tile.dart` (CREATE)
- `lib/core/constants/app_strings.dart` (CREATE - centralize strings)

**UX Expectations:**

**Screen Layout:**
1. User info header (name, email, avatar placeholder)
2. "Giao diện" section (Appearance)
   - Dark mode toggle (T18)
   - Language (locked to Vietnamese for now)
3. "Dữ liệu" section (Data)
   - Export transactions (T21)
   - Clear all data (destructive, with confirmation)
4. "Tài khoản" section (Account)
   - Change password (placeholder)
   - Logout

**Visual Design:**
- Grouped list layout with section headers
- Grey section headers, white tiles
- Right chevron for drill-down items
- Toggle switch for boolean settings
- Destructive items in red text
- Consistent with existing card styling

**Interactions:**
- Logout shows confirmation dialog
- Clear data shows destructive confirmation dialog
- Settings changes persist immediately

**Technical Notes:**
- Create reusable SettingsSection and SettingsTile widgets
- Logout calls existing authProvider.signOut()
- Prepare hooks for dark mode and export (implement in later tasks)

---

### T18: Dark Mode Implementation

**Goal:**
Implement dark mode theme and toggle in settings.

**Why it matters:**
- Expected feature in modern apps (2024+)
- Reduces eye strain for night usage
- OLED screens benefit from power savings
- Premium perception

**Files to create/update:**
- `lib/core/constants/app_colors.dart` (UPDATE - add dark variants)
- `lib/core/theme/app_theme.dart` (CREATE)
- `lib/presentation/providers/theme_provider.dart` (CREATE)
- `lib/main.dart` (UPDATE)
- `lib/presentation/screens/settings/settings_screen.dart` (UPDATE)

**UX Expectations:**

**Dark Mode Colors (from ui-ux-pro-max):**
- Background: #121212 (Material dark)
- Surface: #1E1E1E
- Card: #252525
- Primary: #6C63FF (same purple, works on dark)
- Text primary: #FFFFFF
- Text secondary: #B0B0B0
- Divider: #333333

**Behavior:**
- Toggle in settings switches immediately
- System theme option: "Auto" / "Light" / "Dark"
- Persist preference in SharedPreferences
- All existing screens adapt to theme
- Charts update colors for dark mode

**Visual Consistency:**
- Test EVERY screen in dark mode
- Ensure 4.5:1 contrast ratio minimum
- Income green and expense red still distinguishable
- Icons visible on dark backgrounds

**Technical Notes:**
- ThemeProvider uses StateNotifier with AsyncValue
- Load theme preference on app start
- Use Theme.of(context) for all color access
- Update app_colors.dart with getDarkColor() methods

---

### T19: Settings Persistence

**Goal:**
Persist user preferences using SharedPreferences.

**Why it matters:**
- Users expect settings to persist
- Foundation for future preferences
- Professional app behavior

**Files to create/update:**
- `lib/data/services/preferences_service.dart` (CREATE)
- `lib/presentation/providers/theme_provider.dart` (UPDATE)
- `lib/main.dart` (UPDATE - load preferences before runApp)

**UX Expectations:**
- App remembers theme choice on restart
- No visible UI change (backend task)
- Loading preferences doesn't delay app startup noticeably

**Technical Notes:**
- PreferencesService wraps SharedPreferences
- Keys: 'theme_mode' (light/dark/system)
- Initialize preferences in main() before ProviderScope
- Provide singleton via Riverpod provider

---

## Wave 3: Data Management

### T20: Custom Categories Screen

**Goal:**
Allow users to create, edit, and delete custom categories.

**Why it matters:**
- System categories don't cover all use cases
- Personalization builds ownership
- Users want to organize expenses their way

**Files to create/update:**
- `lib/presentation/screens/categories/categories_screen.dart` (CREATE)
- `lib/presentation/screens/categories/category_form_screen.dart` (CREATE)
- `lib/presentation/widgets/categories/category_list_item.dart` (CREATE)
- `lib/data/repositories/category_repository.dart` (UPDATE - add CRUD)
- `lib/presentation/providers/category_provider.dart` (UPDATE)
- `lib/routes/app_routes.dart` (UPDATE)

**UX Expectations:**

**Categories Screen:**
- Access from settings screen
- Two tabs: "Chi tiêu" (Expense) / "Thu nhập" (Income)
- List of categories with icon, name, color
- System categories marked with lock icon (not editable)
- User categories have swipe-to-delete
- FAB to add new category

**Category Form:**
- Bottom sheet modal (consistent with transaction form)
- Fields: Name, Type (income/expense), Icon picker, Color picker
- Icon picker shows grid of material icons (subset)
- Color picker shows predefined palette (8-12 colors)
- Validation: name required, max 30 chars

**Interactions:**
- Tap user category to edit
- Swipe to delete (with confirmation)
- Delete prevented if category has transactions (show warning)
- New category appears immediately in list

**Technical Notes:**
- CategoryRepository adds: insertCategory, updateCategory, deleteCategory
- Supabase table: categories (existing, add isSystem column if needed)
- Optimistic updates like transactions
- Refresh category cache after mutations

---

### T21: Export Transactions to CSV

**Goal:**
Allow users to export their transactions as a CSV file.

**Why it matters:**
- Data portability builds trust
- Users may need data for taxes, budgeting apps
- Professional finance app expectation

**Files to create/update:**
- `lib/data/services/export_service.dart` (CREATE)
- `lib/presentation/screens/settings/settings_screen.dart` (UPDATE)
- `pubspec.yaml` (UPDATE - add path_provider, share_plus if needed)

**UX Expectations:**

**Export Flow:**
1. User taps "Xuất giao dịch" in settings
2. Date range picker appears (default: all time)
3. Loading indicator while generating
4. System share sheet opens with CSV file
5. Success toast after share completes

**CSV Format:**
```
Ngày,Loại,Danh mục,Số tiền,Ghi chú
2024-03-15,Chi tiêu,Ăn uống,150000,Bữa trưa
2024-03-15,Thu nhập,Lương,10000000,Tháng 3
```

**Edge Cases:**
- No transactions → show info dialog, don't create empty file
- Large dataset (1000+) → show progress indicator
- Export cancelled → no side effects

**Technical Notes:**
- ExportService generates CSV string
- Use share_plus for cross-platform sharing
- path_provider for temporary file storage
- UTF-8 encoding with BOM for Excel compatibility

---

### T22: Delete Account & Data

**Goal:**
Allow users to delete all their data or their entire account.

**Why it matters:**
- GDPR-like compliance
- User trust through data control
- Clean exit option

**Files to create/update:**
- `lib/data/repositories/auth_repository.dart` (UPDATE)
- `lib/presentation/screens/settings/settings_screen.dart` (UPDATE)

**UX Expectations:**

**Clear All Data:**
- Confirmation dialog with warning
- Explains: "Điều này sẽ xóa tất cả giao dịch và danh mục tùy chỉnh"
- Two-step confirmation (type "XÓA" to confirm)
- Success toast, return to empty state

**Delete Account:**
- Destructive confirmation dialog
- Explains: "Điều này sẽ xóa tài khoản và tất cả dữ liệu vĩnh viễn"
- Two-step confirmation
- Log out after deletion, return to login

**Technical Notes:**
- Clear data: DELETE from transactions WHERE user_id = current
- Delete account: Supabase auth.delete() + cascade delete
- Show loading overlay during deletion
- Handle errors gracefully

---

## Wave 4: Polish & Performance

### T23: Performance Optimization

**Goal:**
Optimize list scrolling, chart rendering, and memory usage.

**Why it matters:**
- Smooth scrolling is non-negotiable for quality feel
- Charts must render quickly
- Memory leaks degrade long session experience

**Files to create/update:**
- `lib/presentation/screens/transactions/transactions_list_screen.dart` (UPDATE)
- `lib/presentation/screens/analytics/analytics_screen.dart` (UPDATE)
- `lib/presentation/providers/transaction_provider.dart` (UPDATE)

**UX Expectations:**
- 60 FPS scrolling with 500+ transactions
- Charts render in < 200ms
- No jank during tab switches
- Memory stable during 10+ minute sessions

**Optimizations to implement:**
1. Transaction list virtualization (already using Sliver, verify)
2. Memoize category lookups in list items
3. Use const constructors where possible
4. Lazy load chart data only when tab visible
5. Dispose listeners and subscriptions properly
6. Profile with Flutter DevTools, fix hotspots

**Technical Notes:**
- Add performance monitoring comments
- Use RepaintBoundary for complex widgets
- Consider cacheExtent for ListView
- Test on low-end device (or emulator throttled)

---

### T24: Empty States & Edge Cases

**Goal:**
Review and polish all empty states and edge case handling.

**Why it matters:**
- Empty states are first impression for new users
- Edge cases left unhandled feel broken
- Polish differentiates amateur from professional

**Files to create/update:**
- `lib/presentation/widgets/empty_states/` (CREATE directory)
- Multiple screen files (UPDATE as needed)

**UX Expectations:**

**Empty States to verify/improve:**
1. Transaction list (no transactions ever)
2. Transaction list (filters return empty)
3. Analytics (no transactions for month)
4. Categories (no custom categories)
5. Chart (no data to visualize)

**Edge Cases to handle:**
1. Network error during load
2. Network error during submit
3. Session expired mid-action
4. Extremely long category names
5. Extremely large amounts
6. Future-dated transactions
7. Date picker edge cases

**Each empty state must have:**
- Relevant illustration or icon
- Clear message explaining state
- CTA button to resolve (if applicable)
- Consistent styling

**Technical Notes:**
- Create reusable EmptyState widget
- Standardize error handling pattern
- Test offline behavior

---

### T25: Accessibility Audit

**Goal:**
Ensure app meets basic accessibility requirements.

**Why it matters:**
- Inclusive design is ethical requirement
- Accessibility often improves UX for everyone
- Required for app store compliance in some regions

**Files to create/update:**
- Multiple widget files (UPDATE as needed)
- `lib/core/theme/app_theme.dart` (UPDATE)

**UX Expectations:**

**Audit Checklist:**
1. All interactive elements have minimum 48x48dp touch targets
2. Color is not the only indicator (income/expense have icons)
3. Text contrast meets 4.5:1 ratio
4. Semantic labels on icons and images
5. Keyboard navigation works (for desktop/web future)
6. Screen reader can announce transaction list items
7. Loading states are announced

**From ui-ux-pro-max:**
- Respect prefers-reduced-motion (if applicable)
- Error messages have role="alert" semantics
- Form inputs have associated labels

**Technical Notes:**
- Use Semantics widget where needed
- Test with TalkBack (Android) or VoiceOver (iOS)
- Add excludeFromSemantics where appropriate

---

### T26: Final Polish Pass

**Goal:**
Complete quality pass on all screens before Phase 3 closure.

**Why it matters:**
- Details matter for product perception
- Consistency across screens builds trust
- This task catches anything missed earlier

**Files to create/update:**
- Various (based on findings)

**Checklist:**

**Visual Consistency:**
- [ ] All screens use consistent padding (16dp horizontal)
- [ ] All cards use 12dp border radius
- [ ] All buttons use correct variants
- [ ] Colors match design system exactly
- [ ] Typography hierarchy consistent

**Interaction Consistency:**
- [ ] All destructive actions have confirmation
- [ ] All async actions show loading state
- [ ] All success actions show toast
- [ ] All errors show toast with retry option
- [ ] Pull-to-refresh where applicable

**Dark Mode:**
- [ ] Test every screen in dark mode
- [ ] Fix any contrast issues
- [ ] Charts readable in both modes

**Vietnamese:**
- [ ] All strings in Vietnamese
- [ ] No hardcoded English strings
- [ ] Date format DD/MM/YYYY throughout

**Code Quality:**
- [ ] flutter analyze returns zero issues
- [ ] No debug print statements
- [ ] No TODO comments left unresolved

---

## Task Dependencies

```
T13 (Summary Card)
 └── T14 (Category Analytics Provider)
      └── T15 (Analytics Screen)
           └── T16 (Bottom Navigation)

T16 (Bottom Navigation)
 └── T17 (Settings Screen)
      ├── T18 (Dark Mode)
      │    └── T19 (Settings Persistence)
      ├── T20 (Custom Categories)
      ├── T21 (Export CSV)
      └── T22 (Delete Account)

T15, T16, T17, T18, T19, T20, T21, T22
 └── T23 (Performance)
      └── T24 (Empty States)
           └── T25 (Accessibility)
                └── T26 (Final Polish)
```

---

## Estimated Task Complexity

| Task | Complexity | New Files | Key Challenges |
|------|------------|-----------|----------------|
| T13 | Medium | 2 | Provider computation, gradient styling |
| T14 | Medium | 2 | GroupBy logic, percentage calculation |
| T15 | High | 4 | fl_chart integration, chart styling |
| T16 | Medium | 2 | Navigation state, FAB visibility |
| T17 | Medium | 3 | Reusable settings widgets |
| T18 | High | 2 | Theme system overhaul, testing all screens |
| T19 | Low | 1 | SharedPreferences wrapper |
| T20 | High | 4 | Full CRUD, icon picker, color picker |
| T21 | Medium | 1 | CSV generation, file sharing |
| T22 | Low | 0 | Confirmation flow, cascade delete |
| T23 | Medium | 0 | Profiling, optimization |
| T24 | Medium | 1+ | Comprehensive review |
| T25 | Medium | 0 | Accessibility testing |
| T26 | Low | 0 | Polish and verification |

---

## Implementation Notes for Claude CLI

1. **One task per session** - Complete T13 fully before starting T14
2. **Run flutter analyze after each task** - Zero issues required
3. **Test in dark mode from T18 onward** - Every new screen
4. **Follow STRICT_DESIGN_CODE_STANDARDS.md** - Non-negotiable
5. **Vietnamese strings only** - No English in UI
6. **Commit after each task** - Clean git history
