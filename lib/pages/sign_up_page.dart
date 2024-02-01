import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:example/pages/base_page.dart';
import 'package:example/providers.dart';
import 'package:example/router.dart';

class SignUpPage extends HookConsumerWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final error = useState<String?>(null);
    final passkeyAuth = ref.watch(relyingPartyServerProvider);

    return BasePage(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Text(
              'Register new account',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'Sign up using your biometrics like fingerprint or face.',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'email address',
              ),
            ),
          ),
          if (error.value != null)
            Text(
              error.value!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            )
          else
            Container(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                final email = emailController.value.text;
                try {
                  await passkeyAuth.signUpWithPasskey(email: email);
                  context.go(Routes.signIn);
                } catch (e) {
                  error.value = e.toString();
                }
              },
              child: const Text('sign up'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                side:
                    BorderSide(width: 2, color: Theme.of(context).primaryColor),
              ),
              onPressed: () => context.go(Routes.signIn),
              child: const Text('I already have an account'),
            ),
          ),
        ],
      ),
    );
  }
}
