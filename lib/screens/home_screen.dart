import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:rick_morty/providers/character_provider.dart';
import 'package:rick_morty/widgets/character_card.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late CharacterProvider _characterProvider;

  @override
  void initState() {
    super.initState();
    _characterProvider = Provider.of<CharacterProvider>(context, listen: false);
    _characterProvider.loadCharacters();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        !_characterProvider.isLoading &&
        _characterProvider.hasMore) {
      _characterProvider.loadCharacters();
    }
  }

  Future<void> _refreshData() async {
    _characterProvider.resetSearch();
    _searchController.clear();
    await _characterProvider.loadCharacters(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Персонажи Рик и Морти'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск персонажей...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _characterProvider.resetSearch();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _characterProvider.searchCharacters(value);
                } else {
                  _characterProvider.resetSearch();
                }
              },
            ),
          ),
          Expanded(
            child: Consumer<CharacterProvider>(
              builder: (context, provider, child) {
                if (provider.characters.isEmpty && provider.isLoading) {
                  return _buildLoadingIndicator();
                }
                
                if (provider.characters.isEmpty && provider.isOffline) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Нет подключения к интернету'),
                        Text('Используются кешированные данные'),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshData,
                          child: Text('Попробовать снова'),
                        ),
                      ],
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: _refreshData,
                  child: AnimationLimiter(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: provider.characters.length + (provider.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == provider.characters.length) {
                          return provider.hasMore
                              ? Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(child: CircularProgressIndicator()),
                                )
                              : SizedBox.shrink();
                        }
                        
                        final character = provider.characters[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: CharacterCard(
                                character: character,
                                onFavoriteTap: () => provider.toggleFavorite(character),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}