abstract class Routes {
  static const start = '/start';
  static const welcome = '/welcome';
  static const registerUser = '/register-user';
  static const registerBusiness = '/register-business';
  static const login = '/login';

  static const shell = '/shell';

  static const updatePassword = '/update-password';

  // Rutas de Packs
  static const packs = '/packs';
  static const vendorPacks =
      '/vendor-packs'; // ✅ NUEVA RUTA PARA EL PANEL DEL NEGOCIO
  static const packDetail = '/pack-detail';

  static const payment = '/payment';
  static const orders = '/orders';

  static const businessDetail = '/business-detail';
  static const search = '/search';
}
