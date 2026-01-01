import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'package:animate_do/animate_do.dart';

class QuoteDetailScreen extends StatelessWidget {
  final String quoteId;

  const QuoteDetailScreen({super.key, this.quoteId = "COT-2023-8492"});

  void _showApprovalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElasticIn(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                      color: AppColors.neonGreen, shape: BoxShape.circle),
                  child: const Icon(Icons.check, size: 40, color: Colors.black),
                ),
              ),
              const SizedBox(height: 24),
              const Text("¡Cotización Aprobada!",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text(
                "Un agente de ImportaYA se pondrá en contacto contigo para coordinar el pago y la logística.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close Dialog
                    Navigator.pop(context); // Back to previous Screen
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonGreen,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: const Text("Entendido",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              const Text("¿Rechazar Cotización?",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text(
                "Esta acción no se puede deshacer. Indícanos el motivo para mejorar:",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: "El precio es muy alto...",
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: const Color(0xFF050A14),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none)),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancelar",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                "Cotización rechazada. Gracias por tu feedback.")));
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white),
                      child: const Text("Rechazar"),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppColors.neonGreen;
    const surfaceColor = AppColors.darkBlueBackground;
    const cardColor = Color(0xFF111827); // surface-dark

    return Scaffold(
      backgroundColor: surfaceColor,
      body: Stack(
        children: [
          // Custom ScrollView for content
          SingleChildScrollView(
            padding:
                const EdgeInsets.only(bottom: 100), // Space for sticky footer
            child: Column(
              children: [
                // 1. Status Card (Header)
                Stack(
                  children: [
                    // Background Image & Gradient
                    Container(
                      height: 280,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24)),
                          image: const DecorationImage(
                            image: NetworkImage(
                                "https://lh3.googleusercontent.com/aida-public/AB6AXuC8InMuWV1cPkGGWVSREcpjMe2v-JUIKpTprNcHPnVibccEx7gcPOJJckBqunoBqPkoZsxnjSWUHovYu0lqptuaAva2SiPjxZ-px6s_4rijjAB6Jl78ADIbEFeN6x2oxcT_17Bud_oG_m1EtCYN1Qo_GvgDgddAkuT0qIjZXrGYGXW-iEkMTMDuVwRwvuLvdk_UxDbNYmgOc-rDK1zIwoNQEVLnmM3RW2ka2uTjEPdCpCzKlWP-mZZkzP8kKAcExWQodX5EB3V4Nsg"),
                            fit: BoxFit.cover,
                          )),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF050A14).withValues(alpha: 0.3),
                              const Color(0xFF050A14).withValues(alpha: 0.95),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // SafeArea Content
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Custom App Bar Row (Back Button & Title)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back,
                                      color: Colors.white),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                const Text("Detalle de Cotización",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.picture_as_pdf,
                                      color: Colors.white),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            const SizedBox(height: 60),

                            // Status Info
                            const Text("Cotización",
                                style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5)),
                            const SizedBox(height: 4),
                            Text("#$quoteId",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.yellow.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                    color:
                                        Colors.yellow.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                          color: Colors.yellow,
                                          shape: BoxShape.circle)),
                                  const SizedBox(width: 8),
                                  const Text("PENDIENTE DE APROBACIÓN",
                                      style: TextStyle(
                                          color: Colors.yellowAccent,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // 2. Timeline Section
                      _buildSectionContainer(
                          title: "Ruta de Importación",
                          icon: Icons.public,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  const Icon(Icons.flight_takeoff,
                                      color: Colors.white, size: 20),
                                  Container(
                                      width: 2,
                                      height: 40,
                                      color: Colors.white24),
                                  const Icon(Icons.flight_land,
                                      color: primaryColor, size: 20),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Origin
                                    const Text("Shanghai (CN)",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("Puerto de Salida",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12)),
                                        const Text("12 Oct",
                                            style: TextStyle(
                                                color: primaryColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    // Destination
                                    const Text("Guayaquil (EC)",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("Destino Final",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12)),
                                        const Text("15 Oct",
                                            style: TextStyle(
                                                color: primaryColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )),

                      const SizedBox(height: 16),

                      // 3. Cargo Details
                      _buildSectionContainer(
                          title: "Información de la Carga",
                          icon: Icons.inventory_2,
                          child: GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 2.5,
                            children: [
                              _buildInfoItem("Producto", "500x Smart Watches"),
                              _buildInfoItem("Tipo de Carga", "Carga General"),
                              _buildInfoItem("Peso Total", "150 kg"),
                              _buildInfoItem("Volumen", "2.5 CBM"),
                            ],
                          )),

                      const SizedBox(height: 16),

                      // 4. Documents
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.description,
                                  color: Colors.blue, size: 20),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Documentos Adjuntos",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                  Text("Invoice, Packing List",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 5. Cost Breakdown
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.white10)),
                              ),
                              width: double.infinity,
                              child: const Text("DESGLOSE DE COSTOS",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  _buildCostRow(
                                      "Flete Internacional", "\$1,200.00"),
                                  const SizedBox(height: 8),
                                  _buildCostRow("Seguro de Carga", "\$150.00"),
                                  const SizedBox(height: 8),
                                  _buildCostRow("Gastos Locales", "\$300.00"),
                                  const Divider(
                                      color: Colors.white24, height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text("Total Estimado",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          const Text("\$1,650.00",
                                              style: TextStyle(
                                                  color: primaryColor,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold)),
                                          const Text("IMPUESTOS INCLUIDOS",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 6. Sticky Action Footer
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF050A14),
                border: const Border(top: BorderSide(color: Colors.white10)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, -5))
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRejectDialog(context),
                      icon: const Icon(Icons.close),
                      label: const Text("Rechazar"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => _showApprovalDialog(context),
                      icon: const Icon(Icons.check),
                      label: const Text("Aprobar Cotización"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionContainer(
      {required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
              Icon(icon, color: Colors.grey, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildCostRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(amount,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
