# To-Do App — Flutter

Complete UI built on top of your existing models, provider, and services — now verified against your actual Postman collection.

## 1. Setup

1. **Delete your existing `lib/Provider` and `lib/services` folders first**, then copy this `lib/` folder in on top. (This avoids the exact issue from before — stale files sitting alongside new ones.)
2. Merge the dependencies from `pubspec.yaml` into your existing `pubspec.yaml`, then run:
   ```
   flutter pub get
   ```
3. **Replace `{{TODO_URL}}`** in `lib/services/auth.dart` and `lib/services/task.dart` with your actual backend base URL.
4. Run the app:
   ```
   flutter run
   ```

## 2. Fixes made after checking your Postman collection

Three real bugs were caught by cross-checking against your actual API:

1. **`GET /users/profile`** returns the user fields flat — `{"_id":..., "name":..., "email":...}` — not wrapped in `{"user": {...}}`. `UserModel.fromJson` now handles both shapes, so profile loading actually works.
2. **`PUT /users/profile`**, not `/users/` — the original `UpdateProfile` call had the wrong URL and would have 404'd.
3. **There's no separate "toggle complete" endpoint.** Both editing the description and toggling complete are the *same* call: `PATCH /todos/update/:id`, just with different body fields. `toggleComplete` now calls `updateTask` under the hood with only the `complete` field set.

## 3. What's new

**Screens**
- `views/splash.dart` — checks for a saved login token on launch and routes straight to Home if valid.
- `views/login.dart` / `views/register.dart` — form validation, password visibility toggle, loading states, proper navigation.
- `views/home.dart` — task list with All / Active / Done tabs, pull-to-refresh, empty state, FAB to add tasks, and a **live search bar** wired to `GET /todos/search`.
- `views/add_edit_task.dart` — bottom sheet for creating and editing a task.
- `views/profile.dart` — view/edit name, logout (now calls `POST /users/logout` before clearing the local session).

**State management**
- `provider/user.dart` (now `Provider/user.dart` to match your folder casing) — stores and persists the auth token via `shared_preferences`. Added `logout()`.
- `provider/task.dart` (now `Provider/task.dart`) — task list, loading/error state, active filter, optimistic add/toggle/update/delete, plus search state.

**Services — `services/task.dart`**
- Kept your existing `createTask`, `getAllTasks`, `getCompletedTasks`, `getInCompletedTasks` as-is (fixed the broken import with the stray space).
- `updateTask({token, id, description?, complete?})` — matches the real `PATCH /todos/update/:id`, sends only the fields you pass.
- `toggleComplete()` — thin wrapper over `updateTask` sending just `complete`.
- `deleteTask()` — matches `DELETE /todos/delete/:id`.
- Bonus, added from your collection but not required for the core flow: `getTaskById`, `filterTasksByDate`, `searchTasks` (this one is wired into the Home search bar).

**Services — `services/auth.dart`**
- Fixed `UpdateProfile` URL.
- Added `logoutUser(token)` for `POST /users/logout`.

**Widgets & theme** — unchanged from before (`task_card.dart`, `app_widgets.dart`, `app_theme.dart`).

## 4. Notes

- `filterTasksByDate` and `getTaskById` are implemented in the service layer but not yet wired into any screen — happy to add a date-range filter UI or a task detail view if you want those surfaced.
- If your backend expects the token with a `Bearer ` prefix, add it where `Authorization` headers are set in `services/auth.dart` and `services/task.dart`.

