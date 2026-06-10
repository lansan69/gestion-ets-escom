// core/supabase/supabase_provider.dart

import 'package:supabase_flutter/supabase_flutter.dart';

// Acceso global al cliente
SupabaseClient get supabase => Supabase.instance.client;
