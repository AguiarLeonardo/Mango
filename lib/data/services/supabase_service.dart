import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pack_model.dart';


class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // --- REGISTRO DE USUARIO ---
  Future<void> registerUser({
    required String email,
    required String password,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      final AuthResponse res = await _client.auth.signUp(
        email: email,
        password: password,
      );
      final User? user = res.user;
      if (user == null) throw Exception('Error de Auth: No se creó el usuario.');

      await _client.from('profiles').insert({
        'id': user.id,
        ...profileData,
        'role': 'user',
        'created_at': DateTime.now().toIso8601String(),
      });
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // --- REGISTRO DE EMPRESA ---
  Future<void> registerBusiness({
    required String email,
    required String password,
    required File rifImageFile,
    required Map<String, dynamic> businessDataBuilder(String userId, String? rifUrl),
  }) async {
    try {
      final AuthResponse res = await _client.auth.signUp(
        email: email,
        password: password,
      );
      final User? user = res.user;
      if (user == null) throw Exception('Error creando cuenta de negocio.');

      final String filePath = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _client.storage.from('business_documents').upload(
        filePath,
        rifImageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      final String rifPath = filePath;
      final Map<String, dynamic> businessData = businessDataBuilder(user.id, rifPath);
      await _client.from('businesses').insert(businessData);
    } on AuthException catch (e) {
      throw Exception('Auth Error: ${e.message}');
    } on StorageException catch (e) {
      throw Exception('Error subiendo RIF: ${e.message}');
    } catch (e) {
      throw Exception('Error registrando empresa: $e');
    }
  }

  // --- OBTENER PACKS DISPONIBLES ---
  Future<List<PackModel>> getAvailablePacks() async {
    try {
      final List data = await _client
          .from('packs')
          .select()
          .eq('status', 'available')
          .gt('quantity_available', 0);

      return data.map<PackModel>((pack) {
        return PackModel(
          id: pack['id'],
          businessId: pack['business_id'],
          title: pack['title'],
          description: pack['description'],
          category: pack['category'],
          imageUrl: pack['image_url'],
          price: (pack['price'] as num).toDouble(),
          originalPrice: pack['original_price'] != null ? (pack['original_price'] as num).toDouble() : null,
          quantityTotal: pack['quantity_total'],
          quantityAvailable: pack['quantity_available'],
          status: pack['status'],
          pickupStart: DateTime.parse(pack['pickup_start']),
          pickupEnd: DateTime.parse(pack['pickup_end']),
        );
      }).toList();
    } catch (e) {
      throw Exception('Error obteniendo packs disponibles: $e');
    }
  }
}
