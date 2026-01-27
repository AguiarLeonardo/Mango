import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // --- Variables existentes ---
  bool _acceptedTerms = false;
  String _selectedPhoneCode = '0412';
  final List<String> _phoneCodes = ['0412', '0424', '0416', '0414', '0426'];
  String _selectedIdType = 'V-';
  final List<String> _idTypes = ['V-', 'E-'];
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;

  // --- NUEVO: Controladores y errores para contraseñas ---
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _passwordError;
  String? _confirmPasswordError;

  // --- NUEVO: Variables para Geografía (Estado, Ciudad, Municipio) ---
  String? _selectedState;
  String? _selectedCity;
  String? _selectedMunicipality;

  List<Map<String, dynamic>> _availableCities = [];
  List<String> _availableMunicipalities = [];

  // --- DATA DE VENEZUELA ---
  final List<Map<String, dynamic>> _venezuelaData = [
    {
      "estado": "Distrito Capital",
      "ciudades": [
        { "nombre": "Caracas", "municipios": ["Libertador"] }
      ]
    },
    {
      "estado": "Miranda",
      "ciudades": [
        { "nombre": "Caracas (Área Metro)", "municipios": ["Baruta", "Chacao", "El Hatillo", "Sucre"] },
        { "nombre": "Los Teques", "municipios": ["Guaicaipuro"] },
        { "nombre": "Guarenas / Guatire", "municipios": ["Plaza", "Zamora"] },
        { "nombre": "Valles del Tuy", "municipios": ["Cristóbal Rojas", "Urdaneta", "Lander"] }
      ]
    },
    {
      "estado": "Zulia",
      "ciudades": [
        { "nombre": "Maracaibo", "municipios": ["Maracaibo"] },
        { "nombre": "San Francisco", "municipios": ["San Francisco"] },
        { "nombre": "Cabimas", "municipios": ["Cabimas"] }
      ]
    },
    {
      "estado": "Carabobo",
      "ciudades": [
        { "nombre": "Valencia", "municipios": ["Valencia", "Naguanagua", "San Diego", "Los Guayos"] },
        { "nombre": "Puerto Cabello", "municipios": ["Puerto Cabello"] }
      ]
    },
    {
      "estado": "Lara",
      "ciudades": [
        { "nombre": "Barquisimeto", "municipios": ["Iribarren"] },
        { "nombre": "Cabudare", "municipios": ["Palavecino"] }
      ]
    },
    {
      "estado": "Aragua",
      "ciudades": [
        { "nombre": "Maracay", "municipios": ["Girardot", "Mario Briceño Iragorry"] },
        { "nombre": "La Victoria", "municipios": ["José Félix Ribas"] }
      ]
    },
    {
      "estado": "Anzoátegui",
      "ciudades": [
        { "nombre": "Barcelona", "municipios": ["Simón Bolívar"] },
        { "nombre": "Puerto La Cruz", "municipios": ["Juan Antonio Sotillo"] },
        { "nombre": "Lechería", "municipios": ["Diego Bautista Urbaneja"] }
      ]
    },
    {
       "estado": "La Guaira",
       "ciudades": [
         { "nombre": "La Guaira", "municipios": ["Vargas"] }
       ]
    }
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateEmail(String value) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (value.isNotEmpty && !emailRegex.hasMatch(value)) {
      setState(() => _emailError = "Ese correo no es valido");
    } else {
      setState(() => _emailError = null);
    }
  }

  // --- NUEVO: Función para validar contraseñas ---
  void _validatePasswords() {
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;

      List<String> unmetRequirements = [];

      // Solo validamos si el usuario ha comenzado a escribir.
      if (password.isNotEmpty) {
          if (password.length < 8) {
              unmetRequirements.add("• Mínimo 8 caracteres");
          }
          if (!password.contains(RegExp(r'[A-Z]'))) {
              unmetRequirements.add("• Al menos una mayúscula (A-Z)");
          }
          if (!password.contains(RegExp(r'[a-z]'))) {
              unmetRequirements.add("• Al menos una minúscula (a-z)");
          }
          if (!password.contains(RegExp(r'[0-9]'))) {
              unmetRequirements.add("• Al menos un número (0-9)");
          }
      }

      setState(() {
          // 1. Actualizar error de fortaleza de la contraseña
          _passwordError = unmetRequirements.isNotEmpty ? "Debe incluir:\n${unmetRequirements.join('\n')}" : null;

          // 2. Actualizar error de coincidencia de contraseñas
          _confirmPasswordError = (confirmPassword.isNotEmpty && password != confirmPassword) ? "Las contraseñas no coinciden" : null;
      });
  }

  @override
  Widget build(BuildContext context) {
    // Ordenamos la lista de estados alfabéticamente
    _venezuelaData.sort((a, b) => (a['estado'] as String).compareTo(b['estado'] as String));

    return Scaffold(
      backgroundColor: AppColors.darkOlive,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              // Tarjeta principal del formulario
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: AppColors.white.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Título
                      const Text(
                        "REGISTRO",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkOlive,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- SECCIÓN: Datos Personales ---
                      _buildTextField(label: "Nombres", icon: Icons.person_outline),
                      const SizedBox(height: 15),
                      _buildTextField(label: "Apellidos", icon: Icons.person_outline),
                      const SizedBox(height: 15),
                      _buildTextField(
                        label: "Correo Electrónico",
                        icon: Icons.email_outlined,
                        inputType: TextInputType.emailAddress,
                        controller: _emailController,
                        onChanged: _validateEmail,
                        errorText: _emailError,
                      ),
                      const SizedBox(height: 15),
                      
                      // --- Campo de Teléfono ---
                      Row(
                        children: [
                          Container(
                            width: 110,
                            decoration: BoxDecoration(
                              color: AppColors.sageGreen.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedPhoneCode,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              icon: const Icon(Icons.arrow_drop_down, color: AppColors.darkOlive),
                              style: const TextStyle(color: AppColors.darkOlive, fontSize: 16),
                              dropdownColor: Colors.white,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedPhoneCode = newValue!;
                                });
                              },
                              items: _phoneCodes.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              label: "Número",
                              icon: Icons.phone_outlined,
                              inputType: TextInputType.number,
                              maxLength: 7,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      
                      // --- Campo de Cédula ---
                      Row(
                        children: [
                          Container(
                            width: 90,
                            decoration: BoxDecoration(
                              color: AppColors.sageGreen.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedIdType,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              icon: const Icon(Icons.arrow_drop_down, color: AppColors.darkOlive),
                              style: const TextStyle(color: AppColors.darkOlive, fontSize: 16),
                              dropdownColor: Colors.white,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedIdType = newValue!;
                                });
                              },
                              items: _idTypes.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              label: "Cédula",
                              icon: Icons.badge_outlined,
                              inputType: TextInputType.number,
                              maxLength: 8,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(label: "Dirección (Calle / Av)", icon: Icons.home_outlined),
                      const SizedBox(height: 20),
                      
                      // --- NUEVO SECCIÓN: Ubicación Geográfica ---
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Ubicación", style: TextStyle(color: AppColors.darkOlive, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 10),

                      // 1. Selector de Estado
                      _buildDropdown(
                        label: "Estado",
                        icon: Icons.map,
                        value: _selectedState,
                        items: _venezuelaData.map((e) => e['estado'] as String).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedState = val;
                            // Resetear selección en cascada
                            _selectedCity = null;
                            _selectedMunicipality = null;
                            _availableMunicipalities = [];

                            // Filtrar ciudades
                            if (val != null) {
                              var estadoData = _venezuelaData.firstWhere((e) => e['estado'] == val);
                              _availableCities = List<Map<String, dynamic>>.from(estadoData['ciudades']);
                            } else {
                              _availableCities = [];
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 15),

                      // 2. Selector de Ciudad
                      _buildDropdown(
                        label: "Ciudad",
                        icon: Icons.location_city,
                        value: _selectedCity,
                        isDisabled: _selectedState == null,
                        items: _availableCities.map((e) => e['nombre'] as String).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedCity = val;
                            // Resetear selección en cascada
                            _selectedMunicipality = null;

                            // Filtrar municipios
                            if (val != null) {
                              var ciudadData = _availableCities.firstWhere((e) => e['nombre'] == val);
                              _availableMunicipalities = List<String>.from(ciudadData['municipios']);
                            } else {
                              _availableMunicipalities = [];
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 15),

                      // 3. Selector de Municipio
                      _buildDropdown(
                        label: "Municipio",
                        icon: Icons.location_on_outlined,
                        value: _selectedMunicipality,
                        isDisabled: _selectedCity == null,
                        items: _availableMunicipalities,
                        onChanged: (val) {
                          setState(() {
                            _selectedMunicipality = val;
                          });
                        },
                      ),

                      const SizedBox(height: 25),
                      const Text(
                        "Creación de usuario",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const Divider(),
                      const SizedBox(height: 10),

                      // --- SECCIÓN: Cuenta ---
                      _buildTextField(label: "Nombre de Usuario", icon: Icons.account_circle_outlined),
                      const SizedBox(height: 15),
                      _buildTextField(
                        label: "Contraseña",
                        icon: Icons.lock_outline,
                        isPassword: true,
                        controller: _passwordController,
                        onChanged: (_) => _validatePasswords(),
                        errorText: _passwordError,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        label: "Confirmar Contraseña",
                        icon: Icons.lock_outline,
                        isPassword: true,
                        controller: _confirmPasswordController,
                        onChanged: (_) => _validatePasswords(),
                        errorText: _confirmPasswordError,
                      ),

                      const SizedBox(height: 20),

                      // Checkbox de términos
                      Row(
                        children: [
                          Checkbox(
                            value: _acceptedTerms,
                            activeColor: AppColors.orange,
                            onChanged: (val) {
                              setState(() {
                                _acceptedTerms = val ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: Text(
                              "Acepto los términos y condiciones del servicio.",
                              style: TextStyle(
                                color: AppColors.darkOlive.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Botones de acción
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context); // Volver al menú principal
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.darkOlive,
                              side: const BorderSide(color: AppColors.sageGreen),
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Atrás"),
                          ),
                          
                          ElevatedButton(
                            onPressed: () {
                               // Ejemplo de captura de datos
                               print("Estado: $_selectedState, Ciudad: $_selectedCity");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Registrar",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              
              // Botón "X" de cerrar
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: AppColors.darkOlive,
                    radius: 14,
                    child: Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- NUEVO WIDGET: Dropdown con el estilo de tu app ---
  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isDisabled = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(item, overflow: TextOverflow.ellipsis),
        )).toList(),
        onChanged: isDisabled ? null : onChanged,
        // Si está deshabilitado, se pone gris el ícono
        icon: Icon(Icons.arrow_drop_down, color: isDisabled ? Colors.grey : AppColors.darkOlive),
        style: TextStyle(color: isDisabled ? Colors.grey : AppColors.darkOlive, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDisabled ? Colors.grey : AppColors.darkOlive.withOpacity(0.6)),
          prefixIcon: Icon(icon, color: isDisabled ? Colors.grey : AppColors.darkOlive),
          filled: true,
          // Cambia el color de fondo si está bloqueado
          fillColor: isDisabled ? Colors.grey.withOpacity(0.1) : AppColors.sageGreen.withOpacity(0.25),
        ),
      ),
    );
  }

  // --- Widget existente de TextField ---
  Widget _buildTextField({
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    TextEditingController? controller,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        obscureText: isPassword,
        keyboardType: inputType,
        style: const TextStyle(color: AppColors.darkOlive),
        decoration: InputDecoration(
          errorText: errorText,
          errorMaxLines: 4, // Permite mostrar la lista de requisitos
          counterText: "",
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.darkOlive),
          // El tema global maneja los bordes y colores, pero aquí se respetan tus personalizaciones
        ),
      ),
    );
  }
}