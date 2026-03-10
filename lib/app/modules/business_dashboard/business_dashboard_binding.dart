import 'package:get/get.dart';
import 'business_dashboard_controller.dart';
import 'business_orders_controller.dart';

class BusinessDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BusinessDashboardController>(
        () => BusinessDashboardController());
    Get.lazyPut<BusinessOrdersController>(() => BusinessOrdersController());
  }
}
