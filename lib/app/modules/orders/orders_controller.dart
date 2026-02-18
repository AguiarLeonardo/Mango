import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrdersController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // --- VARIABLES EXACTAS QUE NECESITA TU PANTALLA ---
  var isLoading = true.obs;
  
  // 1. Aquí definimos "ordersList" para que la pantalla la encuentre
  var ordersList = <Map<String, dynamic>>[].obs; 
  
  // 2. Aquí definimos "isBusinessMode" para que la pantalla sepa el rol
  var isBusinessMode = false.obs; 

  @override
  void onInit() {
    super.onInit();
    checkUserRole();
    fetchOrders();
  }

  // Verificar si es empresa
  Future<void> checkUserRole() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      // Buscamos si el ID está en la tabla businesses
      final data = await _supabase
          .from('businesses')
          .select('id')
          .eq('id', userId)
          .maybeSingle();
          
      // Si data no es null, es una empresa. Actualizamos la variable.
      isBusinessMode.value = (data != null);
      
      // Volvemos a cargar las órdenes ahora que sabemos el rol correcto
      fetchOrders(); 
    }
  }

  // Cargar las órdenes
  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      dynamic response;

      if (isBusinessMode.value) {
        // --- MODO EMPRESA (Ver Ventas) ---
        response = await _supabase
            .from('orders')
            .select('*, packs(title, image_url, price)') 
            .eq('business_id', userId) 
            .order('created_at', ascending: false);
      } else {
        // --- MODO USUARIO (Ver Compras) ---
        // Intentamos traer el pack y el negocio
        response = await _supabase
            .from('orders')
            .select('*, packs(title, image_url, businesses(commercial_name))') 
            .eq('user_id', userId)
            .order('created_at', ascending: false);
      }

      if (response != null) {
        ordersList.value = List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      print("Error cargando órdenes: $e");
    } finally {
      isLoading.value = false;
    }
  }
}