import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../modules/packs/packs_controller.dart';
import '../../modules/orders/orders_controller.dart';

/// Servicio global de detección de red y resguardo de pagos pendientes.
/// Se inyecta como `GetxService` permanente en main.dart.
class NetworkService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final GetStorage _storage = GetStorage();

  /// Estado reactivo de conectividad.
  final RxBool isOnline = true.obs;

  /// Key para almacenar pagos pendientes en GetStorage.
  static const String _pendingPaymentsKey = 'pending_payments';

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Snackbar ID para poder cerrarlo después.
  bool _isShowingOfflineBanner = false;
  
  bool _wasOffline = false;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _listenConnectivityChanges();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  // ─── INICIALIZACIÓN ─────────────────────────────────────────

  /// Verifica la conectividad al arrancar la app.
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateStatus(result);
    } catch (e) {
      debugPrint('[NetworkService] Error checking initial connectivity: $e');
      isOnline.value = true; // Asumimos online si hay error al verificar
    }
  }

  /// Escucha cambios de red en tiempo real.
  void _listenConnectivityChanges() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _updateStatus(results);
      },
    );
  }

  /// Actualiza el estado y dispara acciones según el cambio.
  void _updateStatus(List<ConnectivityResult> results) {
    final wasOnline = isOnline.value;
    final nowOnline = results.isNotEmpty &&
        !results.every((r) => r == ConnectivityResult.none);

    isOnline.value = nowOnline;

    if (!nowOnline && wasOnline) {
      // 📴 Conexión perdida
      _showOfflineBanner();
    } else if (nowOnline && !wasOnline) {
      // ✅ Conexión restaurada
      _hideOfflineBanner();
      _syncPendingPayments();
    }
  }

  // ─── BANNER OFFLINE ──────────────────────────────────────────

  void _showOfflineBanner() {
    if (_isShowingOfflineBanner) return;
    _isShowingOfflineBanner = true;
    _wasOffline = true;

    Get.snackbar(
      '📴 Sin conexión',
      'Estás sin conexión. Algunas funciones no estarán disponibles.',
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      isDismissible: true,
      icon: const Icon(Icons.wifi_off, color: Colors.white, size: 28),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      snackbarStatus: (status) {
        if (status == SnackbarStatus.CLOSED) {
          _isShowingOfflineBanner = false;
        }
      },
    );
  }

  void _hideOfflineBanner() {
    if (_isShowingOfflineBanner && Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
      _isShowingOfflineBanner = false;
    }

    if (_wasOffline) {
      // Notificar que la conexión volvió
      Get.snackbar(
        '¡Conexión restaurada!',
        'Estás de vuelta en línea.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.wifi, color: Colors.white, size: 28),
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
      _wasOffline = false;
    }
  }

  // ─── RESGUARDO DE PAGOS PENDIENTES ────────────────────────────

  /// Guarda un pago fallido localmente para sincronizar después.
  void savePendingPayment(Map<String, dynamic> paymentData) {
    paymentData['status'] = 'pending_sync';
    paymentData['timestamp'] = DateTime.now().toUtc().toIso8601String();

    final List<dynamic> pending = _getPendingPayments();
    pending.add(paymentData);
    _storage.write(_pendingPaymentsKey, jsonEncode(pending));

    debugPrint(
        '[NetworkService] 💾 Pago resguardado. Total pendientes: ${pending.length}');
  }

  /// Lee la lista de pagos pendientes del almacenamiento local.
  List<dynamic> _getPendingPayments() {
    final String? raw = _storage.read<String>(_pendingPaymentsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return jsonDecode(raw) as List<dynamic>;
    } catch (e) {
      debugPrint('[NetworkService] Error leyendo pagos pendientes: $e');
      return [];
    }
  }

  /// Verifica si hay pagos pendientes de sincronizar.
  bool get hasPendingPayments => _getPendingPayments().isNotEmpty;

  // ─── SINCRONIZACIÓN AUTOMÁTICA ─────────────────────────────────

  /// Se ejecuta cuando la conexión vuelve. Procesa pagos pending_sync.
  Future<void> _syncPendingPayments() async {
    final pending = _getPendingPayments();
    if (pending.isEmpty) return;

    debugPrint(
        '[NetworkService] 🔄 Sincronizando ${pending.length} pago(s) pendiente(s)...');

    final List<dynamic> stillPending = [];
    final supabase = Supabase.instance.client;

    for (final payment in pending) {
      try {
        final String userId = payment['userId'] ?? '';
        final List<dynamic> packs = payment['packs'] ?? [];
        final String paymentMethod = payment['paymentMethod'] ?? 'tarjeta';
        final String? bankName = payment['bankName'];
        final String? referenceNumber = payment['referenceNumber'];
        final String? cardLast4 = payment['cardLast4'];

        if (userId.isEmpty || packs.isEmpty) {
          debugPrint('[NetworkService] ⚠️ Pago inválido, descartando.');
          continue;
        }

        // Inyectar PacksController para reservar
        final packsController = Get.put(PacksController());

        for (final packData in packs) {
          final String packId = packData['id'] ?? '';
          final String businessId = packData['business_id'] ?? '';
          final double price = (packData['price'] as num?)?.toDouble() ?? 0.0;

          // 1. Insertar pago en Supabase
          await supabase.from('payments').insert({
            'user_id': userId,
            'pack_id': packId,
            'business_id': businessId,
            'amount': price,
            'payment_method': paymentMethod,
            'status': 'success',
            'bank_name': bankName,
            'reference_number': referenceNumber,
            'card_last4': cardLast4,
          });

          // 2. Reservar el pack
          await packsController.reservePack(packId, businessId);
        }

        // ✅ Pago sincronizado exitosamente
        debugPrint('[NetworkService] ✅ Pago sincronizado correctamente.');

        // Refrescar órdenes si el controller está activo
        if (Get.isRegistered<OrdersController>()) {
          Get.find<OrdersController>().fetchOrders();
        }
      } catch (e) {
        debugPrint('[NetworkService] ❌ Error sincronizando pago: $e');
        stillPending.add(payment); // Mantener para próximo intento
      }
    }

    // Actualizar la lista local
    if (stillPending.isEmpty) {
      _storage.remove(_pendingPaymentsKey);
    } else {
      _storage.write(_pendingPaymentsKey, jsonEncode(stillPending));
    }

    // Notificar al usuario
    final int synced = pending.length - stillPending.length;
    if (synced > 0) {
      Get.snackbar(
        '🎉 Pago procesado',
        synced == 1
            ? 'Tu pago pendiente fue procesado exitosamente.'
            : '$synced pagos pendientes fueron procesados exitosamente.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
    }

    if (stillPending.isNotEmpty) {
      debugPrint(
          '[NetworkService] ⚠️ Quedan ${stillPending.length} pago(s) sin sincronizar.');
    }
  }
}
