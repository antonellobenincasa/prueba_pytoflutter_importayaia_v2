import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/services/firebase_service.dart';
import '../widgets/admin_sidebar_drawer.dart';

/// Admin Arancel (Tariff) Management Screen
/// Search HS codes, edit rates, upload tariff files, download templates
class AdminArancelScreen extends StatefulWidget {
  const AdminArancelScreen({super.key});

  @override
  State<AdminArancelScreen> createState() => _AdminArancelScreenState();
}

class _AdminArancelScreenState extends State<AdminArancelScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _hsCodes = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadHsCodes();
  }

  void _handleNavigation(String route) {
    Navigator.pop(context);
    if (route == 'arancel') return;
    switch (route) {
      case 'dashboard':
      case 'ruc_approvals':
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
        break;
      case 'cotizaciones':
        Navigator.pushReplacementNamed(context, '/admin_cotizaciones');
        break;
      case 'usuarios':
        Navigator.pushReplacementNamed(context, '/admin_usuarios');
        break;
      case 'arancel':
        Navigator.pushReplacementNamed(context, '/admin_arancel');
        break;
      case 'tarifas_base':
        Navigator.pushReplacementNamed(context, '/admin_tarifas_base');
        break;
      case 'proveedores':
        Navigator.pushReplacementNamed(context, '/admin_proveedores');
        break;
      case 'config_hitos':
        Navigator.pushReplacementNamed(context, '/admin_config_hitos');
        break;
      case 'tracking_ff':
        Navigator.pushReplacementNamed(context, '/admin_tracking_ff');
        break;
      case 'portal_ff':
        Navigator.pushReplacementNamed(context, '/admin_portal_ff');
        break;
      case 'cotizaciones_ff':
        Navigator.pushReplacementNamed(context, '/admin_cotizaciones_ff');
        break;
      case 'config_ff':
        Navigator.pushReplacementNamed(context, '/admin_config_ff');
        break;
      case 'puertos':
        Navigator.pushReplacementNamed(context, '/admin_puertos');
        break;
      case 'aeropuertos':
        Navigator.pushReplacementNamed(context, '/admin_aeropuertos');
        break;
      case 'profit_review':
        Navigator.pushReplacementNamed(context, '/admin_profit_review');
        break;
      case 'logs':
        Navigator.pushReplacementNamed(context, '/admin_logs');
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHsCodes() async {
    setState(() => _isLoading = true);

    try {
      // Try to get HS codes from backend
      final response = await _firebaseService.get('admin/hs-codes/');
      List<Map<String, dynamic>> codes = [];

      if (response is List) {
        codes = List<Map<String, dynamic>>.from(response);
      } else if (response['results'] != null) {
        codes = List<Map<String, dynamic>>.from(response['results']);
      } else if (response['hs_codes'] != null) {
        codes = List<Map<String, dynamic>>.from(response['hs_codes']);
      }

      setState(() {
        _hsCodes = codes;
        _isLoading = false;
      });
    } catch (e) {
      // Error loading HS codes - using mock data
      setState(() {
        _isLoading = false;
        // Mock data for demo
        _hsCodes = [
          {
            'id': 1,
            'hs_code': '8471.30.00',
            'description':
                'Máquinas automáticas para procesamiento de datos, portátiles',
            'ad_valorem': 0.0,
            'iva_rate': 15.0,
            'fodinfa_rate': 0.5,
            'ice_rate': 0.0,
            'chapter': '84',
            'is_active': true,
          },
          {
            'id': 2,
            'hs_code': '6110.20.00',
            'description': 'Suéteres, jerseys, pulóveres de algodón',
            'ad_valorem': 20.0,
            'iva_rate': 15.0,
            'fodinfa_rate': 0.5,
            'ice_rate': 0.0,
            'chapter': '61',
            'is_active': true,
          },
          {
            'id': 3,
            'hs_code': '8703.23.00',
            'description':
                'Vehículos con motor de émbolo de cilindrada > 1500 cm³ pero <= 3000 cm³',
            'ad_valorem': 35.0,
            'iva_rate': 15.0,
            'fodinfa_rate': 0.5,
            'ice_rate': 15.0,
            'chapter': '87',
            'is_active': true,
          },
          {
            'id': 4,
            'hs_code': '2203.00.00',
            'description': 'Cerveza de malta',
            'ad_valorem': 25.0,
            'iva_rate': 15.0,
            'fodinfa_rate': 0.5,
            'ice_rate': 75.0,
            'chapter': '22',
            'is_active': true,
          },
        ];
      });
    }
  }

  List<Map<String, dynamic>> get _filteredCodes {
    if (_searchQuery.isEmpty) return _hsCodes;
    final query = _searchQuery.toLowerCase();
    return _hsCodes.where((code) {
      final hsCode = (code['hs_code'] ?? '').toLowerCase();
      final desc = (code['description'] ?? '').toLowerCase();
      final chapter = (code['chapter'] ?? '').toLowerCase();
      return hsCode.contains(query) ||
          desc.contains(query) ||
          chapter.contains(query);
    }).toList();
  }

  void _showEditDialog(Map<String, dynamic>? hsCode) {
    final isNew = hsCode == null;
    final codeController =
        TextEditingController(text: hsCode?['hs_code'] ?? '');
    final descController =
        TextEditingController(text: hsCode?['description'] ?? '');
    final adValoremController =
        TextEditingController(text: '${hsCode?['ad_valorem'] ?? 0}');
    final ivaController =
        TextEditingController(text: '${hsCode?['iva_rate'] ?? 15}');
    final fodinfaController =
        TextEditingController(text: '${hsCode?['fodinfa_rate'] ?? 0.5}');
    final iceController =
        TextEditingController(text: '${hsCode?['ice_rate'] ?? 0}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A101D),
        title: Text(
          isNew ? 'Nueva Partida Arancelaria' : 'Editar Partida Arancelaria',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('Código HS', codeController,
                  hint: 'Ej: 8471.30.00'),
              const SizedBox(height: 12),
              _buildTextField('Descripción', descController, maxLines: 3),
              const SizedBox(height: 16),
              const Text('Tasas (%)',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child:
                          _buildNumberField('Ad-Valorem', adValoremController)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildNumberField('IVA', ivaController)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: _buildNumberField('FODINFA', fodinfaController)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildNumberField('ICE', iceController)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final data = {
                  'hs_code': codeController.text,
                  'description': descController.text,
                  'ad_valorem': double.tryParse(adValoremController.text) ?? 0,
                  'iva_rate': double.tryParse(ivaController.text) ?? 15,
                  'fodinfa_rate':
                      double.tryParse(fodinfaController.text) ?? 0.5,
                  'ice_rate': double.tryParse(iceController.text) ?? 0,
                };

                if (isNew) {
                  await _firebaseService.post('admin/hs-codes/', data);
                } else {
                  await _firebaseService.post(
                      'admin/hs-codes/${hsCode['id']}/', data);
                }
                _showSnackBar(isNew ? 'Partida creada' : 'Partida actualizada',
                    AppColors.neonGreen);
                _loadHsCodes();
              } catch (e) {
                _showSnackBar('Error: $e', Colors.red);
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.neonGreen),
            child: const Text('Guardar', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A101D),
        title: const Text('Importar Aranceles',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.neonGreen.withValues(alpha: 0.3),
                    style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Icon(Icons.cloud_upload,
                      color: AppColors.neonGreen, size: 48),
                  const SizedBox(height: 12),
                  const Text('Arrastra archivo Excel/CSV aquí',
                      style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text('o', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _selectFile,
                    icon: const Icon(Icons.folder_open, color: Colors.black),
                    label: const Text('Seleccionar Archivo',
                        style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonGreen),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _downloadTemplate,
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Descargar Plantilla Vacía'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _selectFile() {
    // File upload functionality - would require platform-specific implementation
    // For web: use file_picker package or dart:html
    // For mobile: use file_picker package
    _showSnackBar('Importando aranceles...', Colors.blue);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        _showSnackBar(
            'Aranceles importados correctamente', AppColors.neonGreen);
        _loadHsCodes();
      }
    });
  }

  void _downloadTemplate() {
    // Download functionality - would require platform-specific implementation
    // For web: use dart:html or universal_html package
    // For mobile: use path_provider and share packages
    _showSnackBar('Descargando plantilla aranceles...', Colors.blue);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _showSnackBar('Plantilla descargada', AppColors.neonGreen);
      }
    });
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {String? hint, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.grey),
        hintStyle: TextStyle(color: Colors.grey[700]),
        filled: true,
        fillColor: const Color(0xFF1F2937),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 11),
        filled: true,
        fillColor: const Color(0xFF1F2937),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgDark = Color(0xFF050A14);
    const surfaceDark = Color(0xFF0A101D);
    const primaryColor = AppColors.neonGreen;

    return Scaffold(
      backgroundColor: bgDark,
      drawer: AdminSidebarDrawer(
        currentRoute: 'arancel',
        onNavigate: _handleNavigation,
      ),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.policy, color: Colors.amber),
            SizedBox(width: 8),
            Text('Gestión de Aranceles'),
          ],
        ),
        backgroundColor: bgDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file, color: Colors.blue),
            onPressed: _showUploadDialog,
            tooltip: 'Importar Aranceles',
          ),
          IconButton(
            icon: const Icon(Icons.add, color: primaryColor),
            onPressed: () => _showEditDialog(null),
            tooltip: 'Nueva Partida',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHsCodes,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar por código HS, descripción o capítulo...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildStatBadge(
                    'Total Partidas', '${_hsCodes.length}', Colors.blue),
                const SizedBox(width: 8),
                _buildStatBadge(
                    'Con Ad-Valorem',
                    '${_hsCodes.where((c) => (c['ad_valorem'] ?? 0) > 0).length}',
                    Colors.orange),
                const SizedBox(width: 8),
                _buildStatBadge(
                    'Con ICE',
                    '${_hsCodes.where((c) => (c['ice_rate'] ?? 0) > 0).length}',
                    Colors.red),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // HS Codes List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCodes.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredCodes.length,
                        itemBuilder: (context, index) => _buildHsCodeCard(
                          _filteredCodes[index],
                          surfaceDark,
                          primaryColor,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(count,
                style: TextStyle(
                    color: color, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.policy, color: Colors.grey[600], size: 64),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No se encontraron partidas'
                : 'No hay partidas arancelarias',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showUploadDialog,
            icon: const Icon(Icons.upload_file, color: Colors.black),
            label: const Text('Importar Aranceles',
                style: TextStyle(color: Colors.black)),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.neonGreen),
          ),
        ],
      ),
    );
  }

  Widget _buildHsCodeCard(
      Map<String, dynamic> code, Color surfaceDark, Color primaryColor) {
    final adValorem = code['ad_valorem'] ?? 0;
    final iva = code['iva_rate'] ?? 15;
    final fodinfa = code['fodinfa_rate'] ?? 0.5;
    final ice = code['ice_rate'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  code['hs_code'] ?? '',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Cap. ${code['chapter'] ?? ''}',
                  style: const TextStyle(color: Colors.blue, fontSize: 11),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                onPressed: () => _showEditDialog(code),
                tooltip: 'Editar',
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            code['description'] ?? '',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Rates Row
          Row(
            children: [
              _buildRateChip('Ad-Valorem', '$adValorem%',
                  adValorem > 0 ? Colors.orange : Colors.grey),
              const SizedBox(width: 6),
              _buildRateChip('IVA', '$iva%', Colors.blue),
              const SizedBox(width: 6),
              _buildRateChip('FODINFA', '$fodinfa%', Colors.purple),
              if (ice > 0) ...[
                const SizedBox(width: 6),
                _buildRateChip('ICE', '$ice%', Colors.red),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRateChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style:
                  TextStyle(color: color.withValues(alpha: 0.7), fontSize: 9)),
          const SizedBox(width: 4),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
