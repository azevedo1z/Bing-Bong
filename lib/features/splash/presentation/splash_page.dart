import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/navigation/fade_route.dart';
import '../../../core/theme/peak_colors.dart';
import '../../character/presentation/character_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _fadeIn = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _fadeOut = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(fadeRoute(const CharacterPage()));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: PeakColors.deepPurple,
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) =>
              Opacity(opacity: _fadeIn.value * _fadeOut.value, child: child),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/bing-bong-app-opening.jpg',
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.0,
                      colors: [
                        Colors.transparent,
                        PeakColors.deepPurple.withValues(alpha: 0.5),
                        PeakColors.vignetteEdge.withValues(alpha: 0.85),
                      ],
                      stops: const [0.55, 0.85, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
