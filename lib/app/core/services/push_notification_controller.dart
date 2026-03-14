import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/user_repository.dart';

/// Controlador centralizado para manejar notificaciones Push via Firebase FCM.
class PushNotificationController extends GetxController {
  final UserRepository _userRepository;

  PushNotificationController({required UserRepository userRepository})
      : _userRepository = userRepository;

  @override
  void onInit() {
    super.onInit();
    _initPushNotifications();
  }

  Future<void> _initPushNotifications() async {
    final messaging = FirebaseMessaging.instance;

    // 1. Solicitar permisos (iOS y Android 13+)
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // 2. Obtener Token FCM actual y guardarlo en el backend
      final fcmToken = await messaging.getToken();
      if (fcmToken != null) {
        _updateTokenOnBackend(fcmToken);
      }

      // 3. Escuchar rotación de tokens
      messaging.onTokenRefresh.listen((newToken) {
        _updateTokenOnBackend(newToken);
      });

      // 4. Escuchar notificaciones en Primer Plano (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          // Mostrar un Snackbar con el estilo de la app Mango
          Get.snackbar(
            message.notification!.title ?? 'Notificación',
            message.notification!.body ?? '',
            backgroundColor: AppTheme.primaryGreen.withOpacity(0.95),
            colorText: Colors.white,
            icon: const Icon(Icons.notifications_active, color: Colors.white),
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(15),
            duration: const Duration(seconds: 4),
            onTap: (_) {
              _handleRoute(message.data);
            },
          );
        }
      });

      // 5. Escuchar notificaciones al abrir la app desde Background/Terminated
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleRoute(message.data);
      });
    }
  }

  Future<void> _updateTokenOnBackend(String token) async {
    try {
      await _userRepository.updateFcmToken(token);
    } catch (e) {
      debugPrint("Error actualizando FCM token: $e");
    }
  }

  void _handleRoute(Map<String, dynamic> data) {
    if (data.containsKey('route')) {
      final route = data['route'].toString();
      Get.toNamed(route);
    }
  }
}
