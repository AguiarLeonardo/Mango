import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService extends GetxService {
  // Variables reactivas (Rx)
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;
  final RxString currentStateName = ''.obs;
  final RxString currentCityName = ''.obs;
  final RxString currentMunicipalityName = ''.obs;
  final RxBool isLoadingLocation = false.obs;
  final RxBool hasPermission = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCurrentLocation();
  }

  Future<void> fetchCurrentLocation() async {
    try {
      isLoadingLocation.value = true;
      debugPrint('🗺️ [LocationService] Iniciando proceso para obtener ubicación...');

      // 1. Verificar si el servicio de GPS está activo
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('⚠️ [LocationService] El servicio de ubicación (GPS) está deshabilitado.');
        return;
      }

      // 2. Verificar y solicitar los permisos
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('🔒 [LocationService] Estado inicial del permiso: $permission');

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('❌ [LocationService] Los permisos de ubicación fueron denegados por el usuario.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('❌ [LocationService] Los permisos están denegados permanentemente.');
        return;
      }

      // Si los permisos son concedidos
      hasPermission.value = true;
      debugPrint('✅ [LocationService] Permisos de ubicación concedidos.');

      // 3. Obtener la posición actual con alta precisión
      debugPrint('📍 [LocationService] Obteniendo coordenadas exactas...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude.value = position.latitude;
      longitude.value = position.longitude;
      debugPrint('🎯 [LocationService] Coordenadas actualizadas: Lat: ${position.latitude}, Lng: ${position.longitude}');

      // 4. Obtener dirección desde las coordenadas
      await _getAddressFromLatLng(position);

    } catch (e) {
      debugPrint('🚨 [LocationService] Excepción capturada en fetchCurrentLocation: $e');
    } finally {
      isLoadingLocation.value = false;
      debugPrint('🏁 [LocationService] Finalizó la ejecución de fetchCurrentLocation.');
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      debugPrint('🔍 [LocationService] Geocodificando coordenadas a dirección...');
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        
        // Guardar el administrativeArea (Estado/Provincia)
        currentStateName.value = place.administrativeArea ?? '';
        
        // Guardar city y municipality
        currentCityName.value = place.locality ?? '';
        currentMunicipalityName.value = place.subAdministrativeArea ?? '';

        final String locality = place.locality ?? 'Desconocida';
        final String administrativeArea = place.administrativeArea ?? 'Desconocido';
        final String subAdministrativeArea = place.subAdministrativeArea ?? 'Desconocido';

        // Bloque llamativo al final
        debugPrint('''
===================================================
🏙️ UBICACIÓN DETECTADA EXITOSAMENTE
===================================================
📍 Ciudad (locality):      $locality
🗺️ Estado/Provincia:      $administrativeArea
📍 Municipio/Subárea:      $subAdministrativeArea
📌 Coordenadas:            Lat: ${position.latitude}, Lng: ${position.longitude}
===================================================
''');
      } else {
        debugPrint('⚠️ [LocationService] No se encontraron datos para estas coordenadas.');
      }
    } catch (e) {
      debugPrint('🚨 [LocationService] Excepción capturada en _getAddressFromLatLng: $e');
    }
  }
}
