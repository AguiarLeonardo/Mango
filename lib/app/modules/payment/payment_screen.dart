import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'payment_controller.dart';
import '../../core/theme/app_theme.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaymentController());

    return Scaffold(
      // Usamos el fondo crema global de Mango
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: const Text(
          "Finalizar Compra",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textBlack,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textBlack),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- RESUMEN DE COMPRA (Estilo Ticket) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "Total a pagar",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${controller.price.toStringAsFixed(2)} Bs",
                    style: const TextStyle(
                      fontSize: 32,
                      color: AppTheme.textBlack,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Divider(height: 30),
                  Text(
                    controller.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textBlack,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),

            const Text(
              "Método de pago",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textBlack,
              ),
            ),
            const SizedBox(height: 15),

            // --- SELECTOR DE MÉTODOS ---
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMethodSelector(
                    controller,
                    'tarjeta',
                    Icons.credit_card,
                    'Tarjeta',
                  ),
                  _buildMethodSelector(
                    controller,
                    'pagomovil',
                    Icons.phone_android,
                    'Pago Móvil',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),

            // --- FORMULARIOS DINÁMICOS ---
            Obx(() {
              if (controller.selectedMethod.value == 'tarjeta') {
                return _buildCreditCardForm(controller);
              } else {
                return _buildPagoMovilForm(controller);
              }
            }),

            const SizedBox(height: 40),

            // --- BOTÓN DE PAGO PRINCIPAL ---
            Obx(() {
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentOrange.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.processPayment,
                  // Aquí forzamos el color Naranja para el botón más importante de la app (CTA crítico)
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          "CONFIRMAR PAGO",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // --- WIDGET PARA LOS BOTONES REDONDOS DE SELECCIÓN ---
  Widget _buildMethodSelector(
    PaymentController controller,
    String value,
    IconData icon,
    String label,
  ) {
    final isSelected = controller.selectedMethod.value == value;
    return GestureDetector(
      onTap: () => controller.selectedMethod.value = value,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentOrange : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.accentOrange : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.accentOrange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade500,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET MOLDE PARA LAS CAJAS DE TEXTO LINDAS ---
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryGreen),
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        hintStyle: TextStyle(color: Colors.grey.shade400),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppTheme.accentOrange, width: 2),
        ),
      ),
    );
  }

  // --- WIDGET MOLDE PARA LA LISTA DESPLEGABLE ---
  Widget _buildCustomDropdown({
    required String hint,
    required IconData icon,
    required RxString selectedValue,
    required List<String> items,
  }) {
    return Obx(
      () => DropdownButtonFormField<String>(
        initialValue: selectedValue.value.isEmpty ? null : selectedValue.value,
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: AppTheme.primaryGreen,
        ),
        decoration: InputDecoration(
          labelText: "Banco de Origen",
          hintText: hint,
          prefixIcon: Icon(icon, color: AppTheme.primaryGreen),
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: AppTheme.accentOrange,
              width: 2,
            ),
          ),
        ),
        items: items.map((String bank) {
          return DropdownMenuItem<String>(
            value: bank,
            child: Text(
              bank,
              style: const TextStyle(fontSize: 15, color: AppTheme.textBlack),
            ),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) selectedValue.value = newValue;
        },
      ),
    );
  }

  // --- FORMULARIO TARJETA ---
  Widget _buildCreditCardForm(PaymentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Datos de la Tarjeta",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textBlack,
          ),
        ),
        const SizedBox(height: 15),

        _buildCustomTextField(
          controller: controller.cardNumberController,
          label: "Número de Tarjeta",
          hint: "0000 0000 0000 0000",
          icon: Icons.credit_card,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
            CardNumberFormatter(),
          ],
        ),

        const SizedBox(height: 15),

        Row(
          children: [
            Expanded(
              child: _buildCustomTextField(
                controller: controller.cardExpiryController,
                label: "Vencimiento",
                hint: "MM/AA",
                icon: Icons.calendar_month,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  CardMonthYearFormatter(),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildCustomTextField(
                controller: controller.cardCvvController,
                label: "CVV",
                hint: "***",
                icon: Icons.security,
                obscureText: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- FORMULARIO PAGO MÓVIL ---
  Widget _buildPagoMovilForm(PaymentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Datos para Transferir",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textBlack,
          ),
        ),
        const SizedBox(height: 15),

        // Tarjeta con los datos del negocio
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildDataRow("Banco", "0134 - Banesco"),
              const Divider(height: 20),
              _buildDataRow("Teléfono", "0412-1234567"),
              const Divider(height: 20),
              _buildDataRow("RIF", "J-50001234-5"),
            ],
          ),
        ),
        const SizedBox(height: 25),

        const Text(
          "Confirmación",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textBlack,
          ),
        ),
        const SizedBox(height: 15),

        // --- NUEVA LISTA DESPLEGABLE DE BANCOS ---
        _buildCustomDropdown(
          hint: "Selecciona tu banco",
          icon: Icons.account_balance,
          selectedValue: controller.selectedBank,
          items: controller.bankList,
        ),

        const SizedBox(height: 15),

        // Caja de referencia
        _buildCustomTextField(
          controller: controller.referenceController,
          label: "Número de Referencia",
          hint: "Últimos dígitos",
          icon: Icons.numbers,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(8),
          ],
        ),
      ],
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppTheme.textBlack,
          ),
        ),
      ],
    );
  }
}

// ==========================================
// CLASES FORMATEADORAS DE TEXTO PERSONALIZADAS
// ==========================================

class CardMonthYearFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != text.length && i == 1) {
        buffer.write('/');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
