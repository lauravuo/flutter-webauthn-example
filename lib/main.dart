import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:example/pages/loading_page.dart';
import 'package:example/providers.dart';
import 'package:example/router.dart';
import 'package:example/custom_auth.dart';

// Application implementation according to
// https://github.com/corbado/flutter-passkeys/tree/main/packages/passkeys/passkeys/example
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // This is a nice pattern if you need to initialize some of your services
  // before the app starts.
  // As we are using riverpod this initialization happens inside providers.
  // First we show a loading page.
  runApp(const LoadingPage());

  // Now we do the initialization.

  final relyingPartyServer = CustomAuth();
  await relyingPartyServer.init();

  runApp(
    ProviderScope(
      overrides: [
        relyingPartyServerProvider.overrideWithValue(relyingPartyServer),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: false,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color.fromARGB(255, 255, 25, 228),
          onPrimary: Colors.white,
          secondary: Colors.white,
          onSecondary: Colors.black,
          error: Colors.redAccent,
          onError: Colors.white,
          background: Color.fromARGB(255, 255, 25, 228),
          onBackground: Colors.white,
          surface: Color.fromARGB(255, 255, 25, 228),
          onSurface: Color.fromARGB(255, 255, 25, 228),
        ),
      ),
    );
  }
}
