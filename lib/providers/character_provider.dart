import 'package:flutter/material.dart';
import 'package:rick_morty/models/character.dart';
import 'package:rick_morty/repositories/character_repository.dart';

class CharacterProvider with ChangeNotifier {
  final CharacterRepository _repository;
  List<Character> _characters = [];
  List<Character> _filteredCharacters = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  String _searchQuery = '';
  bool _isOffline = false;

  CharacterProvider(this._repository);

  List<Character> get characters => _searchQuery.isEmpty ? _characters : _filteredCharacters;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  bool get isOffline => _isOffline;

  Future<void> loadCharacters({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final newCharacters = await _repository.fetchCharacters(_page, forceRefresh: forceRefresh);
      
      setState(() {
        _characters.addAll(newCharacters);
        _page++;
        _hasMore = newCharacters.isNotEmpty;
        _isOffline = false;
      });
    } catch (e) {
      setState(() => _isOffline = true);
      if (_characters.isEmpty) rethrow;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> searchCharacters(String query) async {
    _searchQuery = query;
    
    if (query.isEmpty) {
      _filteredCharacters = [];
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      _filteredCharacters = await _repository.searchCharacters(query);
      _isOffline = false;
    } catch (e) {
      _isOffline = true;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(Character character) async {
    await _repository.toggleFavorite(character);
    notifyListeners();
  }

  void setState(void Function() fn) {
    fn();
    notifyListeners();
  }

  void resetSearch() {
    _searchQuery = '';
    _filteredCharacters = [];
    notifyListeners();
  }
}