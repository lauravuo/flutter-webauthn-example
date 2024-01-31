import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:example/router.dart';

enum RouteLabel {
  native('Native WebAuthn', Routes.signUp),
  web('Embedded Webview', Routes.webview);

  const RouteLabel(this.label, this.route);
  final String label;
  final String route;
}

class BasePage extends StatelessWidget {
  const BasePage({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Passkeys Example/Standard Backend')),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              DropdownMenu<RouteLabel>(
                requestFocusOnTap: true,
                label: const Text('Mode'),
                onSelected: (RouteLabel? route) {
                  if (route != null) {
                    context.go(route.route);
                  }
                },
                dropdownMenuEntries: RouteLabel.values
                    .map<DropdownMenuEntry<RouteLabel>>((RouteLabel route) {
                  return DropdownMenuEntry<RouteLabel>(
                    value: route,
                    label: route.label,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: child,
              )
            ],
          )),
        ),
      ),
    );
  }
}
