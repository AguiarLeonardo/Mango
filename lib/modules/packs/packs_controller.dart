import 'package:get/get.dart';
import '../../data/models/pack_model.dart';

class PacksController extends GetxController {
  final packs = <PackModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMockPacks();
  }

  void loadMockPacks() {
    packs.value = [
      PackModel(
        id: '1',
        title: 'Pack Sorpresa Panadería',
        description: 'Pan del día y dulces variados',
        price: 3.5,
        businessName: 'Panadería Caracas',
        businessAddress: 'Av. Principal',
        state: 'Distrito Capital',
        city: 'Caracas',
        municipality: 'Libertador',
      ),
      PackModel(
        id: '2',
        title: 'Pack Dulce',
        description: 'Postres del día',
        price: 4.0,
        businessName: 'Dulcería Miranda',
        businessAddress: 'Centro',
        state: 'Miranda',
        city: 'Los Teques',
        municipality: 'Guaicaipuro',
      ),
    ];
  }
}
