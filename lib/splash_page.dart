import 'package:flutter/material.dart';
import 'home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double opacidade = 0;

  @override
  void initState() {
    super.initState();
    // entrada
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => opacidade = 1);
    });
    // saída
    Future.delayed(const Duration(milliseconds: 2300), () {
      if (mounted) setState(() => opacidade = 0);
    });
    // vai para a Home
    Future.delayed(const Duration(milliseconds: 3300), () {
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomePage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: AnimatedOpacity(
          opacity: opacidade,
          duration: const Duration(seconds: 1),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.directions_walk, size: 100, color: Colors.white),
              Text('Caminhadas',
                  style: TextStyle(fontSize: 28, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}