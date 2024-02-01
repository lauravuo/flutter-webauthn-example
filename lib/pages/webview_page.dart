import 'package:example/router.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:example/pages/base_page.dart';
import 'package:example/providers.dart';

class WebviewPage extends HookConsumerWidget {
  const WebviewPage({this.logout = false, super.key});

  final bool logout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse(const String.fromEnvironment('BACKEND_URL')));
    final navigationDelegate = NavigationDelegate(
      onProgress: (int progress) {},
      onPageStarted: (String url) {},
      onPageFinished: (String url) async {
        final script = logout
            ? "localStorage.setItem('token', '');window.location.reload();'reload'"
            : "localStorage.getItem('token') || ''";
        final newToken = await controller.runJavaScriptReturningResult(script);
        ref.read(tokenProvider.notifier).set(newToken as String);
        if (newToken == "reload") {
          context.go(Routes.webview);
        } else if (newToken != "") {
          context.go(
              Uri(path: Routes.profile, queryParameters: {'origin': 'webview'})
                  .toString());
        }
      },
      onWebResourceError: (WebResourceError error) {},
      onNavigationRequest: (NavigationRequest request) {
        return NavigationDecision.navigate;
      },
    );

    controller.setNavigationDelegate(navigationDelegate);

    return BasePage(
      useScroll: false,
      child: WebViewWidget(controller: controller),
    );
  }
}
