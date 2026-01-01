import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  // Controllers
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _empresaController = TextEditingController();
  final _rucController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _direccionController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final userData = _authService.userData;
    if (userData != null) {
      _nombreController.text = userData['first_name'] ?? '';
      _apellidoController.text = userData['last_name'] ?? '';
      _empresaController.text = userData['company_name'] ?? '';
      _telefonoController.text = userData['phone'] ?? '';
      _ciudadController.text = userData['city'] ?? '';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _empresaController.dispose();
    _rucController.dispose();
    _telefonoController.dispose();
    _ciudadController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    // TODO: Implementar llamada a API para guardar perfil
    // Por ahora simulamos guardado exitoso
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isSaving = false;
      _successMessage = 'Perfil actualizado exitosamente';
    });

    // Ocultar mensaje después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _successMessage = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const bgDark = Color(0xFF050A14);
    const surfaceDark = Color(0xFF0A101D);
    const primaryColor = AppColors.neonGreen;

    final rucStatus = _authService.rucStatus;
    final isRucApproved = _authService.isRucApproved;

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        title: const Text("Mi Perfil"),
        backgroundColor: bgDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Banner
              _buildStatusBanner(rucStatus, isRucApproved, primaryColor),
              const SizedBox(height: 24),

              // Información Personal
              _buildSectionTitle("Información Personal"),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _nombreController,
                      label: "Nombre",
                      icon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _apellidoController,
                      label: "Apellido",
                      icon: Icons.person_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _telefonoController,
                label: "Teléfono",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _ciudadController,
                label: "Ciudad",
                icon: Icons.location_city_outlined,
              ),
              const SizedBox(height: 32),

              // Información Empresarial
              _buildSectionTitle("Información Empresarial"),
              const SizedBox(height: 8),
              Text(
                "Estos datos son requeridos para habilitar las funciones de cotización e importación.",
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _empresaController,
                label: "Nombre de Empresa",
                icon: Icons.business_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre de empresa es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _rucController,
                label: "RUC (13 dígitos)",
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
                maxLength: 13,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El RUC es requerido';
                  }
                  if (value.length != 13) {
                    return 'El RUC debe tener 13 dígitos';
                  }
                  if (!RegExp(r'^\d{13}$').hasMatch(value)) {
                    return 'El RUC solo debe contener números';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _direccionController,
                label: "Dirección Comercial",
                icon: Icons.location_on_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // Messages
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_errorMessage!,
                            style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),

              if (_successMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: primaryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_successMessage!,
                            style: TextStyle(color: primaryColor)),
                      ),
                    ],
                  ),
                ),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: bgDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save),
                            SizedBox(width: 8),
                            Text(
                              "Guardar Cambios",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner(
      String? rucStatus, bool isRucApproved, Color primaryColor) {
    String message;
    Color color;
    IconData icon;

    if (isRucApproved) {
      message = "✅ Tu cuenta está verificada y lista para operar";
      color = primaryColor;
      icon = Icons.verified;
    } else if (rucStatus == 'pending') {
      message =
          "⏳ Tu RUC está en revisión. Te notificaremos cuando sea aprobado.";
      color = Colors.orange;
      icon = Icons.hourglass_top;
    } else {
      message =
          "⚠️ Completa los datos de tu empresa y RUC para habilitar las funciones de importación.";
      color = Colors.amber;
      icon = Icons.warning_amber;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.grey[500]),
        counterStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: const Color(0xFF0A101D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neonGreen),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
