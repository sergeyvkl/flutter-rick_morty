import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:rick_morty/providers/favorites_provider.dart';
import 'package:rick_morty/widgets/character_card.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late FavoritesProvider _favoritesProvider;

  @override
  void initState() {
    super.initState();
    _favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    await _favoritesProvider.loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранное'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _favoritesProvider.setSortBy(value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, color: Colors.black),
                    SizedBox(width: 8),
                    Text('По имени'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'status',
                child: Row(
                  children: [
                    Icon(Icons.health_and_safety, color: Colors.black),
                    SizedBox(width: 8),
                    Text('По статусу'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, provider, child) {
          if (provider.favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'Нет избранных персонажей',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Добавьте персонажей, нажав на звездочку',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }
          
          return AnimationLimiter(
            child: ListView.builder(
              itemCount: provider.favorites.length,
              itemBuilder: (context, index) {
                final character = provider.favorites[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Dismissible(
                        key: Key(character.id.toString()),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => provider.toggleFavorite(character),
                        child: CharacterCard(
                          character: character,
                          onFavoriteTap: () => provider.toggleFavorite(character),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}