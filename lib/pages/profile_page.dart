import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:example/pages/base_page.dart';
import 'package:example/router.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({this.origin = "signin", super.key});

  final String origin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BasePage(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              'Welcome',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              '',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text(
              'You are currently logged in. You have a JWT token that you can use to make calls to your backend.',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  side: BorderSide(
                      width: 2, color: Theme.of(context).primaryColor)),
              onPressed: () {
                //context.go(Routes.signUp);
                context.go(Uri(
                    path: origin == "webview" ? Routes.webview : Routes.signUp,
                    queryParameters: {'logout': 'true'}).toString());
              },
              child: const Text('sign out'),
            ),
          ),
        ],
      ),
    );
  }
}
