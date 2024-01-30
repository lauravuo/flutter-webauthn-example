import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:example/custom_auth.dart';

// Relying party server provider.
final relyingPartyServerProvider = Provider<CustomAuth>(
  (ref) => throw UnimplementedError('no instance of CustomAuth'),
);
