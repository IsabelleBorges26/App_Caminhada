import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart';
import 'caminhada.dart';
import 'storage.dart';
import 'splash_page.dart';
import 'nova_page.dart';
import 'detalhes_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Caminhada> lista = [];

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    final dados = await listarCaminhadas();
    setState(() => lista = dados);
  }

  @override
  Widget build(BuildContext context) {
    final claro = temaNotifier.value == ThemeMode.light;

    return Scaffold(
      appBar: AppBar(title: const Text('Caminhadas')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text('Menu', style: TextStyle(fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.play_circle),
              title: const Text('Splash'),
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const SplashPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: Text(claro ? 'Tema Escuro' : 'Tema Claro'),
              onTap: () {
                temaNotifier.value = claro ? ThemeMode.dark : ThemeMode.light;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sair'),
              onTap: () => SystemNavigator.pop(),
            ),
          ],
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2),
        itemCount: lista.length,
        itemBuilder: (context, i) {
          final c = lista[i];
          return Card(
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DetalhesPage(caminhada: c)));
                carregar();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  c.foto != null
                      ? Image.file(File(c.foto!),
                          height: 90, width: 90, fit: BoxFit.cover)
                      : const Icon(Icons.directions_walk, size: 70),
                  const SizedBox(height: 8),
                  Text(c.titulo),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
              context, MaterialPageRoute(builder: (_) => const NovaPage()));
          carregar();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}