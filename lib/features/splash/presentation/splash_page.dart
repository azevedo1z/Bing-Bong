import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/navigation/fade_route.dart';
import '../../character/presentation/character_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _fadeIn;
  late final CurvedAnimation _fadeOut;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    );

    _fadeOut = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
    );

    _controller.forward().then((_) {
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(fadeRoute<void>(const CharacterPage()));
    });
  }

  @override
  void dispose() {
    _fadeIn.dispose();
    _fadeOut.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Opacity(
            opacity: _fadeIn.value * (1 - _fadeOut.value),
            child: child,
          ),
          child: const Stack(
            fit: StackFit.expand,
            children: [
              Image(
                image: AssetImage('assets/images/bing-bong-app-opening.jpg'),
                fit: BoxFit.contain,
              ),
              _Vignette(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Vignette extends StatelessWidget {
  const _Vignette();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            radius: 1.0,
            colors: [Colors.transparent, Color(0x8C000000), Colors.black],
            stops: [0.5, 0.82, 1.0],
          ),
        ),
      ),
    );
  }
}
