import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'src/screens/home_screen.dart';
import 'src/screens/login_screen.dart';
import 'src/state/app_state.dart';
import 'src/theme/glass_theme.dart';

bool get _isDesktop =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Desktop: give the window a sensible default + minimum size and a clean title bar.
  if (_isDesktop) {
    await windowManager.ensureInitialized();
    const options = WindowOptions(
      size: Size(1120, 740),
      minimumSize: Size(720, 520),
      center: true,
      title: 'Sunrise',
      titleBarStyle: TitleBarStyle.normal,
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const SunriseApp());
}

class SunriseApp extends StatefulWidget {
  const SunriseApp({super.key});

  @override
  State<SunriseApp> createState() => _SunriseAppState();
}

class _SunriseAppState extends State<SunriseApp> {
  final AppState _state = AppState();
  bool _restoring = true;

  @override
  void initState() {
    super.initState();
    // Try to resume a saved session; show a splash until we know the result.
    _state.tryRestoreSession().whenComplete(() {
      if (mounted) setState(() => _restoring = false);
    });
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sunrise',
      debugShowCheckedModeBanner: false,
      theme: buildGlassTheme(Brightness.light),
      darkTheme: buildGlassTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: Builder(builder: (context) {
        // Keep the brightness-aware Palette in sync with the active theme.
        Palette.dark = Theme.of(context).brightness == Brightness.dark;
        if (_restoring) {
          return const _Splash();
        }
        return ListenableBuilder(
          listenable: Listenable.merge([_state, _state.call, _state.liveKit]),
          builder: (context, _) {
            return _state.phase == Phase.ready
                ? HomeScreen(state: _state)
                : LoginScreen(state: _state);
          },
        );
      }),
    );
  }
}

/// Minimal splash shown while a saved session is being restored.
class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('☀️', style: TextStyle(fontSize: 44)),
            SizedBox(height: 16),
            SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        ),
      ),
    );
  }
}
