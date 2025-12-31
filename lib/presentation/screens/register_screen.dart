import 'package:flutter/material.dart';
import '../../config/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    // HTML uses 'bg-background-dark' for body, which maps to AppColors.darkBlueBackground
    // But the card itself is 'bg-white'.
    return Scaffold(
      backgroundColor: AppColors.darkBlueBackground,
      body: Stack(
        children: [
          // --- Background Gradient Blobs (Animated) ---
          // Top Left Blob
           Positioned(
            top: -100, // Approximate top: -10%
            left: -100, // Approximate left: -10%
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonGreen.withOpacity(0.05),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonGreen.withOpacity(0.05),
                    blurRadius: 120,
                    spreadRadius: 50,
                  )
                ]
              ),
            ),
          ),
          // Bottom Right Blob
          Positioned(
            bottom: -100, // Approximate bottom: -10%
            right: -100, // Approximate right: -10%
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.width * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonGreen.withOpacity(0.05),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonGreen.withOpacity(0.05),
                    blurRadius: 100,
                    spreadRadius: 40,
                  )
                ]
              ),
            ),
          ),

          // --- Main Content ---
          Center( // flex flex-col justify-center items-center
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24), // p-4 sm:p-6
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   // Card
                   Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 450), // max-w-[450px]
                    decoration: BoxDecoration(
                      color: Colors.white, // bg-white
                      borderRadius: BorderRadius.circular(16), // rounded-xl
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // shadow-2xl equivalent approx
                          blurRadius: 25,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    clipBehavior: Clip.hardEdge, // overflow-hidden
                    child: Column(
                      children: [
                        // Header Section
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16), // pt-8 pb-4 px-6
                          child: Column(
                            children: [
                              // Icon Circle
                              Container(
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFf7f8f5), // bg-background-light
                                  shape: BoxShape.circle,
                                   boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05) // shadow-inner approx (inset not supported directly easily on container, using slight shadow)
                                    )
                                   ]
                                ),
                                child: const Icon(Icons.person_add_alt_1, color: AppColors.neonGreen, size: 48),
                              ),
                              // Title
                              const Text(
                                "Crear tu cuenta",
                                style: TextStyle(
                                  color: Color(0xFF111827), // text-gray-900
                                  fontSize: 30, // text-3xl
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5, // tracking-tight
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Subtitle
                              const Text(
                                "Únete a la nueva era de la logística inteligente.",
                                style: TextStyle(
                                  color: Color(0xFF6B7280), // text-gray-500
                                  fontSize: 14, // text-sm
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Form Section
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32), // px-6 pb-8 pt-2
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Name Row
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInput(
                                      hintText: "Nombre", 
                                      padding: const EdgeInsets.only(right: 8),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildInput(
                                      hintText: "Apellido",
                                      padding: const EdgeInsets.only(left: 8),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16), // gap-4
                              
                              // Email
                              _buildInput(
                                hintText: "Correo", 
                                icon: Icons.mail_outline, 
                                keyboardType: TextInputType.emailAddress
                              ),
                              const SizedBox(height: 16),

                              // Company
                              _buildInput(
                                hintText: "Empresa", 
                                icon: Icons.domain
                              ),
                              const SizedBox(height: 16),

                              // Phone
                               _buildInput(
                                hintText: "Teléfono", 
                                icon: Icons.phone,
                                keyboardType: TextInputType.phone
                              ),
                              const SizedBox(height: 16),

                              // Password
                               _buildInput(
                                hintText: "Contraseña", 
                                icon: Icons.lock_outline,
                                isPassword: true,
                                obscureText: _obscurePassword,
                                onTogglePassword: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                }
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 6, left: 4),
                                child: Text(
                                  "Mínimo 8 caracteres",
                                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                ),
                              ),

                              const SizedBox(height: 32), // mt-4 (plus margins)

                              // Submit Button
                              ElevatedButton(
                                onPressed: () {
                                  // Action
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.neonGreen,
                                  foregroundColor: Colors.black,
                                  elevation: 5, // shadow
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  shadowColor: AppColors.neonGreen.withOpacity(0.4),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Crear Cuenta",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.check, size: 24, weight: 600), // Material Symbols weight adjustment not directly native, standard icon ok
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Already have account
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "¿Ya tienes cuenta? ",
                                    style: TextStyle(
                                      color: Color(0xFF6B7280), // text-gray-500
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/login');
                                    },
                                    child: const Text(
                                      "Inicia sesión",
                                      style: TextStyle(
                                        color: Color(0xFF1F2937), // text-gray-800
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.neonGreen,
                                        decorationThickness: 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Bottom Decor Line
                        Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.neonGreen, 
                                Colors.transparent
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            )
                          ),
                        )
                      ],
                    ),
                   ),

                   const SizedBox(height: 24),
                   const Text(
                    "IMPORTAYA.IA",
                    style: TextStyle(
                      color: Colors.white24,
                      fontSize: 12,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.bold,
                    ),
                   )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required String hintText,
    IconData? icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
  }) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label sr-only in HTML, so we skip visible label or keep it hidden/implicit
          // Input
          Container(
             decoration:BoxDecoration(
               // To match focus ring effect strictly we'd need more state, but standard InputDecoration focus border works reasonably well
             ),
             child: TextFormField(
              initialValue: "", // Clean slate
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: const TextStyle(
                color: Color(0xFF111827), // text-gray-900
                fontSize: 16,
              ),
              cursorColor: AppColors.neonGreen,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF9FAFB), // bg-gray-50
                hintText: hintText,
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)), // text-gray-400
                prefixIcon: icon != null 
                  ? Icon(icon, color: const Color(0xFF9CA3AF), size: 20) // text-gray-400
                  : null, 
                suffixIcon: isPassword 
                  ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF9CA3AF),
                      ),
                      onPressed: onTogglePassword,
                    )
                  : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // px-4 py-3.5
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)), // border-gray-200
                ),
                enabledBorder: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(8),
                   borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(8),
                   borderSide: const BorderSide(color: AppColors.neonGreen), // focus:border-primary
                ),
              ),
             ),
          ),
        ],
      ),
    );
  }
}