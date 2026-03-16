import 'package:supabase_flutter/supabase_flutter.dart';

class StoreRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getNearbyStores({
    required double lat,
    required double lon,
    required String state,
    required double radiusKm,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_nearby_stores',
        params: {
          'user_lat': lat,
          'user_lon': lon,
          'user_state': state,
          'radius_km': radiusKm,
        },
      );
      
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print("Error en StoreRepository.getNearbyStores: $e");
      rethrow;
    }
  }
}
