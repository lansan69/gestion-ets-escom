// ============================================================
// NOMBRE: router_refresh_stream.dart
// USO: Adapta un Stream (p.ej. el stream de sesión de Supabase)
//      a un ChangeNotifier para que GoRouter revalúe el redirect
//      cuando cambia el estado de autenticación.
// ============================================================
import 'dart:async';
import 'package:flutter/foundation.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
