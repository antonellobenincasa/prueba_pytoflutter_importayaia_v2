import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/theme.dart';
import 'landing_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "image": "https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?ixlib=rb-4.0.3&auto=format&fit=crop&w=1470&q=80", // Warehouse/Logistics
      "title": "Cotizaciones con IA",
      "desc": "Obtén cotizaciones precisas de importación en segundos gracias a nuestra inteligencia artificial."
    },
    {
      "image": "https://images.unsplash.com/photo-1494412651409-ae5c8502cfa4?ixlib=rb-4.0.3&auto=format&fit=crop&w=1470&q=80", // Global shipping/Map
      "title": "Rastreo en Tiempo Real",
      "desc": "Monitorea tu carga 24/7 con actualizaciones en vivo desde origen hasta destino."
    },
    {
      "image": "https://images.unsplash.com/photo-1554224155-6726b3ff858f?ixlib=rb-4.0.3&auto=format&fit=crop&w=1511&q=80", // Calculator/Finance
      "title": "Cálculo de Impuestos",
      "desc": "Simula costos de aduana y logística antes de comprar. Sin sorpresas ocultas."
    },
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LandingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A14),
      body: Stack(
        children: [
          // Background Image with Gradient
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) => setState(() => _currentPage = page),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _pages[index]['image']!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(color: const Color(0xFF050A14));
                    },
                    errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF101622)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF050A14).withOpacity(0.3),
                          const Color(0xFF050A14).withOpacity(0.8),
                          const Color(0xFF050A14),
                        ],
                        stops: const [0.0, 0.6, 1.0]
                      )
                    ),
                  )
                ],
              );
            },
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header (Skip)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextButton(
                      onPressed: _finishOnboarding,
                      child: const Text("Saltar", style: TextStyle(color: Colors.white70)),
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Text Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                       FadeInUp(
                         key: ValueKey("title_$_currentPage"),
                         duration: const Duration(milliseconds: 600),
                         child: Text(
                           _pages[_currentPage]['title']!,
                           textAlign: TextAlign.center,
                           style: const TextStyle(
                             color: Colors.white,
                             fontSize: 32,
                             fontWeight: FontWeight.bold,
                             height: 1.1
                           ),
                         ),
                       ),
                       const SizedBox(height: 16),
                       FadeInUp(
                         key: ValueKey("desc_$_currentPage"),
                         delay: const Duration(milliseconds: 200),
                         duration: const Duration(milliseconds: 600),
                         child: Text(
                           _pages[_currentPage]['desc']!,
                           textAlign: TextAlign.center,
                           style: const TextStyle(
                             color: Colors.grey,
                             fontSize: 16,
                             height: 1.5
                           ),
                         ),
                       ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),

                // Indicators & Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Indicators
                      Row(
                        children: List.generate(_pages.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index ? AppColors.neonGreen : Colors.white24,
                              borderRadius: BorderRadius.circular(4)
                            ),
                          );
                        }),
                      ),

                      // Next Button
                      GestureDetector(
                        onTap: _onNext,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.neonGreen,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonGreen.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 5)
                              )
                            ]
                          ),
                          child: Icon(
                            _currentPage == _pages.length - 1 ? Icons.check : Icons.arrow_forward,
                            color: Colors.black,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
