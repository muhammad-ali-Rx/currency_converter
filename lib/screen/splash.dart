import 'dart:async';
import 'dart:math' as math;
import 'package:currency_converter/screen/register.dart';
import 'package:flutter/material.dart';

class UniqueSplashScreen extends StatefulWidget {
  const UniqueSplashScreen({super.key});

  @override
  State<UniqueSplashScreen> createState() => _UniqueSplashScreenState();
}

class _UniqueSplashScreenState extends State<UniqueSplashScreen>
    with TickerProviderStateMixin {
  
  // Animation Controllers
  late AnimationController _mainController;
  late AnimationController _logoController;
  late AnimationController _particleController;
  late AnimationController _textController;
  late AnimationController _progressController;
  
  // Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _logoGlow;
  late Animation<double> _textFade;
  late Animation<double> _textSlide;
  late Animation<double> _progressValue;
  late Animation<Color?> _backgroundGradient;
  
  // Currency symbols with animations
  final List<String> _currencySymbols = ['€', '\$', '£', '¥', '₹', '₿', '₽', '₩'];
  late List<AnimationController> _symbolControllers;
  late List<Animation<Offset>> _symbolAnimations;
  late List<Animation<double>> _symbolRotations;
  late List<Animation<double>> _symbolOpacity;
  
  // Particle system
  final List<Particle> _particles = [];
  late Timer _particleTimer;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeParticles();
    _startAnimationSequence();
    _navigateToNextScreen();
  }

  void _initializeAnimations() {
    // Main controller for overall timing
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );
    
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    
    _logoRotation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
      ),
    );
    
    _logoGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _textSlide = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    
    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Background gradient animation
    _backgroundGradient = ColorTween(
      begin: const Color(0xFF0F0F23),
      end: const Color(0xFF1A1A2E),
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Particle controller
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..repeat();
    
    // Currency symbol animations
    _symbolControllers = List.generate(
      _currencySymbols.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 1000 + (index * 100)),
        vsync: this,
      ),
    );
    
    _symbolAnimations = List.generate(
      _currencySymbols.length,
      (index) => Tween<Offset>(
        begin: Offset(
          (math.Random().nextDouble() - 0.5) * 4,
          -2.0,
        ),
        end: Offset(
          (math.Random().nextDouble() - 0.5) * 0.5,
          0.0,
        ),
      ).animate(
        CurvedAnimation(
          parent: _symbolControllers[index],
          curve: Curves.easeOutBack,
        ),
      ),
    );
    
    _symbolRotations = List.generate(
      _currencySymbols.length,
      (index) => Tween<double>(
        begin: 0.0,
        end: (math.Random().nextDouble() - 0.5) * 4,
      ).animate(_symbolControllers[index]),
    );
    
    _symbolOpacity = List.generate(
      _currencySymbols.length,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _symbolControllers[index],
          curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
        ),
      ),
    );
  }

  void _initializeParticles() {
    // Create initial particles
    for (int i = 0; i < 20; i++) {
      _particles.add(Particle());
    }
    
    // Timer to update particles
    _particleTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) {
        setState(() {
          for (var particle in _particles) {
            particle.update();
          }
          
          // Add new particles occasionally
          if (math.Random().nextDouble() < 0.1) {
            _particles.add(Particle());
          }
          
          // Remove old particles
          _particles.removeWhere((particle) => particle.isDead);
        });
      }
    });
  }

  void _startAnimationSequence() {
    // Start logo animation
    _logoController.forward();
    
    // Start text animation after delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _textController.forward();
    });
    
    // Start symbol animations with staggered delay
    for (int i = 0; i < _symbolControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 1200 + (i * 150)), () {
        if (mounted) _symbolControllers[i].forward();
      });
    }
    
    // Start progress animation
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _progressController.forward();
    });
    
    // Start main controller
    _mainController.forward();
  }

  void _navigateToNextScreen() {
    Timer(const Duration(milliseconds: 5000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const RegisterScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.3),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _logoController.dispose();
    _particleController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _particleTimer.cancel();
    
    for (var controller in _symbolControllers) {
      controller.dispose();
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _mainController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0F0F23),
                  _backgroundGradient.value ?? const Color(0xFF0F0F23),
                  const Color.fromARGB(255, 10, 108, 236).withOpacity(0.1),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Animated background pattern
                _buildBackgroundPattern(),
                
                // Floating particles
                _buildParticles(),
                
                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated currency symbols background
                      _buildFloatingSymbols(),
                      
                      const SizedBox(height: 40),
                      
                      // Main logo with glow effect
                      _buildAnimatedLogo(),
                      
                      const SizedBox(height: 40),
                      
                      // App name with slide animation
                      _buildAnimatedTitle(),
                      
                      const SizedBox(height: 20),
                      
                      // Subtitle
                      _buildSubtitle(),
                      
                      const SizedBox(height: 50),
                      
                      // Custom progress indicator
                      _buildProgressIndicator(),
                      
                      const SizedBox(height: 30),
                      
                      // Loading text
                      _buildLoadingText(),
                    ],
                  ),
                ),
                
                // Version info
                _buildVersionInfo(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: BackgroundPatternPainter(_mainController.value),
      ),
    );
  }

  Widget _buildParticles() {
    return Positioned.fill(
      child: CustomPaint(
        painter: ParticlePainter(_particles),
      ),
    );
  }

  Widget _buildFloatingSymbols() {
    return SizedBox(
      height: 100,
      child: Stack(
        children: List.generate(
          _currencySymbols.length,
          (index) => AnimatedBuilder(
            animation: _symbolControllers[index],
            builder: (context, child) {
              return Positioned(
                left: MediaQuery.of(context).size.width * 0.1 + (index * 40.0),
                top: 20,
                child: SlideTransition(
                  position: _symbolAnimations[index],
                  child: RotationTransition(
                    turns: _symbolRotations[index],
                    child: FadeTransition(
                      opacity: _symbolOpacity[index],
                      child: Text(
                        _currencySymbols[index],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.6),
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.3),
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return ScaleTransition(
          scale: _logoScale,
          child: RotationTransition(
            turns: _logoRotation,
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 10, 108, 236),
                    Color(0xFF44A08D),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.4 * _logoGlow.value),
                    blurRadius: 30 * _logoGlow.value,
                    spreadRadius: 5 * _logoGlow.value,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.currency_exchange_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTitle() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _textSlide.value),
          child: FadeTransition(
            opacity: _textFade,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color.fromARGB(255, 10, 108, 236),
                  Color(0xFF44A08D),
                  Colors.white,
                ],
              ).createShader(bounds),
              child: const Text(
                'Currency Converter',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubtitle() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _textFade,
          child: const Text(
            'Real-time Exchange • Smart Alerts • Portfolio Tracking',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF8A94A6),
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        return Container(
          width: 250,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Stack(
            children: [
              Container(
                width: 250 * _progressValue.value,
                height: 4,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 10, 108, 236),
                      Color(0xFF44A08D),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 10, 108, 236).withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingText() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        final loadingTexts = [
          'Initializing...',
          'Loading currencies...',
          'Fetching rates...',
          'Almost ready...',
          'Welcome!',
        ];
        
        final index = (_progressValue.value * (loadingTexts.length - 1)).round();
        
        return FadeTransition(
          opacity: _textFade,
          child: Text(
            loadingTexts[index],
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8A94A6),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }

  Widget _buildVersionInfo() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _textController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _textFade,
            child: const Text(
              'v2.1.0',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF8A94A6),
              ),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }
}

// Particle class for floating effect
class Particle {
  late double x;
  late double y;
  late double vx;
  late double vy;
  late double life;
  late double maxLife;
  late Color color;
  late double size;

  Particle() {
    final random = math.Random();
    x = random.nextDouble() * 400;
    y = 600 + random.nextDouble() * 100;
    vx = (random.nextDouble() - 0.5) * 2;
    vy = -random.nextDouble() * 3 - 1;
    maxLife = life = random.nextDouble() * 100 + 50;
    
    final colors = [
      const Color.fromARGB(255, 10, 108, 236),
      const Color(0xFF44A08D),
      Colors.white,
    ];
    color = colors[random.nextInt(colors.length)];
    size = random.nextDouble() * 3 + 1;
  }

  void update() {
    x += vx;
    y += vy;
    life--;
    
    // Add some drift
    vx += (math.Random().nextDouble() - 0.5) * 0.1;
    vy += (math.Random().nextDouble() - 0.5) * 0.1;
  }

  bool get isDead => life <= 0 || y < -50;
  
  double get opacity => (life / maxLife).clamp(0.0, 1.0);
}

// Custom painter for particles
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * 0.6)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter for background pattern
class BackgroundPatternPainter extends CustomPainter {
  final double animationValue;

  BackgroundPatternPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 10, 108, 236).withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final spacing = 30.0;
    final offset = animationValue * spacing;

    // Draw animated grid pattern
    for (double x = -spacing + offset % spacing; x < size.width + spacing; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = -spacing + offset % spacing; y < size.height + spacing; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}