import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'caminhada.dart';

Future<List<Caminhada>> listarCaminhadas() async {
  final prefs = await SharedPreferences.getInstance();
  final json = prefs.getString('caminhadas');
  if (json == null) return [];
  final lista = jsonDecode(json) as List;
  return lista.map((m) => Caminhada.fromMap(m)).toList();
}

Future<void> _gravar(List<Caminhada> lista) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
      'caminhadas', jsonEncode(lista.map((c) => c.toMap()).toList()));
}

Future<void> salvarCaminhada(Caminhada c) async {
  final lista = await listarCaminhadas();
  lista.add(c);
  await _gravar(lista);
}

Future<void> atualizarCaminhada(Caminhada c) async {
  final lista = await listarCaminhadas();
  final i = lista.indexWhere((x) => x.id == c.id);
  if (i != -1) lista[i] = c;
  await _gravar(lista);
}