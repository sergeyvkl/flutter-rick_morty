import 'dart:convert';

import 'package:http/http.dart';
import 'package:rick_morty/models/character.dart';

class ApiService {
  static const String _baseUrl = 'https://rickandmortyapi.com/api';
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Character>> fetchCharacters(int page) async {
    final response = await _client.get(Uri.parse('$_baseUrl/character?page=$page'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((json) => Character.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load characters');
    }
  }

  Future<List<Character>> searchCharacters(String query) async {
    final response = await _client.get(Uri.parse('$_baseUrl/character/?name=$query'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((json) => Character.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Failed to search characters');
    }
  }
}