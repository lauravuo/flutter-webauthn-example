import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:passkeys/passkey_auth.dart';
import 'package:example/my_relying_party_server.dart';

final relyingPartyServer = MyRelyingPartyServer();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await relyingPartyServer.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
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
          background: Color(0xFF1953ff),
          onBackground: Colors.white,
          surface: Color(0xFF1953ff),
          onSurface: Color(0xFF1953ff),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({super.key}) : _auth = PasskeyAuth(relyingPartyServer);

  final PasskeyAuth<RpRequest, RpResponse> _auth;

  @override
  State<HomePage> createState() => _HomePageState();
}

enum PageMode { registration, login, loggedIn }

class _HomePageState extends State<HomePage> {
  final _emailController = TextEditingController();
  PageMode _pageMode = PageMode.registration;
  String? _status;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Passkeys Example/Custom Backend')),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 5,
                ),
                child: Text(
                  'Authentication Example',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 50, top: 10, bottom: 10),
                child: Text(
                  'Use Simulator Features/Face ID menu to authenticate to ${MyRelyingPartyServer.backendUrl}',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 50, top: 10, bottom: 10),
                child: Text(
                  _status ?? "",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: TextField(
                  autofillHints: const [AutofillHints.username],
                  controller: _emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'email address',
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _onclick,
                  child: Text(_buttonText()),
                ),
              ),
              const SizedBox(height: 16),
              _drawSubLine()
            ],
          ),
        ),
      ),
    );
  }

  String _buttonText() {
    if (_pageMode == PageMode.registration) {
      return 'sign up';
    } else if (_pageMode == PageMode.login) {
      return 'sign in';
    } else {
      return 'logout';
    }
  }

  Widget _drawSubLine() {
    if (_pageMode == PageMode.registration) {
      return RichText(
        text: TextSpan(
          children: [
            const TextSpan(
              text: 'Already have an account? ',
              style: TextStyle(color: Colors.black),
            ),
            TextSpan(
              text: 'Sign in',
              style: TextStyle(color: Theme.of(context).primaryColor),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  setState(() {
                    _pageMode = PageMode.login;
                  });
                },
            )
          ],
        ),
      );
    } else if (_pageMode == PageMode.login) {
      return RichText(
        text: TextSpan(
          children: [
            const TextSpan(
              text: 'First time here? ',
              style: TextStyle(color: Colors.black),
            ),
            TextSpan(
              text: 'Sign up',
              style: TextStyle(color: Theme.of(context).primaryColor),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  setState(() {
                    _pageMode = PageMode.registration;
                  });
                },
            )
          ],
        ),
      );
    } else {
      return const Text('You are currently logged in.');
    }
  }

  Future<void> _onclick() async {
    setState(() {
      _status = "";
    });

    final email = _emailController.value.text;

    try {
      if (_pageMode == PageMode.registration) {
        final response =
            await widget._auth.registerWithEmail(RpRequest(email: email));

        if (response != null) {
          setState(() {
            if (response.success) {
              _pageMode = PageMode.login;
            }
            _status = "Register success: ${response.success.toString()}";
          });
        }
      } else if (_pageMode == PageMode.login) {
        final response =
            await widget._auth.authenticateWithEmail(RpRequest(email: email));

        if (response != null) {
          setState(() {
            if (response.success) {
              _pageMode = PageMode.loggedIn;
            }
            _status = "Login success: ${response.success.toString()}";
          });
        }
      } else {
        setState(() {
          _pageMode = PageMode.login;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).primaryColor,
          content: Text(e.toString()),
          duration: const Duration(seconds: 10),
        ),
      );
    }
  }
}