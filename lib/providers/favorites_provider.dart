import 'package:flutter/material.dart';
import 'package:rick_morty/models/character.dart';
import 'package:rick_morty/repositories/character_repository.dart';

class FavoritesProvider with ChangeNotifier {
  final CharacterRepository _repository;
  List<Character> _favorites = [];
  String _sortBy = 'name';

  FavoritesProvider(this._repository);

  List<Character> get favorites {
    return _sortBy == 'name'
        ? _favorites.sort((a, b) => a.name.compareTo(b.name))
        : _favorites..sort((a, b) => a.status.compareTo(b.status));
  }

  String get sortBy => _sortBy;

  Future<void> loadFavorites() async {
    _favorites = await _repository.getFavorites();
    notifyListeners();
  }

  Future<void> toggleFavorite(Character character) async {
    await _repository.toggleFavorite(character);
    if (character.isFavorite) {
      _favorites.add(character);
    } else {
      _favorites.removeWhere((c) => c.id == character.id);
    }
    notifyListeners();
  }

  void setSortBy(String value) {
    _sortBy = value;
    notifyListeners();
  }
}