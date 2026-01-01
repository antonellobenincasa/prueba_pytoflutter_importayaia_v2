import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../widgets/transport_icon.dart';

class TrackingScreen extends StatelessWidget {
  final String quoteId;
  const TrackingScreen({super.key, this.quoteId = "IMP-839201"});

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppColors.neonGreen;
    const surfaceColor = AppColors.darkBlueBackground;

    return Scaffold(
      backgroundColor: surfaceColor,
      extendBodyBehindAppBar:
          true, // For the blurred effect in header if we want, but HTML uses fixed header
      appBar: AppBar(
        backgroundColor: const Color(0xFF050A14).withValues(alpha: 0.9),
        elevation: 0,
        leading: Builder(
            builder: (c) => IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(c))),
        title: const Text("Seguimiento de Carga",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        actions: [
          Stack(
            children: [
              IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {}),
              Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: primaryColor, shape: BoxShape.circle)))
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
            top: 100,
            left: 16,
            right: 16,
            bottom: 40), // Top padding for fixed header simulation
        child: Column(
          children: [
            // Search Bar
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF111620),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: "#$quoteId",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Número de guía...",
                          hintStyle: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                        border:
                            Border(left: BorderSide(color: Colors.white10))),
                    child:
                        const Icon(Icons.qr_code_scanner, color: primaryColor),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Shipment Overview Card (Map)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF111620),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5))
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  // Map Section
                  SizedBox(
                    height: 192,
                    child: Stack(
                      children: [
                        // Background Image (Mock Map)
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.5,
                            child: Image.network(
                              "https://lh3.googleusercontent.com/aida-public/AB6AXuCuFjmtQirnfKWrQlvZGmFIJqGo_MpUAOVkILNB4yuVWo-6AlAgIHcBS4QE2jtWUKjFhJsZoZwMXqfdtpwLKv4nqLdbWlkSD7cwvkYMfJAn_nb_ZvMTimBuSMIA_Cn89qgE73_HJAm1hc-R9EIqTd1QQLqTvmW-fRJrFbwBX271TeRX2b7EM6sZVnrrlvtITlD-O6mHtjuBNUYFd_zF1WK5Hry38PV-XGOxp3IXuvigwr97xmd0OP_-WWWaHU1KLL0-7o1nAg7ub98",
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) =>
                                  Container(color: Colors.blueGrey.shade900),
                            ),
                          ),
                        ),
                        // Gradient
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                const Color(0xFF111620),
                                const Color(0xFF111620).withValues(alpha: 0.2),
                                Colors.transparent
                              ],
                            )),
                          ),
                        ),
                        // Floating Badge
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              children: [
                                Pulse(
                                    infinite: true,
                                    child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                            color: primaryColor,
                                            shape: BoxShape.circle))),
                                const SizedBox(width: 8),
                                const Text("EN TRÁNSITO",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1)),
                              ],
                            ),
                          ),
                        ),
                        // Transport Dynamic Icon
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Change type here or via props: TransportType.air, maritimeLCL, etc.
                              const TransportIcon(
                                type: TransportType.maritimeFCL,
                                size: 30,
                                isGroundSegment:
                                    false, // Set to true if status is 'Arrived' or 'Final Delivery'
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(4)),
                                child: const Text("PACIFIC OCEAN",
                                    style: TextStyle(
                                        color: AppColors.neonGreen,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1)),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  // Details Section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("GUÍA INTERNACIONAL",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text("#$quoteId",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text("LLEGADA ESTIMADA",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                const Text("24 Oct, 2023",
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Progress
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("CN, Shanghai",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                            const Text("MX, Manzanillo",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 11))
                          ],
                        ),
                        const SizedBox(height: 8),
                        Stack(
                          children: [
                            Container(
                                height: 6,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: const Color(0xFF2A303C),
                                    borderRadius: BorderRadius.circular(3))),
                            Container(
                                height: 6,
                                width: 200,
                                decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(3))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("65% Completado",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                            Text("En tiempo",
                                style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold))
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Vertical Timeline
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.timeline, color: primaryColor, size: 20),
                    SizedBox(width: 8),
                    Text("Historial de Eventos",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      color: const Color(0xFF111620),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10)),
                  child: Column(
                    children: [
                      _buildTimelineItem(
                          icon: Icons.check,
                          iconColor: primaryColor,
                          iconBg: primaryColor.withValues(alpha: 0.1),
                          title: "Recibido en Origen",
                          desc: "Shanghai, CN • 10 Oct 2023, 09:30 AM",
                          isLast: false,
                          isActive: false),
                      _buildTimelineItem(
                          icon: Icons.sailing,
                          iconColor: primaryColor,
                          iconBg: primaryColor.withValues(alpha: 0.1),
                          title: "Zarpe de Buque",
                          desc: "Puerto Shanghai • 12 Oct 2023, 04:15 PM",
                          isLast: false,
                          isActive: false),
                      _buildTimelineItem(
                          icon: Icons.waves,
                          iconColor: Colors.black,
                          iconBg: primaryColor,
                          title: "En Tránsito",
                          desc: "Océano Pacífico • Actualizado hace 2h",
                          isLast: false,
                          isActive: true,
                          note:
                              "Buque navegando a velocidad normal. Sin retrasos."),
                      _buildTimelineItem(
                          icon: Icons.anchor,
                          iconColor: Colors.grey,
                          iconBg: const Color(0xFF1A212E),
                          title: "Arribo a Puerto",
                          desc: "Manzanillo, MX • Est. 24 Oct",
                          isLast: false,
                          isActive: false,
                          isPending: true),
                      _buildTimelineItem(
                          icon: Icons.local_shipping,
                          iconColor: Colors.grey,
                          iconBg: const Color(0xFF1A212E),
                          title: "Entrega Final",
                          desc: "Bodega Central • Est. 26 Oct",
                          isLast: true,
                          isActive: false,
                          isPending: true),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),

            // Technical Details Grid
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: const Color(0xFF111620),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10)),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.monitor_weight_outlined,
                              color: Colors.grey, size: 16),
                          SizedBox(width: 4),
                          Text("PESO TOTAL",
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold))
                        ]),
                        SizedBox(height: 8),
                        Text.rich(TextSpan(
                            text: "1,250 ",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                  text: "kg",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.grey))
                            ]))
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: const Color(0xFF111620),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10)),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.inventory_2_outlined,
                              color: Colors.grey, size: 16),
                          SizedBox(width: 4),
                          Text("PIEZAS",
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold))
                        ]),
                        SizedBox(height: 8),
                        Text.rich(TextSpan(
                            text: "450 ",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                  text: "un.",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.grey))
                            ]))
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),

            // Buttons
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.description),
                label: const Text("VER DOCUMENTOS",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.support_agent),
                label: const Text("CONTACTAR SOPORTE",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF1A212E),
                    side: const BorderSide(color: Colors.white10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
      {required IconData icon,
      required Color iconColor,
      required Color iconBg,
      required String title,
      required String desc,
      required bool isLast,
      required bool isActive,
      bool isPending = false,
      String? note}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Line & Icon
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isActive ? Colors.transparent : Colors.white10),
                    boxShadow: isActive
                        ? [
                            const BoxShadow(
                                color: AppColors.neonGreen,
                                blurRadius: 10,
                                spreadRadius: 1)
                          ]
                        : null),
                child: Center(child: Icon(icon, color: iconColor, size: 16)),
              ),
              if (!isLast)
                Expanded(
                    child: Container(
                        width: 2,
                        color:
                            isActive ? AppColors.neonGreen : Colors.white10)),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: isActive
                              ? AppColors.neonGreen
                              : (isPending ? Colors.white60 : Colors.white),
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(desc,
                      style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  if (note != null)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: AppColors.neonGreen.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color:
                                  AppColors.neonGreen.withValues(alpha: 0.2))),
                      child: Row(
                        children: [
                          const Icon(Icons.info,
                              color: AppColors.neonGreen, size: 14),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(note,
                                  style: const TextStyle(
                                      color: AppColors.neonGreen,
                                      fontSize: 11)))
                        ],
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
}
