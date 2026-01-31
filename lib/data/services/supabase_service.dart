import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // --- REGISTRO DE USUARIO (Ya lo tenías) ---
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

  // --- REGISTRO DE EMPRESA (Nuevo) ---
  Future<void> registerBusiness({
    required String email,
    required String password,
    required File rifImageFile, // Archivo físico de la imagen
    required Map<String, dynamic> businessDataBuilder(String userId, String? rifUrl),
  }) async {
    try {
      // 1. Crear Auth User
      final AuthResponse res = await _client.auth.signUp(
        email: email,
        password: password,
      );
      final User? user = res.user;

      if (user == null) throw Exception('Error creando cuenta de negocio.');

      // 2. Subir imagen del RIF al Storage
      // Nombre único para el archivo: ID_usuario + timestamp
      final String filePath = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      await _client.storage.from('business_documents').upload(
        filePath,
        rifImageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      // 3. Obtener la ruta pública (o privada si usas signedUrls, pero por ahora usaremos getPublicUrl para simplificar, 
      // aunque lo ideal para docs legales es signedUrl. Si el bucket es privado, esto devolverá una ruta que requiere token).
      // NOTA: Para documentos sensibles, guardamos el PATH, no la URL pública.
      final String rifPath = filePath; 

      // 4. Guardar datos en la tabla 'businesses'
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
}