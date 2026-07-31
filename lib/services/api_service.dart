import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/track.dart';

class ApiService {
  static const String baseUrl = 'https://bhindi1.ddns.net/music/api';

  Future<Track?> searchAndFetchTrack(String query) async {
    try {
      final prepareUri = Uri.parse('$baseUrl/prepare/${Uri.encodeComponent(query)}');
      final prepareResponse = await http.get(prepareUri);

      if (prepareResponse.statusCode == 200) {
        final prepareData = jsonDecode(prepareResponse.body);
        final String songId = prepareData['song_id'] ?? '';

        if (songId.isEmpty) return null;

        final fetchUri = Uri.parse('$baseUrl/fetch/$songId');
        final fetchResponse = await http.get(fetchUri);

        if (fetchResponse.statusCode == 200) {
          final fetchData = jsonDecode(fetchResponse.body);

          return Track(
            id: songId,
            title: fetchData['title'] ?? query,
            artist: fetchData['artist'] ?? 'Artista Desconhecido',
            coverUrl: fetchData['thumbnail'] ?? 'https://via.placeholder.com/150',
            streamUrl: '$baseUrl/audio/$songId',
          );
        }
      }
    } catch (e) {
      print('Erro na requisição: $e');
    }
    return null;
  }
}