import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        title: const Text(
          "Ayuda y Soporte",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ENCABEZADO ---
            Center(
              child: Column(
                children: [
                  Icon(Icons.support_agent, size: 80, color: AppTheme.primaryGreen.withOpacity(0.8)),
                  const SizedBox(height: 10),
                  const Text(
                    "¿En qué podemos ayudarte?",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textBlack),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Encuentra respuestas rápidas o contáctanos.",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- PREGUNTAS FRECUENTES ---
            const Text(
              "Preguntas Frecuentes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textBlack),
            ),
            const SizedBox(height: 15),
            
            _buildFAQItem(
              "¿Cómo funcionan las reservas?",
              "Cuando reservas un pack, tienes 15 minutos para completar el pago. Una vez pagado, te daremos un código para que lo muestres en el negocio al recoger tu comida.",
            ),
            _buildFAQItem(
              "¿Qué pasa si no recojo mi pack a tiempo?",
              "Los packs deben recogerse dentro del horario establecido por el local. Si no asistes, el pack se perderá y no habrá reembolso, ¡así que pon una alarma! ⏰",
            ),
            _buildFAQItem(
              "¿Puedo cancelar una reserva?",
              "Puedes cancelar un pack mientras esté en tu carrito. Sin embargo, una vez que el pago ha sido procesado y el pack confirmado, no se pueden realizar cancelaciones.",
            ),
            _buildFAQItem(
              "¿Qué contiene exactamente un pack?",
              "Para ayudar a reducir el desperdicio, los packs son una sorpresa con los excelentes excedentes del día. ¡Siempre recibirás comida deliciosa a un gran precio!",
            ),

            const SizedBox(height: 30),

            // --- SECCIÓN DE CONTACTO ---
            const Text(
              "¿Aún necesitas ayuda?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textBlack),
            ),
            const SizedBox(height: 15),

            _buildContactCard(
              icon: Icons.chat_bubble_outline,
              title: "Escríbenos por WhatsApp",
              subtitle: "Te responderemos lo más pronto posible.",
              color: Colors.green,
              onTap: () {
                // Aquí luego podemos poner un enlace real a WhatsApp
                Get.snackbar("WhatsApp", "Abriendo chat de soporte...", backgroundColor: Colors.green, colorText: Colors.white);
              },
            ),
            const SizedBox(height: 10),
            _buildContactCard(
              icon: Icons.email_outlined,
              title: "Envíanos un correo",
              subtitle: "soporte@mango.com",
              color: AppTheme.accentOrange,
              onTap: () {
                Get.snackbar("Correo", "Abriendo tu app de correos...", backgroundColor: AppTheme.accentOrange, colorText: Colors.white);
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para las preguntas
  Widget _buildFAQItem(String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppTheme.primaryGreen,
          collapsedIconColor: Colors.grey,
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: Text(
                content,
                style: TextStyle(color: Colors.grey.shade700, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para los botones de contacto
  Widget _buildContactCard({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 15, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}