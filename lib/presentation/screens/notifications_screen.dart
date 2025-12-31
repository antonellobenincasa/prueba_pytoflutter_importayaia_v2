import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'tracking_screen.dart';
import 'quote_detail_screen.dart';
import 'package:animate_do/animate_do.dart';
import '../widgets/transport_icon.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFA2F40B);
    const bgDark = Color(0xFF050A14);
    const surfaceDark = Color(0xFF111827);
    const textGrey = Color(0xFF9CA3AF);

    final List<Map<String, dynamic>> notifications = [
      {
        "type": "shipping",
        "title": "Carga Arribada a Puerto",
        "body": "Tu envío #IMP-2023-001 ha llegado al Puerto de Guayaquil.",
        "time": "Hace 2 horas",
        "read": false,
        "date": "Hoy"
      },
      {
        "type": "quote",
        "title": "Cotización Aprobada",
        "body": "La cotización #COT-2023-8492 ha sido aprobada exitosamente.",
        "time": "Hace 5 horas",
        "read": true,
        "date": "Hoy"
      },
      {
        "type": "promo",
        "title": "Descuento en Fletes Aéreos",
        "body": "Obtén un 20% de descuento en tu próximo envío aéreo desde Miami.",
        "time": "Ayer",
        "read": true,
        "date": "Ayer"
      },
      {
        "type": "shipping",
        "title": "Retraso en Aduana",
        "body": "Tu envío #IMP-2023-089 está en revisión física. Se estima 2 días de demora.",
        "time": "Ayer",
        "read": true,
        "date": "Ayer"
      },
    ];

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Notificaciones", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.done_all, color: primaryColor), onPressed: (){})
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          final showHeader = index == 0 || notifications[index - 1]['date'] != notif['date'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showHeader)
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(notif['date'], style: TextStyle(color: textGrey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                ),
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: Duration(milliseconds: index * 100),
                child: _buildNotificationItem(context, notif, surfaceDark, primaryColor, textGrey),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, Map<String, dynamic> notif, Color bg, Color primary, Color grey) {
    IconData icon;
    Color iconColor;
    Color iconBg;
    VoidCallback onTap;

    switch (notif['type']) {
      case 'shipping':
        icon = Icons.local_shipping;
        iconColor = primary;
        iconBg = primary.withOpacity(0.1);
        onTap = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackingScreen()));
        break;
      case 'quote':
        icon = Icons.request_quote;
        iconColor = Colors.blueAccent;
        iconBg = Colors.blueAccent.withOpacity(0.1);
        onTap = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuoteDetailScreen()));
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.orangeAccent;
        iconBg = Colors.orangeAccent.withOpacity(0.1);
        onTap = () {};
    }

    Widget leadingIcon;
    if (notif['type'] == 'shipping') {
       TransportType type = TransportType.maritimeFCL;
       if (notif['body'].toString().toLowerCase().contains('aéreo')) {
         type = TransportType.air;
       } else if (notif['title'].toString().toLowerCase().contains('retraso')) {
         type = TransportType.maritimeLCL; // Example variation
       }
       leadingIcon = TransportIcon(type: type, size: 20);
    } else {
       leadingIcon = Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 20),
      );
    }

    return Dismissible(
      key: UniqueKey(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.red),
      ),
      direction: DismissDirection.endToStart,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notif['read'] ? Colors.transparent : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10)
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leadingIcon,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(notif['title'], style: TextStyle(color: Colors.white, fontWeight: notif['read'] ? FontWeight.NORMAL : FontWeight.bold, fontSize: 14)),
                        if (!notif['read']) Container(width: 8, height: 8, decoration: BoxDecoration(color: primary, shape: BoxShape.circle))
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(notif['body'], style: TextStyle(color: grey, fontSize: 12, height: 1.4)),
                    const SizedBox(height: 8),
                    Text(notif['time'], style: TextStyle(color: grey.withOpacity(0.5), fontSize: 10)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
