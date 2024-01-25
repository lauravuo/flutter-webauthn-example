# Flutter Example app for WebAuthn login

Utilizes [Corbado passkeys library](https://pub.dev/packages/passkeys).

## Run app

Define BACKEND_URL environment variable.

```sh
flutter run --dart-define=BACKEND_URL=$BACKEND_URL
```

## Notes

- The iOS app is configured with development team id "0000000000" and bundle identifier "com.corbado.passkeys.pub". According entry needs to be found in server configuration file `/.well-known/apple-app-site-association.
- Configuration for backend domain webcredentials are needed in [iOS project configuration](https://developer.apple.com/documentation/xcode/supporting-associated-domains). Tip: search for string "backend.example.com" and replace with your domain.
- Android prerequisities: <https://developer.android.com/training/sign-in/passkeys#prerequisites>
  - signing app
- Android authenticator selection needs values in registration
- Start android emulator from cmd line:

  ```shell
  ~/Library/Android/sdk/emulator/emulator -avd Pixel_7_API_34
  ```
