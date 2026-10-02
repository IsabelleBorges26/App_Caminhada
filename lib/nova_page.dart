import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'caminhada.dart';
import 'storage.dart';

class NovaPage extends StatefulWidget {
  const NovaPage({super.key});

  @override
  State<NovaPage> createState() => _NovaPageState();
}

class _NovaPageState extends State<NovaPage> {
  LatLng? origem;
  LatLng? destino;
  List<LatLng> trajeto = [];
  double distancia = 0;
  final tituloController = TextEditingController();

  int get calorias => (distancia * 0.065).round();

  int get tempo {
    final t = (distancia / 83).round();
    return t < 1 ? 1 : t;
  }

  @override
  void initState() {
    super.initState();
    pegarLocalizacao();
  }

  Future<void> pegarLocalizacao() async {
    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    if (permissao == LocationPermission.denied ||
        permissao == LocationPermission.deniedForever) {
      // sem permissão: usa o SESI Amparo (ponto do exemplo)
      setState(() => origem = LatLng(-22.713, -46.818));
      return;
    }
    final pos = await Geolocator.getCurrentPosition();
    setState(() => origem = LatLng(pos.latitude, pos.longitude));
  }

  // clicou no mapa: define o destino e traça o trajeto
  Future<void> escolherDestino(LatLng ponto) async {
    setState(() => destino = ponto);

    final url = 'https://routing.openstreetmap.de/routed-foot/route/v1/foot/'
        '${origem!.longitude},${origem!.latitude};${ponto.longitude},${ponto.latitude}'
        '?overview=full&geometries=geojson';

    try {
      final resp = await http.get(Uri.parse(url));
      final json = jsonDecode(resp.body);
      final rota = json['routes'][0];
      final coords = rota['geometry']['coordinates'] as List;
      setState(() {
        distancia = (rota['distance'] as num).toDouble();
        trajeto = coords
            .map((p) => LatLng((p[1] as num).toDouble(), (p[0] as num).toDouble()))
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível traçar o trajeto')),
      );
    }
  }

  void abrirModal() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Caminhou uma distância de ${distancia.round()}m queimando cerca de $calorias calorias'),
            const SizedBox(height: 15),
            TextField(
              controller: tituloController,
              decoration: const InputDecoration(
                labelText: 'Título da caminhada',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(onPressed: salvar, child: const Text('Salvar')),
        ],
      ),
    );
  }

  Future<void> salvar() async {
    if (tituloController.text.trim().isEmpty) return;

    final c = Caminhada(
      id: DateTime.now().millisecondsSinceEpoch,
      titulo: tituloController.text,
      origem: origem!,
      destino: destino!,
      trajeto: trajeto,
      distancia: distancia,
      calorias: calorias,
      tempo: tempo,
    );
    await salvarCaminhada(c);

    if (!mounted) return;
    Navigator.pop(context); // fecha o modal
    Navigator.pop(context); // volta para a Home
  }

  @override
  Widget build(BuildContext context) {
    if (origem == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova caminhada'),
        actions: [
          if (destino != null && trajeto.isNotEmpty)
            TextButton(onPressed: abrirModal, child: const Text('Salvar')),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(destino == null
                ? 'Clique no destino da sua caminhada'
                : 'Vai percorrer uma distância de ${distancia.round()}m, queimando cerca de $calorias calorias, em cerca de $tempo min'),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: origem!,
                initialZoom: 16,
                onTap: (tapPosition, ponto) => escolherDestino(ponto),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.caminhadas',
                ),
                if (trajeto.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(points: trajeto, strokeWidth: 4, color: Colors.blue),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: origem!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.my_location,
                          color: Colors.blue, size: 40),
                    ),
                    if (destino != null)
                      Marker(
                        point: destino!,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_on,
                            color: Colors.red, size: 40),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}