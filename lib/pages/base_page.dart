import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:example/router.dart';

enum RouteLabel {
  native('Native library', Routes.signUp),
  web('Embedded webview', Routes.webview);

  const RouteLabel(this.label, this.route);
  final String label;
  final String route;
}

class BasePage extends StatelessWidget {
  const BasePage({required this.child, this.useScroll = true, super.key});

  final Widget child;
  final bool useScroll;

  @override
  Widget build(BuildContext context) {
    final currentRoute =
        GoRouter.of(context).routeInformationProvider.value.uri.toString();
    return Scaffold(
      appBar: AppBar(title: const Text('Passkeys Example/Standard Backend')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(child: Text("")),
            ...RouteLabel.values.map((route) => ListTile(
                title: Text(route.label),
                selected:
                    route.route == currentRoute || route == RouteLabel.native,
                onTap: () {
                  context.go(route.route);
                })),
          ],
        ),
      ),
      body: Center(
        child: useScroll
            ? Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: child,
                  ),
                ),
              )
            : child,
      ),
    );
  }
}
