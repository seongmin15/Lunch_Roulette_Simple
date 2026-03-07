# Framework — Flutter

> This skill defines Flutter-specific patterns for the **lunch-roulette-app** service.
> Approach: **cross_platform** | Navigation: ****
> Min OS: **iOS 14.0, Android 8.0 (API 26)**
> Read this before building or modifying any mobile logic.

---

## 1. Application Bootstrap

```dart
// main.dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}
```

```dart
// app/app.dart
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(               // Riverpod (if used)
      child: MaterialApp.router(
        routerConfig: appRouter,
        theme: appTheme,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
```

**Provider nesting order (if wrapping manually):**

```dart
ProviderScope(                          // state management (outermost)
  child: AuthGuard(                     // auth gate
    child: MaterialApp.router(
      routerConfig: appRouter,
      theme: appTheme,
      localizationsDelegates: [...],
    ),
  ),
)
```

**Rules:**
- Call `WidgetsFlutterBinding.ensureInitialized()` before any plugin usage in `main()`.
- Use `MaterialApp.router()` with declarative routing (GoRouter).
- Initialize async services (SharedPreferences, Firebase) before `runApp()`.

---

## 2. Navigation


**Auth-aware routing:**

```dart
final appRouter = GoRouter(
  redirect: (context, state) {
    final isLoggedIn = ref.read(authProvider).isAuthenticated;
    final isLoginRoute = state.matchedLocation == '/login';
    if (!isLoggedIn && !isLoginRoute) return '/login';
    if (isLoggedIn && isLoginRoute) return '/home';
    return null;
  },
  routes: [...],
);
```

**Rules:**
- Use **GoRouter** for declarative, type-safe routing.
- Define all routes in a single `router.dart` file.
- Always validate path parameters before use.
- Auth flow: use `redirect` guard — not separate widget trees.

---

## 3. Data Fetching

**Use Dio for HTTP + a repository/service layer.**

```dart
// services/api_client.dart
class ApiClient {
  final Dio _dio;

  ApiClient({required String baseUrl, Dio? dio})
      : _dio = (dio ?? Dio())
          ..options.baseUrl = baseUrl
          ..options.connectTimeout = const Duration(seconds: 10)
          ..interceptors.add(AuthInterceptor());

  Future<T> get<T>(String path, {T Function(dynamic)? fromJson}) async {
    final response = await _dio.get(path);
    return fromJson != null ? fromJson(response.data) : response.data as T;
  }

  Future<T> post<T>(String path, {dynamic data, T Function(dynamic)? fromJson}) async {
    final response = await _dio.post(path, data: data);
    return fromJson != null ? fromJson(response.data) : response.data as T;
  }
}
```

```dart
// services/user_api.dart
class UserApi {
  final ApiClient _client;
  UserApi(this._client);

  Future<User> getById(String id) =>
      _client.get('/users/$id', fromJson: User.fromJson);
}
```

**Auth interceptor pattern:**

```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await SecureStorage.readToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // trigger logout or token refresh
    }
    handler.next(err);
  }
}
```

---

## 4. Offline Support

**Offline support: not enabled.** Handle network errors gracefully with retry and user feedback.

---

## 5. Device Features


**Permission handling pattern:**

```dart
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestCameraPermission() async {
  final status = await Permission.camera.request();
  if (status.isPermanentlyDenied) {
    openAppSettings();
    return false;
  }
  return status.isGranted;
}
```

**Rules:**
- Request permissions at point of use, not on app launch.
- Always handle denial gracefully — show explanation and alternative.
- Check permission status before each use (user can revoke anytime).
- Use `openAppSettings()` when permanently denied.

---

## 7. Performance

- **Widget rebuilds:** Use `const` constructors. Split large widgets into small `StatelessWidget`s.
- **Lists:** Use `ListView.builder` / `SliverList` — never `Column` with `children: list.map(...)`.
- **Images:** Use `cached_network_image` for network images with disk caching.
- **Animations:** Prefer implicit animations (`AnimatedContainer`, `AnimatedOpacity`). Use `AnimationController` only when needed.
- **Shader compilation jank:** Run `flutter build` with `--bundle-sksl-warmup` for release builds.
- **Bundle size:** Use `--split-debug-info` and `--obfuscate` for release. Monitor with `flutter build --analyze-size`.
- **Startup:** Defer non-critical work. Use `Future.microtask` or `WidgetsBinding.addPostFrameCallback`.


---

## 9. Common Pitfalls

| Pitfall | Problem | Solution |
|---------|---------|----------|
| Missing `const` constructors | Unnecessary widget rebuilds | Add `const` wherever possible |
| `setState` in large widgets | Entire subtree rebuilds | Split into small widgets or use state management |
| `Column` + `map()` for long lists | All items rendered at once (no virtualization) | `ListView.builder` with `itemBuilder` |
| Storing tokens in SharedPreferences | Not encrypted on device | Use `flutter_secure_storage` for secrets |
| Unhandled permission denial | App crash or bad UX | Always handle denial + permanently denied cases |
| Platform-specific bugs | Works on iOS, breaks Android | Test on both platforms regularly |
| Large images in memory | OOM on low-end devices | Use disk cache, resize before display |
| Blocking `main()` | White screen on startup | Async init with splash screen |
