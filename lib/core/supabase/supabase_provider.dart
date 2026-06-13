// ============================================================
// NOMBRE: supabase_provider.dart
// USO: Expone el cliente global de Supabase ya inicializado.
//      Alternativa directa a supabaseClientProvider de Riverpod,
//      usada en contextos sin acceso a ref.
// ============================================================

import 'package:supabase_flutter/supabase_flutter.dart';

// Acceso global al cliente de Supabase sin necesidad de ref.
SupabaseClient get supabase => Supabase.instance.client;
