import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'tax_calculator_screen.dart';
import 'quote_request_screen.dart';
import '../../config/theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      "isUser": false,
      "text":
          "Hola. Soy tu asistente de aduanas de ImportaYA.ia. ¿En qué puedo ayudarte con tu importación hoy?",
      "time": "10:30 AM",
      "actions": []
    },
    {
      "isUser": true,
      "text": "¿Qué impuestos paga la importación de laptops?",
      "time": "10:31 AM",
      "actions": []
    },
    {
      "isUser": false,
      "text":
          "Las laptops generalmente pagan 0% de Arancel Advalorem, pero están sujetas al IVA del 19% (dependiendo del país de destino).\n\n¿Deseas ver la partida arancelaria específica o calcular el costo total?",
      "time": "10:31 AM",
      "actions": ["Ver partida arancelaria", "Calcular impuestos"]
    },
    {
      "isUser": true,
      "text":
          "También quiero traer unos monitores gaming. ¿Tienen restricciones?",
      "time": "10:33 AM",
      "actions": []
    },
  ];

  final bool _isTyping = true;

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppColors.neonGreen; // #a2f40b
    const bgDark = Color(0xFF050A14);

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark.withValues(alpha: 0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient:
                          LinearGradient(colors: [Colors.grey, Colors.black])),
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Color(0xFF111827), shape: BoxShape.circle),
                    child: const Icon(Icons.smart_toy,
                        color: primaryColor, size: 20),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: bgDark, width: 2)),
                  ),
                )
              ],
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("AduanaExpertoIA",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text("En línea",
                    style: TextStyle(
                        color: primaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w500)),
              ],
            )
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onPressed: () {})
        ],
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: Colors.white10, height: 1)),
      ),
      body: Column(
        children: [
          // Messages Area
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                // Divider "Hoy"
                if (index == 0) {
                  return Column(
                    children: [
                      Center(
                          child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Text("Hoy",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 10)))),
                      _buildMessageRow(_messages[index])
                    ],
                  );
                }

                // Typing Indicator
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }

                return _buildMessageRow(_messages[index]);
              },
            ),
          ),

          // Suggestion Chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildSuggestionChip(Icons.gavel, "Regulaciones"),
                _buildSuggestionChip(Icons.calculate, "Calculadora"),
                _buildSuggestionChip(Icons.price_check, "Simulador Costos"),
                _buildSuggestionChip(Icons.description, "Documentación"),
                _buildSuggestionChip(Icons.warning, "Restricciones"),
              ],
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
                color: bgDark,
                border: Border(top: BorderSide(color: Colors.white10))),
            child: Row(
              children: [
                IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.grey),
                    onPressed: () {}),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color(0xFF1F2937),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white10)),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          hintText: "Escribe tu consulta aquí...",
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                            color: primaryColor.withValues(alpha: 0.2),
                            blurRadius: 10)
                      ]),
                  child: IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFF050A14)),
                      onPressed: () {}),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMessageRow(Map<String, dynamic> msg) {
    bool isUser = msg['isUser'];
    List<String> actions = (msg['actions'] as List).cast<String>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                  color: Color(0xFF1F2937), shape: BoxShape.circle),
              child: const Icon(Icons.smart_toy,
                  size: 16, color: AppColors.neonGreen),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: isUser
                          ? AppColors.neonGreen
                          : const Color(0xFF1F2937),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft:
                            isUser ? const Radius.circular(16) : Radius.zero,
                        bottomRight:
                            isUser ? Radius.zero : const Radius.circular(16),
                      ),
                      border:
                          isUser ? null : Border.all(color: Colors.white10)),
                  child: Text(
                    msg['text'],
                    style: TextStyle(
                        color:
                            isUser ? const Color(0xFF050A14) : Colors.white70,
                        fontSize: 14),
                  ),
                ),
                if (!isUser && actions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: actions
                          .map((a) => InkWell(
                                onTap: () {
                                  if (a == "Calcular impuestos") {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const TaxCalculatorScreen()));
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.05),
                                      border: Border.all(color: Colors.white10),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Text(a,
                                      style: const TextStyle(
                                          color: AppColors.neonGreen,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Text(msg['time'],
                      style: const TextStyle(color: Colors.grey, fontSize: 10)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
                color: Color(0xFF1F2937), shape: BoxShape.circle),
            child: const Icon(Icons.smart_toy,
                size: 16, color: AppColors.neonGreen),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1F2937),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeIn(
                    duration: const Duration(milliseconds: 600), child: _dot()),
                const SizedBox(width: 4),
                FadeIn(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 600),
                    child: _dot()),
                const SizedBox(width: 4),
                FadeIn(
                    delay: const Duration(milliseconds: 400),
                    duration: const Duration(milliseconds: 600),
                    child: _dot()),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _dot() => Container(
      width: 6,
      height: 6,
      decoration:
          BoxDecoration(color: Colors.grey.shade600, shape: BoxShape.circle));

  Widget _buildSuggestionChip(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 16, color: AppColors.neonGreen),
        label: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 12)),
        backgroundColor: const Color(0xFF1F2937),
        shape: const StadiumBorder(side: BorderSide(color: Colors.white10)),
        onPressed: () {
          if (label == "Calculadora") {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const TaxCalculatorScreen()));
          } else if (label == "Simulador Costos") {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const QuoteRequestScreen()));
          } else {
            setState(() => _controller.text = label);
          }
        },
      ),
    );
  }
}
