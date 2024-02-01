import 'dart:async';
import 'dart:convert';

import 'package:corbado_auth/corbado_auth.dart';
import 'package:corbado_frontend_api_client/frontendapi/lib/api.dart';
import 'package:passkeys/authenticator.dart';
import 'package:example/my_users_api.dart';

class AuthResponse {
  AuthResponse({
    required this.token,
  });

  final String token;
}

class CustomAuth {
  /// Constructor
  CustomAuth() : passkeyAuthenticator = PasskeyAuthenticator();

  final PasskeyAuthenticator passkeyAuthenticator;

  late final ApiClient _client;
  // Note: this server needs to be configured as associated domain for webcredentials
  // in iOS project configuration
  static const String backendUrl = String.fromEnvironment('BACKEND_URL');
  late final MyUsersApi myUsersApi;

  Future<void> init() async {
    _client = await buildClient();
    myUsersApi = MyUsersApi(_client);
  }

  // Builds an API client to interact with the FIDO2 server API.
  Future<ApiClient> buildClient() async {
    print("API client " + backendUrl);
    final client = ApiClient(basePath: backendUrl);

    return client;
  }

  /// Signs up a user by registering a new passkey (using the passkeys package).
  Future<AuthResponse> signUpWithPasskey({
    required String email,
    String? fullName,
  }) async {
    try {
      final result = await myUsersApi.passKeyRegisterStart(
        PassKeyRegisterStartReq(
          username: email,
          fullName: fullName ?? email,
        ),
      );

      if (result == null) {
        throw UnexpectedBackendException(
          'passKeyRegisterStart',
          'result was null',
        );
      }

      // reformat json from standard FIDO2 backend
      final json = jsonDecode(result.data.challenge) as Map<String, dynamic>;
      // TODO: in android these should be null if no exist?
      // valid values are now compulsory, iOS accepts empty strings
      json['authenticatorSelection']['residentKey'] = 'required';
      json['authenticatorSelection']['authenticatorAttachment'] = 'platform';
      json['publicKey'] = json;

      final res1 = StartRegisterResponse.fromJson(json);
      final platformReq = res1.toPlatformType();
      final platformResponse = await passkeyAuthenticator.register(platformReq);
      final req2 =
          FinishRegisterRequest.fromRegisterCompleteRequest(platformResponse);

      print(platformResponse.clientDataJSON);

      final finishRes = await myUsersApi.passKeyRegisterFinishWithHttpInfo(
        req2,
      );

      print("Complete register: ${finishRes.statusCode}, ${finishRes.body}");
      if (finishRes.statusCode != 200) {
        throw ExceptionFactory.fromBackendMessage(
          'passKeyRegisterStart',
          finishRes.body,
        );
      }

      // Server returns no tokens on register
      return AuthResponse(token: "");
    } on ApiException catch (e) {
      throw ExceptionFactory.fromBackendMessage(
        'passKeyRegisterStart',
        e.message ?? '',
      );
    }
  }

  /// Signs in a user relying on a passkey.
  /// This is an alternative to autocompletedSignInWithPasskey.
  /// It should be called when the user explicitly wants to type in a username.
  Future<AuthResponse> loginWithPasskey({required String email}) async {
    return _loginWithPasskey(email: email, conditional: false);
  }

  Future<AuthResponse> _loginWithPasskey({
    required bool conditional,
    String email = '',
  }) async {
    try {
      final result = await myUsersApi.passKeyLoginStart(
        PassKeyLoginStartReq(username: email),
      );

      if (result == null) {
        throw Exception(
          'An unknown error occurred during the Corbado API call',
        );
      }

      if (result.data.challenge.isEmpty) {
        throw NoPasskeyForDeviceException();
      }

      final json = jsonDecode(result.data.challenge) as Map<String, dynamic>;
      json['publicKey'] = json;

      final res1 = StartLoginResponse.fromJson(json);
      final platformReq = res1.toPlatformType(conditional: conditional);
      final platformResponse =
          await passkeyAuthenticator.authenticate(platformReq);
      final req2 = FinishLoginRequest.fromPlatformType(platformResponse);
      final res2 = await myUsersApi.passKeyLoginFinishWithHttpInfo(
        req2,
      );

      print("Complete authenticate: ${res2.statusCode}, ${res2.body}");
      if (res2.statusCode != 200) {
        throw ExceptionFactory.fromBackendMessage(
          'passKeyRegisterStart',
          res2.body,
        );
      }

      final tokenResult =
          jsonDecode(utf8.decode(res2.bodyBytes)) as Map<String, dynamic>;

      return AuthResponse(token: tokenResult["token"]);
    } on ApiException catch (e) {
      throw ExceptionFactory.fromBackendMessage(
        'passKeyAuthenticateStart',
        e.message ?? '',
      );
    }
  }
}
