import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:example/pages/base_page.dart';

class WebviewPage extends HookConsumerWidget {
  const WebviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = useState<String?>(null);

    var controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse(const String.fromEnvironment('BACKEND_URL')));
    final navigationDelegate = NavigationDelegate(
      onProgress: (int progress) {},
      onPageStarted: (String url) {},
      onPageFinished: (String url) async {
        final newToken = await controller.runJavaScriptReturningResult(
          "localStorage.getItem('token') || ''",
        );
        token.value = newToken as String;
      },
      onWebResourceError: (WebResourceError error) {},
      onNavigationRequest: (NavigationRequest request) {
        return NavigationDecision.navigate;
      },
    );

    controller.setNavigationDelegate(navigationDelegate);

    return BasePage(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          token.value == ""
              ? WebViewWidget(controller: controller)
              : const Text("OK")
        ],
      ),
    );
  }
}
