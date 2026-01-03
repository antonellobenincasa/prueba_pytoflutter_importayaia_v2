import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// AduanaExpertoIA - AI-powered customs expert assistant
/// This is a placeholder screen for the AI chat feature
class AduanaExpertoScreen extends StatefulWidget {
  const AduanaExpertoScreen({super.key});

  @override
  State<AduanaExpertoScreen> createState() => _AduanaExpertoScreenState();
}

class _AduanaExpertoScreenState extends State<AduanaExpertoScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add({
      'isUser': false,
      'text':
          '¡Hola! Soy AduanaExpertoIA, tu asistente experto en comercio exterior de Ecuador. ¿En qué puedo ayudarte hoy?\n\nPuedes preguntarme sobre:\n• Clasificación arancelaria (códigos HS)\n• Tributos de importación\n• Requisitos previos (INEN, ARCSA)\n• Documentación necesaria',
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'isUser': true, 'text': text});
      _isLoading = true;
    });
    _messageController.clear();

    // Simulate AI response (placeholder)
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'isUser': false,
            'text': _getPlaceholderResponse(text),
          });
          _isLoading = false;
        });
      }
    });
  }

  String _getPlaceholderResponse(String query) {
    final lowerQuery = query.toLowerCase();

    if (lowerQuery.contains('laptop') ||
        lowerQuery.contains('computadora') ||
        lowerQuery.contains('8471')) {
      return '📦 **Clasificación Sugerida: 8471.30.00**\n\n'
          '• **Producto:** Laptops y máquinas portátiles de procesamiento de datos\n'
          '• **Ad-Valorem:** 0%\n'
          '• **FODINFA:** 0.5%\n'
          '• **IVA:** 15%\n\n'
          '✅ No requiere permisos previos ARCSA/INEN para uso personal.';
    } else if (lowerQuery.contains('arancel') ||
        lowerQuery.contains('impuesto')) {
      return '📊 **Tributos de Importación en Ecuador:**\n\n'
          '• **Ad-Valorem:** Variable según partida (0% - 45%)\n'
          '• **FODINFA:** 0.5% del CIF\n'
          '• **IVA:** 15% sobre (CIF + AdValorem + FODINFA)\n'
          '• **ICE:** Aplica solo para ciertos productos\n\n'
          'La base de cálculo es el **Valor CIF** (Cost + Insurance + Freight).';
    } else if (lowerQuery.contains('hs') ||
        lowerQuery.contains('partida') ||
        lowerQuery.contains('clasificar')) {
      return '🔍 **Clasificación Arancelaria**\n\n'
          'Para clasificar tu producto, necesito conocer:\n\n'
          '1. Descripción detallada del producto\n'
          '2. Material principal de composición\n'
          '3. Función o uso principal\n'
          '4. Marca y modelo (si aplica)\n\n'
          'Escríbeme los detalles y te sugeriré el código HS apropiado.';
    } else {
      return '🤖 Estoy procesando tu consulta sobre:\n\n"$query"\n\n'
          'Para darte una respuesta más precisa, ¿podrías especificar:\n'
          '• Tipo de producto\n'
          '• País de origen\n'
          '• Uso final (comercial/personal)?\n\n'
          '**Nota:** Esta es una versión de demostración. En producción, conectaré con IA avanzada para respuestas en tiempo real.';
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgDark = Color(0xFF050A14);
    const primaryColor = AppColors.neonGreen;

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.smart_toy, color: primaryColor, size: 24),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("AduanaExpertoIA",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Tu asistente de comercio exterior",
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A101D),
              border:
                  Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Escribe tu consulta...",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: bgDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;
    const primaryColor = AppColors.neonGreen;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color:
              isUser ? primaryColor.withValues(alpha: 0.2) : const Color(0xFF111C2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUser
                ? primaryColor.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Text(
          message['text'],
          style: TextStyle(
            color: isUser ? primaryColor : Colors.white,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111C2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            _buildDot(1),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 150)),
      builder: (context, value, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.5 + (value * 0.5)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
