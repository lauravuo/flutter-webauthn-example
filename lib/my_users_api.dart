import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:corbado_frontend_api_client/frontendapi/lib/api.dart';
import 'package:passkeys/relying_party_server/corbado/types/authentication.dart';
import 'package:passkeys/relying_party_server/corbado/types/registration.dart';

class MyUsersApi {
  MyUsersApi([ApiClient? apiClient])
      : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  String? sessionCookie;

  Future<void> setSessionCookie(Response response) async {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      sessionCookie = (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }

  /// Returns the decoded body as UTF-8 if the given headers indicate an 'application/json'
  /// content type. Otherwise, returns the decoded body as decoded by dart:http package.
  Future<String> _decodeBodyBytes(Response response) async {
    final contentType = response.headers['content-type'];
    return contentType != null &&
            contentType.toLowerCase().startsWith('application/json')
        ? response.bodyBytes.isEmpty
            ? ''
            : utf8.decode(response.bodyBytes)
        : response.body;
  }

  /// Performs passkey login finish
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [PassKeyFinishReq] passKeyFinishReq (required):
  Future<Response> passKeyLoginFinishWithHttpInfo(
    CorbadoAuthenticationCompleteRequest signedChallenge,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/assertion/result';

    // ignore: prefer_final_locals
    Object? postBody = signedChallenge;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{'Cookie': sessionCookie ?? ''};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];

    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Performs passkey login start
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [PassKeyLoginStartReq] passKeyLoginStartReq (required):
  Future<Response> passKeyLoginStartWithHttpInfo(
    PassKeyLoginStartReq passKeyLoginStartReq,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/assertion/options';

    // ignore: prefer_final_locals
    Object? postBody = passKeyLoginStartReq;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];

    final res = await apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
    if (res.statusCode == 200) {
      await setSessionCookie(res);
    }
    return res;
  }

  /// Performs passkey login start
  ///
  /// Parameters:
  ///
  /// * [PassKeyLoginStartReq] passKeyLoginStartReq (required):
  Future<PassKeyStartRsp?> passKeyLoginStart(
    PassKeyLoginStartReq passKeyLoginStartReq,
  ) async {
    final response = await passKeyLoginStartWithHttpInfo(
      passKeyLoginStartReq,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty &&
        response.statusCode != HttpStatus.noContent) {
      final data = PassKeyStartRspAllOfData(challenge: response.body);

      return PassKeyStartRsp(
          httpStatusCode: 200,
          message: '',
          requestData: RequestData(link: '', requestID: ''),
          runtime: 1,
          data: data);
    }
    return null;
  }

  /// Performs passkey register finish
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [PassKeyFinishReq] passKeyFinishReq (required):
  Future<Response> passKeyRegisterFinishWithHttpInfo(
    CorbadoRegisterSignedChallengeRequest signedChallenge,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/attestation/result';

    // ignore: prefer_final_locals
    Object? postBody = signedChallenge;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{'Cookie': sessionCookie ?? ''};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];

    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Performs passkey register finish
  ///
  /// Parameters:
  ///
  /// * [PassKeyFinishReq] passKeyFinishReq (required):
  Future<PassKeyRegisterFinishRsp?> passKeyRegisterFinish(
    CorbadoRegisterSignedChallengeRequest signedChallenge,
  ) async {
    final response = await passKeyRegisterFinishWithHttpInfo(
      signedChallenge,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty &&
        response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(
        await _decodeBodyBytes(response),
        'PassKeyRegisterFinishRsp',
      ) as PassKeyRegisterFinishRsp;
    }
    return null;
  }

  /// Performs passkey register start
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [PassKeyRegisterStartReq] passKeyRegisterStartReq (required):
  Future<Response> passKeyRegisterStartWithHttpInfo(
    PassKeyRegisterStartReq passKeyRegisterStartReq,
  ) async {
    // ignore: prefer_const_declarations
    final path = r'/attestation/options';

    // ignore: prefer_final_locals
    Object? postBody = passKeyRegisterStartReq;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];

    final res = await apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
    if (res.statusCode == 200) {
      await setSessionCookie(res);
    }

    return res;
  }

  /// Performs passkey register start
  ///
  /// Parameters:
  ///
  /// * [PassKeyRegisterStartReq] passKeyRegisterStartReq (required):
  Future<PassKeyStartRsp?> passKeyRegisterStart(
    PassKeyRegisterStartReq passKeyRegisterStartReq,
  ) async {
    final response = await passKeyRegisterStartWithHttpInfo(
      passKeyRegisterStartReq,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty &&
        response.statusCode != HttpStatus.noContent) {
      final data = PassKeyStartRspAllOfData(challenge: response.body);

      return PassKeyStartRsp(
          httpStatusCode: 200,
          message: '',
          requestData: RequestData(link: '', requestID: ''),
          runtime: 1,
          data: data);
    }
    return null;
  }
}
