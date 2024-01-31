import 'package:go_router/go_router.dart';
import 'package:example/pages/profile_page.dart';
import 'package:example/pages/sign_in_page.dart';
import 'package:example/pages/sign_up_page.dart';
import 'package:example/pages/webview_page.dart';

class Routes {
  static const signUp = '/sign-up';
  static const signIn = '/sign-in';
  static const profile = '/profile';
  static const webview = '/webview';
}

final GoRouter router = GoRouter(
  initialLocation: Routes.signUp,
  routes: [
    GoRoute(
      path: Routes.signUp,
      builder: (context, state) => SignUpPage(),
    ),
    GoRoute(
      path: Routes.signIn,
      builder: (context, state) => SignInPage(),
    ),
    GoRoute(
      path: Routes.profile,
      builder: (context, state) => ProfilePage(),
    ),
    GoRoute(
      path: Routes.webview,
      builder: (context, state) => WebviewPage(),
    ),
  ],
);
