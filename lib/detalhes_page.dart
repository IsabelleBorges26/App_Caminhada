import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'caminhada.dart';
import 'storage.dart';

class DetalhesPage extends StatefulWidget {
  final Caminhada caminhada;
  const DetalhesPage({super.key, required this.caminhada});

  @override
  State<DetalhesPage> createState() => _DetalhesPageState();
}

class _DetalhesPageState extends State<DetalhesPage> {
  late Caminhada c;

  @override
  void initState() {
    super.initState();
    c = widget.caminhada;
  }

  Future<void> tirarFoto() async {
    final picker = ImagePicker();
    final foto = await picker.pickImage(source: ImageSource.camera);
    if (foto == null) return;

    setState(() => c.foto = foto.path);
    await atualizarCaminhada(c);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(c.titulo)),
      body: Column(
        children: [
          // foto ou ícone da câmera
          SizedBox(
            height: 180,
            width: double.infinity,
            child: c.foto != null
                ? Image.file(File(c.foto!), fit: BoxFit.cover)
                : IconButton(
                    icon: const Icon(Icons.camera_alt, size: 70),
                    onPressed: tirarFoto,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
                'Caminhou uma distância de ${c.distancia.round()}m queimando cerca de ${c.calorias} calorias, em ${c.tempo} min'),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(initialCenter: c.origem, initialZoom: 16),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.caminhadas',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(points: c.trajeto, strokeWidth: 4, color: Colors.blue),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: c.origem,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.my_location,
                          color: Colors.blue, size: 40),
                    ),
                    Marker(
                      point: c.destino,
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