import 'package:rick_morty/models/character.dart';
import 'package:rick_morty/services/api_service.dart';
import 'package:rick_morty/services/database_service.dart';

class CharacterRepository {
  final ApiService _apiService;
  final DatabaseService _databaseService;

  CharacterRepository(this._apiService, this._databaseService);

  Future<List<Character>> fetchCharacters(int page, {bool forceRefresh = false}) async {
    try {
      final characters = await _apiService.fetchCharacters(page);
      await _databaseService.cacheCharacters(characters);
      return characters;
    } catch (e) {
      if (!forceRefresh) {
        return await _databaseService.getCachedCharacters(page);
      }
      rethrow;
    }
  }

  Future<List<Character>> searchCharacters(String query) async {
    try {
      final results = await _apiService.searchCharacters(query);
      return results;
    } catch (e) {
      return await _databaseService.searchCachedCharacters(query);
    }
  }

  Future<void> toggleFavorite(Character character) async {
    if (character.isFavorite) {
      await _databaseService.removeFavorite(character.id);
    } else {
      await _databaseService.addFavorite(character.id);
    }
    character.isFavorite = !character.isFavorite;
  }

  Future<List<Character>> getFavorites() async {
    final favoriteIds = await _databaseService.getFavorites();
    final characters = await _databaseService.getCharactersByIds(favoriteIds);
    return characters;
  }
}