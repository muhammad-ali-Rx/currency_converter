import 'dart:async';
import 'package:currency_converter/screen/register.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;

  late List<AnimationController> _symbolControllers;
  late List<Animation<Offset>> _symbolOffsetAnimations;

  final List<String> _currencySymbols = ['€', '\$', '£', '¥', '₹'];

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoScaleAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );

    _logoRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _symbolControllers = List.generate(
      _currencySymbols.length,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 800 + (index * 150)),
      ),
    );

    _symbolOffsetAnimations = List.generate(
      _currencySymbols.length,
      (index) => Tween<Offset>(
        begin: const Offset(0, -1.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _symbolControllers[index],
        curve: Curves.easeOutBack,
      )),
    );

    _logoController.forward();

    for (int i = 0; i < _symbolControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 300 + (i * 200)), () {
        if (mounted) _symbolControllers[i].forward();
      });
    }

    Timer(const Duration(milliseconds: 5000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const RegisterScreen(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 700),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    for (var controller in _symbolControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo
                ScaleTransition(
                  scale: _logoScaleAnimation,
                  child: RotationTransition(
                    turns: _logoRotationAnimation,
                    child: Container(
                      height: 130,
                      width: 130,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.currency_exchange,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // App Name
                FadeTransition(
                  opacity: _logoScaleAnimation,
                  child: const Text(
                    'Currency Converter',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF004D40),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Animated Currency Symbols
                SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _currencySymbols.length,
                      (index) => SlideTransition(
                        position: _symbolOffsetAnimations[index],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            _currencySymbols[index],
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                              shadows: [
                                Shadow(
                                  blurRadius: 4,
                                  color: Colors.black26,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Custom Loading Bar
                FadeTransition(
                  opacity: _logoScaleAnimation,
                  child: Container(
                    width: 200,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00796B)),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Optional Tagline
                const Text(
                  "Empowering your exchange experience",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
