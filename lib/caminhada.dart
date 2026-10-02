import 'package:latlong2/latlong.dart';

class Caminhada {
  int id;
  String titulo;
  LatLng origem;
  LatLng destino;
  List<LatLng> trajeto;
  double distancia;
  int calorias;
  int tempo;
  String? foto;

  Caminhada({
    required this.id,
    required this.titulo,
    required this.origem,
    required this.destino,
    required this.trajeto,
    required this.distancia,
    required this.calorias,
    required this.tempo,
    this.foto,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': titulo,
        'origem': [origem.latitude, origem.longitude],
        'destino': [destino.latitude, destino.longitude],
        'trajeto': trajeto.map((p) => [p.latitude, p.longitude]).toList(),
        'distancia': distancia,
        'calorias': calorias,
        'tempo': tempo,
        'foto': foto,
      };

  factory Caminhada.fromMap(Map<String, dynamic> m) => Caminhada(
        id: m['id'],
        titulo: m['titulo'],
        origem: LatLng(m['origem'][0], m['origem'][1]),
        destino: LatLng(m['destino'][0], m['destino'][1]),
        trajeto: (m['trajeto'] as List).map((p) => LatLng(p[0], p[1])).toList(),
        distancia: (m['distancia'] as num).toDouble(),
        calorias: m['calorias'],
        tempo: m['tempo'],
        foto: m['foto'],
      );
}