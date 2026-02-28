import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PackDetailController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  var isLoadingReviews = true.obs;
  var reviewsList = <Map<String, dynamic>>[].obs;
  var averageRating = 0.0.obs;
  var totalReviews = 0.obs;

  void fetchReviews(String packId) async {
    try {
      isLoadingReviews.value = true;
      
      // Buscamos las reseñas de este pack en específico
      final response = await _supabase
          .from('ratings')
          .select('rating, comment, created_at')
          .eq('pack_id', packId)
          .order('created_at', ascending: false);

      if (response != null) {
        final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);
        
        reviewsList.value = data;
        totalReviews.value = data.length;

        // Calculamos el promedio matemático de las estrellas
        if (data.isNotEmpty) {
          double sum = 0;
          for (var review in data) {
            sum += (review['rating'] as num).toDouble();
          }
          averageRating.value = sum / data.length;
        } else {
          averageRating.value = 0.0;
        }
      }
    } catch (e) {
      print("Error cargando reseñas: $e");
    } finally {
      isLoadingReviews.value = false;
    }
  }
}