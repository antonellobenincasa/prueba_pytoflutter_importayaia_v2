import 'package:flutter/material.dart';
import '../../config/theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;

  void _submit() async {
    if (_emailController.text.isEmpty) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppColors.neonGreen;
    const bgDark = Color(0xFF050A14);
    
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _isSuccess 
            ? _buildSuccessView(context) 
            : _buildFormView(primaryColor),
      ),
    );
  }

  Widget _buildFormView(Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Icon(Icons.lock_reset, color: Colors.white, size: 48),
        const SizedBox(height: 24),
        const Text(
          "Recuperar\nContraseña",
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1.1
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Ingresa tu correo electrónico asociado a tu cuenta y te enviaremos las instrucciones para restablecer tu contraseña.",
          style: TextStyle(color: Colors.grey[400], fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 40),
        
        // Input
        const Text("Email", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111620), 
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10)
          ),
          child: TextField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "ejemplo@correo.com",
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14)
            ),
          ),
        ),

        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              disabledBackgroundColor: primary.withOpacity(0.5)
            ),
            child: _isLoading 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) 
                : const Text("Enviar Instrucciones", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        )
      ],
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.neonGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_read, size: 64, color: AppColors.neonGreen),
          ),
          const SizedBox(height: 32),
          const Text(
            "¡Correo Enviado!",
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            "Hemos enviado las instrucciones a ${_emailController.text}.\nPor favor revisa tu bandeja de entrada.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400], height: 1.5),
          ),
          const SizedBox(height: 40),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Volver al Login", style: TextStyle(color: AppColors.neonGreen, fontSize: 16, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}
