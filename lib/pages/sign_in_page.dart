import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:passkeys/types.dart';
import 'package:example/pages/base_page.dart';
import 'package:example/providers.dart';
import 'package:example/router.dart';

class SignInPage extends StatefulHookConsumerWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // TODO:
      //final passkeyAuth = ref.watch(relyingPartyServerProvider);

      // As soon as the view has been loaded prepare the autocompleted passkey sign in.
      // passkeyAuth
      //     .autocompletedLoginWithPasskey()
      //     .then((value) => context.go(Routes.profile))
      //     .onError(
      //   (error, stackTrace) {
      //     if (error is PasskeyAuthCancelledException) {
      //       debugPrint(
      //           'user cancelled authentication. This is not a problem. It can just be started again.');
      //       return;
      //     }

      //     debugPrint('error: $error');
      //   },
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    final error = useState<String?>(null);
    final passkeyAuth = ref.watch(relyingPartyServerProvider);

    return BasePage(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Text(
              'Login',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'Use Simulator Features/Face ID menu to authenticate.',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: TextField(
              controller: _emailController,
              autofillHints: [_getAutofillHint()],
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
                try {
                  final email = _emailController.value.text;
                  await passkeyAuth.loginWithPasskey(email: email);
                  context.go(Routes.profile);
                } catch (e) {
                  if (e is PasskeyAuthCancelledException) {
                    debugPrint(
                        'user cancelled authentication. This is not a problem. It can just be started again.');
                    return;
                  }

                  error.value = e.toString();
                  debugPrint('error: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).primaryColor,
                      content: Text('$error'),
                      duration: const Duration(seconds: 10),
                    ),
                  );
                }
              },
              child: const Text('sign in'),
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
              onPressed: () {
                ref.read(tokenProvider.notifier).set("");
                context.go(Routes.signUp);
              },
              child: const Text('I want to create a new account'),
            ),
          ),
        ],
      ),
    );
  }

  String _getAutofillHint() {
    if (kIsWeb) {
      return 'webauthn';
    } else {
      return AutofillHints.username;
    }
  }
}
