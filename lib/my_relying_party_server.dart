import 'dart:convert';

import 'package:corbado_frontend_api_client/frontendapi/lib/api.dart';
import 'package:passkeys/relying_party_server/corbado/types/authentication.dart';
import 'package:passkeys/relying_party_server/corbado/types/exceptions.dart';
import 'package:passkeys/relying_party_server/corbado/types/registration.dart';
import 'package:passkeys/relying_party_server/corbado/types/shared.dart';
import 'package:passkeys/relying_party_server/relying_party_server.dart';
import 'package:passkeys/relying_party_server/types/authentication.dart';
import 'package:passkeys/relying_party_server/types/registration.dart';
import 'package:example/my_users_api.dart';

class RpRequest {
  const RpRequest({required this.email});

  final String email;
}

class RpResponse {
  const RpResponse({required this.success});

  final bool success;
}

class MyRelyingPartyServer extends RelyingPartyServer<RpRequest, RpResponse> {
  late final ApiClient _client;
  // Note: this server needs to be configured as associated domain for webcredentials
  // in iOS project configuration
  static const String backendUrl = String.fromEnvironment('BACKEND_URL');
  late final MyUsersApi myUsersApi;

  Future<void> init() async {
    _client = await buildClient();
    myUsersApi = MyUsersApi(_client);
  }

  // Builds an API client to interact with the Corbado frontend API.
  // Depending on the platform different headers will be set.
  Future<ApiClient> buildClient() async {
    final client = ApiClient(basePath: backendUrl)
      ..addDefaultHeader('Origin', backendUrl);

    return client;
  }

  @override
  Future<RpResponse> completeAuthenticate(
      AuthenticationCompleteRequest request) async {
    // similar in its structure to completeAuthenticate
    try {
      await doCompleteAuthenticate(request);
      return const RpResponse(success: true);
    } catch (e) {
      return const RpResponse(success: false);
    }
  }

  @override
  Future<RpResponse> completeRegister(
      RegistrationCompleteRequest request) async {
    try {
      await doCompleteRegister(request);
      return const RpResponse(success: true);
    } catch (e) {
      return const RpResponse(success: false);
    }
  }

  @override
  Future<AuthenticationInitResponse> initAuthenticate(RpRequest request) {
    return doInitAuthenticate(AuthRequest(request.email));
  }

  @override
  Future<AuthenticationInitResponse> initAuthenticateWithAutoComplete(
      RpRequest request) {
    // similar in its structure to completeAuthenticate
    throw UnimplementedError();
  }

  @override
  Future<RegistrationInitResponse> initRegister(RpRequest req) {
    final request = AuthRequest(req.email);
    return doInitRegister(request);
  }

  Future<RegistrationInitResponse> doInitRegister(AuthRequest request) async {
    try {
      final result = await myUsersApi.passKeyRegisterStart(
        PassKeyRegisterStartReq(
          username: request.email,
          fullName: request.username ?? request.email,
        ),
      );

      if (result == null) {
        throw UnexpectedBackendException(
          'passKeyRegisterStart',
          'result was null',
        );
      }

      // reformat json suitable for our backend
      final json = jsonDecode(result.data.challenge) as Map<String, dynamic>;
      json['authenticatorSelection']['residentKey'] = '';
      json['authenticatorSelection']['authenticatorAttachment'] = '';
      json['publicKey'] = json;

      final typed = CorbadoRegisterChallenge.fromJson(json);
      return typed.toRegisterInitResponse();
    } on ApiException catch (e) {
      throw ExceptionFactory.fromBackendMessage(
        'passKeyRegisterStart',
        e.message ?? '',
      );
    }
  }

  Future<AuthResponse> doCompleteRegister(
    RegistrationCompleteRequest request,
  ) async {
    try {
      final signedChallenge =
          CorbadoRegisterSignedChallengeRequest.fromRegisterCompleteRequest(
        request,
      );
      final result = await myUsersApi.passKeyRegisterFinishWithHttpInfo(
        signedChallenge,
      );

      print("Complete register: ${result.statusCode}, ${result.body}");

      // Our server returns no tokens on register
      return AuthResponse(token: "", refreshToken: "");
    } on ApiException catch (e) {
      throw ExceptionFactory.fromBackendMessage(
        'passKeyRegisterFinish',
        e.message ?? '',
      );
    }
  }

  Future<AuthenticationInitResponse> doInitAuthenticate(
    AuthRequest request,
  ) async {
    try {
      final result = await myUsersApi.passKeyLoginStart(
        PassKeyLoginStartReq(username: request.email),
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

      final typed = CorbadoAuthenticationInitResponse.fromJson(json);
      return typed.toAuthenticationInitResponse();
    } on ApiException catch (e) {
      throw ExceptionFactory.fromBackendMessage(
        'passKeyAuthenticateStart',
        e.message ?? '',
      );
    }
  }

  Future<AuthResponse> doCompleteAuthenticate(
    AuthenticationCompleteRequest request,
  ) async {
    try {
      final signedChallenge = CorbadoAuthenticationCompleteRequest
          .fromAuthenticationCompleteRequest(
        request,
      );

      final response = await myUsersApi.passKeyLoginFinishWithHttpInfo(
        signedChallenge,
      );

      print("Complete authenticate: ${response.statusCode}, ${response.body}");

      final result =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      return AuthResponse(token: result["token"], refreshToken: "");
    } on ApiException catch (e) {
      throw ExceptionFactory.fromBackendMessage(
        'passKeyAuthenticateFinish',
        e.message ?? '',
      );
    }
  }
}

// Define all fields in this class that your relying party server expects during the initial sign up and login call
// At most, this must contain some kind of user identifier (e.g. an email address).
class Request {
  const Request({required this.email});

  final String email;
}

// Define all data in this class that can be returned by your relying party server on a successful authentication.
// Usually this is some kind of token (e.g. a JWT token that encodes user data).
class Response {
  const Response({required this.idToken});

  final String idToken;
}
