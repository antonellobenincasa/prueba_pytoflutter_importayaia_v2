import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/api/client.dart';
import '../widgets/admin_sidebar_drawer.dart';

class AdminProfitReviewScreen extends StatefulWidget {
  const AdminProfitReviewScreen({super.key});

  @override
  State<AdminProfitReviewScreen> createState() =>
      _AdminProfitReviewScreenState();
}

class _AdminProfitReviewScreenState extends State<AdminProfitReviewScreen> {
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = true;
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get('admin/profit-review/');
      if (response != null && response is Map<String, dynamic>) {
        setState(() => _data = response);
      }
    } catch (e) {
      _showSnackBar('Error cargando profit review: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadReport() async {
    try {
      final response = await _apiClient
          .get('admin/export/', queryParameters: {'type': 'profit'});
      // In a real web app, we would trigger a download with the blob.
      // For now, we just show success since file handling varies.
      if (response != null && response['success'] == true) {
        _showSnackBar('Reporte generado (simulado)', AppColors.neonGreen);
      }
    } catch (e) {
      _showSnackBar('Error generando reporte', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _handleNavigation(String route) {
    Navigator.pop(context);
    if (route == 'profit_review') return;
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
  Widget build(BuildContext context) {
    const bgDark = Color(0xFF050A14);
    const surfaceDark = Color(0xFF0A101D);
    const primaryColor = AppColors.neonGreen;

    return Scaffold(
      backgroundColor: bgDark,
      drawer: AdminSidebarDrawer(
        currentRoute: 'profit_review',
        onNavigate: _handleNavigation,
      ),
      appBar: AppBar(
        title: const Text('Profit Review'),
        backgroundColor: bgDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadReport,
            tooltip: 'Exportar CSV',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPIs
                  if (_data['resumen'] != null) ...[
                    _buildKPIGrid(_data['resumen'], surfaceDark, primaryColor),
                    const SizedBox(height: 24),
                  ],

                  // Monthly Chart
                  if (_data['charts']?['monthly_profits'] != null) ...[
                    const Text('Ganancia Mensual (Últimos 12 meses)',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildMonthlyChart(_data['charts']['monthly_profits'],
                        surfaceDark, primaryColor),
                    const SizedBox(height: 24),
                  ],

                  // Transport Breakdown
                  if (_data['charts']?['transport_breakdown'] != null) ...[
                    const Text('Desglose por Transporte',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildTransportBreakdown(
                        _data['charts']['transport_breakdown'], surfaceDark),
                    const SizedBox(height: 24),
                  ],

                  // RO List
                  const Text('Detalle de ROs Activos',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildROList(_data['ros'] ?? [], surfaceDark),
                ],
              ),
            ),
    );
  }

  Widget _buildKPIGrid(
      Map<String, dynamic> kpis, Color surfaceColor, Color primaryColor) {
    // Replaced with Map for safety
    return GridView.count(
      crossAxisCount:
          2, // Adjusted for typical mobile/web width, can be responsive
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildKPICard('Ingresos Totales', '\$${kpis['ingresos_totales_usd']}',
            Icons.attach_money, Colors.blue),
        _buildKPICard('Margen Total', '\$${kpis['margen_total_usd']}',
            Icons.trending_up, primaryColor),
        _buildKPICard('Margen %', '${kpis['margen_promedio_porcentaje']}%',
            Icons.pie_chart, Colors.purple),
        _buildKPICard('Total ROs', '${kpis['total_ros']}', Icons.receipt_long,
            Colors.orange),
      ],
    );
  }

  Widget _buildKPICard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A101D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(
      List<dynamic> data, Color surfaceColor, Color primaryColor) {
    if (data.isEmpty) return const SizedBox();

    double maxProfit = 0;
    for (var d in data) {
      if (d['profit'] > maxProfit) maxProfit = d['profit'].toDouble();
    }
    if (maxProfit == 0) maxProfit = 1;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: data.map((d) {
          final heightPct =
              ((d['profit'] as num) / maxProfit).clamp(0.0, 1.0).toDouble();
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 120 * heightPct,
                  width: 12,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  (d['month'] as String).split(' ').first, // Just Month name
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransportBreakdown(List<dynamic> data, Color surfaceColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: data.map((d) {
          final color = d['name'] == 'FCL'
              ? Colors.blue
              : d['name'] == 'LCL'
                  ? Colors.orange
                  : Colors.purple;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                    width: 12,
                    height: 12,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(d['name'], style: const TextStyle(color: Colors.white)),
                const Spacer(),
                Text('\$${d['value']}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildROList(List<dynamic> ros, Color surfaceColor) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ros.length,
      itemBuilder: (context, index) {
        final ro = ros[index];
        final marginPct = ro['margen_porcentaje'] ?? 0;
        final isPositive = marginPct > 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(ro['ro_number'] ?? 'N/A',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isPositive ? Colors.green : Colors.red)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('${marginPct}%',
                        style: TextStyle(
                            color: isPositive ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(ro['cliente_email'] ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Text('\$${ro['margen_usd']}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
