import 'package:supabase_flutter/supabase_flutter.dart';

class StoreRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtiene negocios filtrados por estado (provincia).
  /// Regla: Miranda y Distrito Capital se agrupan juntos.
  Future<List<Map<String, dynamic>>> getStoresByState({
    required String userState,
  }) async {
    try {
      final normalizedState = userState.trim().toLowerCase();

      // Regla de negocio: Miranda y Distrito Capital se muestran juntos
      final bool isMirandaOrDC =
          normalizedState == 'miranda' ||
          normalizedState == 'distrito capital';

      dynamic query = _supabase.from('businesses').select('*');

      if (isMirandaOrDC) {
        query = query.inFilter('state', ['Miranda', 'Distrito Capital']);
      } else {
        query = query.eq('state', userState);
      }

      final response = await query.order('commercial_name', ascending: true);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print("Error en StoreRepository.getStoresByState: $e");
      rethrow;
    }
  }
}
