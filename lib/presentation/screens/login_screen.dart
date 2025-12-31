import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/api/auth_repository.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final username = _userController.text;
    final password = _passController.text;

    try {
      // Llamamos a tu Backend Django
      bool success = await _authRepository.login(username, password);

      if (success) {
        // Si el login es correcto, ir al Home
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Usuario o contraseña incorrectos';
        });
      }
    } catch (e) {
      setState(() {
         // Displaying a more user friendly error message if possible or just the exception
        _errorMessage = 'Error de conexión: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // HTML uses 'bg-background-light dark:bg-background-dark' -> we assume dark mode as primary for this flutter app theme or based on toggle.
    // Given the previous screens, we are leaning towards the dark theme implementation (bg-[#050A14]).
    
    return Scaffold(
      backgroundColor: AppColors.darkBlueBackground,
      body: Stack(
        children: [
          // Background Blobs
          // Top Right
           Positioned(
            top: -80,
            right: -80,
            child: FadeIn(
              duration: const Duration(seconds: 2),
              child: Container(
                width: 256,
                height: 256,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonGreen.withOpacity(0.05),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonGreen.withOpacity(0.05),
                      blurRadius: 80,
                       spreadRadius: 40,
                    )
                  ]
                ),
              ),
            ),
          ),
          // Bottom Left
           Positioned(
            bottom: -80,
            left: -80,
            child: FadeIn(
               duration: const Duration(seconds: 2),
              child: Container(
                width: 192,
                height: 192,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(0.1),
                   boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 60,
                      spreadRadius: 30,
                    )
                  ]
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header
                    _buildHeader(),
                    
                    const SizedBox(height: 32), // approx gap-5 equivalent + header padding

                    // Form
                     _buildForm(),

                    const SizedBox(height: 32), // Footer padding

                    // Footer
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Row(
           mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.neonGreen,
                borderRadius: BorderRadius.circular(4), // rounded
              ),
              child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF111C2E), size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              "ImportaYA.ia",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20, // text-xl
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32), // mb-8 in header
        
        // Welcome Text
        const Text(
          "Bienvenido",
          style: TextStyle(
            color: Colors.white,
            fontSize: 36, // text-4xl
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12), // mb-3
        Text(
          "Inicia sesión en ImportaYa.ia",
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_errorMessage != null)
           Container(
             width: double.infinity,
             padding: const EdgeInsets.all(12),
             margin: const EdgeInsets.only(bottom: 20),
             decoration: BoxDecoration(
               color: Colors.red.withOpacity(0.1),
               borderRadius: BorderRadius.circular(8),
               border: Border.all(color: Colors.red.withOpacity(0.3)),
             ),
             child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)),
           ),

        // Email
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text("Correo Electrónico", style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14, fontWeight: FontWeight.w500)),
        ),
        Container(
           decoration: BoxDecoration(
             // box shadow for glow if focused? standard input decoration handles focus border
           ),
           child: TextField(
            controller: _userController,
            style: const TextStyle(color: Colors.white),
            cursorColor: AppColors.neonGreen,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF151f2e), // bg-surface-input
              hintText: "nombre@ejemplo.com",
              hintStyle: TextStyle(color: Colors.grey[600]),
              suffixIcon: const Icon(Icons.mail_outline, color: Color(0xFF6B7280)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18), // h-14 approx
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), // rounded-xl
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                 borderSide: const BorderSide(color: AppColors.neonGreen),
              ),
            ),
           ),
        ),
        
        const SizedBox(height: 20),

        // Password
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text("Contraseña", style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14, fontWeight: FontWeight.w500)),
        ),
         Container(
           child: TextField(
            controller: _passController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: Colors.white),
            cursorColor: AppColors.neonGreen,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF151f2e),
              hintText: "••••••••",
              hintStyle: TextStyle(color: Colors.grey[600]),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: const Color(0xFF6B7280)
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                 borderSide: const BorderSide(color: AppColors.neonGreen),
              ),
            ),
           ),
        ),

        const SizedBox(height: 12),

        // Remember Me & Forgot Password
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: Checkbox(
                    value: _rememberMe, 
                    onChanged: (v) => setState(() => _rememberMe = v!),
                    activeColor: AppColors.neonGreen,
                    checkColor: AppColors.darkBlueBackground,
                    side: const BorderSide(color: Color(0xFF4B5563)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 8),
                const Text("Recordarme", style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
              ],
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/forgot_password'),
              child: const Text("¿Olvidaste tu contraseña?", style: TextStyle(color: AppColors.neonGreen, fontSize: 14, fontWeight: FontWeight.w500)),
            )
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Login Button
        SizedBox(
          width: double.infinity,
          height: 56, // h-14
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonGreen,
              foregroundColor: const Color(0xFF111C2E), // text-on-primary
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // rounded-xl
              ),
              elevation: 0,
              // Shadow managed by Container usually but here standard elevation ok or custom shadow via Container
            ),
            child: _isLoading 
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Color(0xFF111C2E))) 
                : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Text(
                      "Iniciar Sesión",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("¿No tienes cuenta? ", style: TextStyle(color: Colors.grey[400], fontSize: 14)),
            GestureDetector(
              onTap: () {
                 Navigator.pushReplacementNamed(context, '/registro'); // Go to Register
              },
              child: const Text(
                "Crear cuenta nueva",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/'); // Back to Home (Landing)
          },
          icon: const Icon(Icons.arrow_back, size: 18, color: Color(0xFF6B7280)),
          label: const Text("Volver al inicio", style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w500)),
        )
      ],
    );
  }
}