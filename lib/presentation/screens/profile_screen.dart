import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/services/auth_service.dart';
import '../../core/api/client.dart';

/// List of main Ecuador cities for autocomplete
const List<String> ecuadorCities = [
  'Guayaquil',
  'Quito',
  'Cuenca',
  'Santo Domingo',
  'Machala',
  'Durán',
  'Manta',
  'Portoviejo',
  'Loja',
  'Ambato',
  'Esmeraldas',
  'Quevedo',
  'Riobamba',
  'Milagro',
  'Ibarra',
  'Latacunga',
  'Tulcán',
  'Babahoyo',
  'Sangolquí',
  'Pasaje',
  'Chone',
  'Santa Rosa',
  'Huaquillas',
  'El Carmen',
  'Daule',
  'Samborondón',
  'La Libertad',
  'Salinas',
  'Otavalo',
  'Cayambe',
];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final ApiClient _apiClient = ApiClient();

  // Controllers
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _empresaController = TextEditingController();
  final _rucController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();

  // City autocomplete
  String _selectedCity = '';

  bool _isSaving = false;
  bool _rucIsReadOnly = false;
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
      _selectedCity = userData['city'] ?? '';
      _direccionController.text = userData['address'] ?? '';

      // Pre-fill RUC from registration data
      final ruc = userData['ruc'] ?? _authService.userRuc ?? '';
      if (ruc.isNotEmpty) {
        _rucController.text = ruc;
        // If RUC is already approved, make it read-only
        if (_authService.isRucApproved) {
          _rucIsReadOnly = true;
        }
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _empresaController.dispose();
    _rucController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate city is selected
    if (_selectedCity.isEmpty) {
      setState(() => _errorMessage = 'Por favor selecciona una ciudad');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Prepare profile data
      final profileData = {
        'first_name': _nombreController.text.trim(),
        'last_name': _apellidoController.text.trim(),
        'company_name': _empresaController.text.trim(),
        'phone': _telefonoController.text.trim(),
        'city': _selectedCity,
        'address': _direccionController.text.trim(),
      };

      // Only include RUC if not read-only (not yet approved)
      if (!_rucIsReadOnly && _rucController.text.isNotEmpty) {
        profileData['ruc'] = _rucController.text.trim();
      }

      // Saving profile to backend

      // Call API to update profile using PUT to /profile/complete/
      await _apiClient.put('accounts/profile/complete/', profileData);
      // Profile saved successfully

      // If RUC was provided and is new, request approval
      if (!_rucIsReadOnly && _rucController.text.isNotEmpty) {
        try {
          await _requestRucApproval();
        } catch (e) {
          // RUC approval request issue - continue anyway
        }
      }

      if (mounted) {
        setState(() {
          _isSaving = false;
          _successMessage = _rucController.text.isNotEmpty && !_rucIsReadOnly
              ? '✅ Perfil guardado. RUC enviado para aprobación.'
              : '✅ Perfil actualizado exitosamente';
        });

        // Refresh user data
        await _authService.fetchUserProfile();
      }
    } catch (e) {
      // Error saving profile
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Error al guardar: $e';
        });
      }
    }
  }

  Future<void> _requestRucApproval() async {
    final rucData = {
      'ruc': _rucController.text.trim(),
      'company_name': _empresaController.text.trim(),
    };

    await _apiClient.post('accounts/register-ruc/', rucData);
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

              // City Autocomplete
              _buildCityAutocomplete(surfaceDark, primaryColor),

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
                label:
                    _rucIsReadOnly ? "RUC (Verificado ✓)" : "RUC (13 dígitos)",
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
                maxLength: 13,
                readOnly: _rucIsReadOnly,
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
                  if (!value.endsWith('001')) {
                    return 'El RUC debe terminar en 001';
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
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.red.withValues(alpha: 0.3)),
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
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: primaryColor.withValues(alpha: 0.3)),
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

  Widget _buildCityAutocomplete(Color surfaceDark, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<String>(
          initialValue: TextEditingValue(text: _selectedCity),
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return ecuadorCities.where((city) => city
                .toLowerCase()
                .startsWith(textEditingValue.text.toLowerCase()));
          },
          onSelected: (String selection) {
            setState(() => _selectedCity = selection);
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            // Sync controller with selected city
            if (controller.text.isEmpty && _selectedCity.isNotEmpty) {
              controller.text = _selectedCity;
            }
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                // Update selected city as user types
                if (ecuadorCities
                    .any((c) => c.toLowerCase() == value.toLowerCase())) {
                  _selectedCity = ecuadorCities.firstWhere(
                      (c) => c.toLowerCase() == value.toLowerCase());
                }
              },
              decoration: InputDecoration(
                labelText: "Ciudad",
                labelStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon:
                    Icon(Icons.location_city_outlined, color: Colors.grey[500]),
                suffixIcon:
                    Icon(Icons.arrow_drop_down, color: Colors.grey[500]),
                filled: true,
                fillColor: surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor),
                ),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: surfaceDark,
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        leading: Icon(Icons.location_on,
                            color: primaryColor, size: 20),
                        title: Text(option,
                            style: const TextStyle(color: Colors.white)),
                        onTap: () => onSelected(option),
                        hoverColor: primaryColor.withValues(alpha: 0.1),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines,
      readOnly: readOnly,
      validator: validator,
      style: TextStyle(color: readOnly ? Colors.grey : Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.grey[500]),
        counterStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: readOnly
            ? const Color(0xFF0A101D).withValues(alpha: 0.5)
            : const Color(0xFF0A101D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: readOnly
                  ? Colors.green.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1)),
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
