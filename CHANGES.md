# FManagement — Changes Made

This documents everything fixed against the original bug list (Lỗi 1–9), what was
already working before I touched anything, what's genuinely new, and what still
needs attention. Verified with a full clean C++ build against Qt 6 (see
"Validation" at the bottom) — the CMakeLists.txt itself still targets Qt 6.10
exactly as before.

## Lỗi 1 — Responsive layout & debug toolbar
- **Debug toolbar**: `Main.qml` unconditionally showed `DialogTestOverlay`. Now gated
  behind a `--debug-dialogs` launch flag; hidden by default.
- **Overview KPI cards** ("Current M..." cutoff): `OverviewKpiCard.qml`'s amount/date
  text had no `elide`, unlike every other row component in the app. Added
  `elide: Text.ElideRight` with sensible min/max widths so the amount is protected
  and the date truncates gracefully instead of overflowing.
- Audited Transactions/Bills/Budgets/Savings headers and row delegates
  (`TransactionRow_1`, `BillRow_1`, `BudgetRow_1`, `SavingRow_1`) — these already use
  `elide` + `RowLayout` correctly; no changes needed there. Added a missing `elide`
  to `ProgressInfo_1.qml`'s limit text defensively.

## Lỗi 2 — Overview real data
Already fully implemented (`OverviewController` correctly computes net balance,
income/expense, upcoming bills, recent transactions). No changes needed.

## Lỗi 3 — Charts showing wrong/mock data
- Confirmed the donut charts (Expense/Income by Category) were **already correct**
  — the percentage math and drawing order were right; not a bug.
- The "Income vs Expense" bar charts on **both** Overview and Reports, and the
  "Net Worth Growth" chart on Reports, were all hardcoded Jan–Jun mock arrays
  (explaining why Overview and Reports looked identical). Fixed:
  - Added `monthlyIncomeExpense` to `OverviewController` and `ReportsController`
    (real last-6-months income/expense from actual transactions).
  - Added `netWorthTrend` to `ReportsController` (real cumulative running balance
    as of the end of each of the last 6 months).
  - Both bar charts now auto-scale their Y-axis to the real data (a "nice number"
    algorithm) instead of a fixed 20M ceiling.
  - Net Worth chart's Y-axis also handles negative net worth correctly if it ever
    occurs.
  - Retitled Overview's chart from "Last Month" to "Last 6 Months" to match what's
    actually displayed.

## Lỗi 4 — Budgets page (was completely non-functional)
Root cause: `budgets_controller.h/.cpp` were literal empty stub files
(`//dummy file`), and were **never instantiated in `main.cpp`** — so nothing on
this page could ever have worked. `DatabaseManager`'s budget CRUD storage layer
was already solid, though.
- Wrote `BudgetsController` from scratch (`QAbstractListModel`, mirroring the
  working `BillsController` pattern): real list + roles, aggregate totals, priority/
  category/search filters, add/update/delete.
- Wired it up in `main.cpp` and exposed it as `budgetsController`.
- Rebuilt `BudgetDialog.qml` from an unwired static shell into a fully working
  add/edit form (validation, live category list from `categoriesController`,
  comma-formatted amount input, Period dropdown that auto-fills End Date from
  Start Date).
- Rewrote `BudgetsPage.qml`: real summary cards, working search/priority filter
  buttons/category dropdown, real ListView bound to `budgetsController`, working
  Add/Edit/Delete (Delete goes through the existing `DeleteDialog` confirmation).

## Lỗi 5 — Savings page (same situation as Budgets)
- `Saving` model had no `priority` field even though the UI already had a Priority
  column — added it (reusing Budget's `Priority` enum), updated the CSV format
  (`savings.csv` now has a `priority` column) and `DatabaseManager`'s load/save.
- `DatabaseManager` only had additive `contributeToSaving()`, no way to actually
  edit a saving goal — added `updateSaving()` for full edits (name, category,
  target, priority, and directly setting the current amount, per the "số tiền đã
  tiết kiệm" requirement in the spec).
- Wrote `SavingsController` from scratch, same treatment as Budgets.
- Rebuilt `SavingDialog.qml` and rewrote `SavingsPage.qml` the same way.

## Lỗi 6 — New category not appearing / "0 VND" total
- The "doesn't appear in the list" symptom: traced the full path (dialog →
  `CategoriesController::addCategory` → `DatabaseManager` → `categoriesChanged`
  signal → QML `model:` binding) and it was already correct end-to-end — this
  looks like it was already fixed in this branch, or was a filter/UX issue rather
  than a real binding bug. No changes needed there.
- **"TOTAL MONEY BY CATEGORY" hardcoded to "0 VND"**: this was real. Fixed —
  `CategoriesController::categoriesList()` now sums real transaction amounts per
  category.

## Lỗi 7 — Reports not rendering on tab switch
The app uses `StackLayout` (not a lazy `Loader`), so every page — including
Reports — is actually instantiated at startup with real geometry, which should
already avoid this class of bug. As cheap insurance anyway, added
`Component.onCompleted: requestPaint()` to all 5 chart canvases (Overview's bar
chart + Reports' bar/net-worth/expense-donut/income-donut charts) so they're
guaranteed at least one real paint regardless of timing.

## Lỗi 8 — Settings avatar (new feature)
- `SettingsController`: added `avatarImagePath`, `avatarColor`, `initials`
  properties; `setAvatarImage()` / `setAvatarPreset()`; persisted to
  `data/avatar.txt` and reloaded (with an existence check) on startup.
- `SettingsPage.qml`: circular avatar (shows the uploaded photo, or a colored
  initials placeholder if none is set) with a "Đổi ảnh đại diện" button opening a
  popup with (a) **Upload From This Device** via a real `FileDialog`
  (`QtQuick.Dialogs`/`Qt6::QuickDialogs2` — added to `CMakeLists.txt`), and (b) a
  grid of 12 preset colors.

## Lỗi 9 — Login page (new feature)
- New `SessionController` (`frontend/session_controller.h/.cpp`): single-user
  login backed by `data/auth.csv` (seeded with `admin` / `admin123` on first run),
  optional "remember me" persisted to `data/session.txt` for auto-login on next
  launch, and `logout()`.
  - **Security note**: credentials are plain text in `auth.csv`, which is fine for
    a local student-project demo but is not how a real product should store
    passwords (those need salting + hashing). Flagged clearly in a code comment.
- New `qml/pages/LoginPage.qml`: username/password form, show/hide password toggle
  reusing the existing `Eye`/`Eye_off` icon components, "remember me", inline error
  message, FManagement branding/colors.
- `Main.qml` now shows `LoginPage` until `sessionController.isLoggedIn`, then
  reveals the sidebar + pages, landing on Overview after a successful login.
- `SettingsPage.qml` got a new "Account" card with a working Logout button that
  calls `sessionController.logout()` and returns to the Login screen.

## Files changed
**New files**: `frontend/session_controller.{h,cpp}`, `qml/pages/LoginPage.qml`,
`data/auth.csv`

**Rewritten from stubs/broken state**: `frontend/budgets_controller.{h,cpp}`,
`frontend/savings_controller.{h,cpp}`, `qml/components/dialogs/BudgetDialog.qml`,
`qml/components/dialogs/SavingDialog.qml`, `qml/pages/BudgetsPage.qml`,
`qml/pages/SavingsPage.qml`

**Modified**: `main.cpp`, `CMakeLists.txt`, `Main.qml`, `backend/models/saving.{h,cpp}`,
`backend/storage/database_manager.h`, `backend/storage/database_manager_saving.cpp`,
`data/savings.csv`, `frontend/overview_controller.{h,cpp}`,
`frontend/reports_controller.{h,cpp}`, `frontend/categories_controller.cpp`,
`frontend/settings_controller.{h,cpp}`, `qml/pages/OverviewPage.qml`,
`qml/pages/ReportsPage.qml`, `qml/pages/CategoriesPage.qml`,
`qml/pages/SettingsPage.qml`, `qml/components/OverviewKpiCard.qml`,
`qml/components/ProgressInfo_1.qml`

## Validation
The project doesn't build with Ubuntu's packaged Qt (6.4.2 — this project targets
6.10, which isn't in Ubuntu's apt repos), so I temporarily lowered
`REQUIRES 6.10` → `REQUIRES 6.4` in a **throwaway copy only** to get a real
compiler in the loop, and confirmed:
- A clean, warning-free build of every new/changed C++ file (controllers, models,
  storage layer, `main.cpp`) against a real Qt6 toolchain, including the new
  `Qt6::QuickDialogs2` dependency.
- The app starts, loads all CSVs correctly (including the new `priority` column
  in `savings.csv` and the new `auth.csv`), with no crashes.
- A pre-existing QML resource-loading quirk when run under Qt 6.4 instead of the
  project's actual Qt 6.10 exists identically on a pristine, **unmodified** clone
  of the repo — confirming it's an environment/version mismatch on my end, not a
  regression from these changes.
- `qmllint` static analysis on the changed QML files turned up nothing beyond the
  expected "unresolved context property" noise every page in this codebase
  already produces (e.g. `overviewController`, `categoriesController`), since
  those are wired up in C++ at runtime, not visible to a standalone linter.

**What I could not do**: actually see the rendered UI, since I don't have the
project's exact Qt 6.10 and there's no display in this environment. Recommend a
visual pass against the Figma file (spacing/colors/fonts) and a real resize-test
pass on your machine before calling Lỗi 1's Definition-of-Done fully checked off.
