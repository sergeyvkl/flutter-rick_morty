import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rick_morty/providers/character_provider.dart';
import 'package:rick_morty/providers/favorites_provider.dart';
import 'package:rick_morty/repositories/character_repository.dart';
import 'package:rick_morty/screens/favorites_screen.dart';
import 'package:rick_morty/screens/home_screen.dart';
import 'package:rick_morty/services/api_service.dart';
import 'package:rick_morty/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final databaseService = DatabaseService();
  await databaseService.database; // Инициализация базы данных
  
  final apiService = ApiService();
  final characterRepository = CharacterRepository(apiService, databaseService);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CharacterProvider(characterRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(characterRepository),
        ),
      ],
      child: RickAndMortyApp(),
    ),
  );
}

class RickAndMortyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Рик и Морти',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      home: MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Персонажи',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Избранное',
          ),
        ],
        onTap: (index) {
          setState(() => _currentIndex = index);
          
          // Обновляем список избранных при переходе на экран
          if (index == 1) {
            Provider.of<FavoritesProvider>(context, listen: false).loadFavorites();
          }
        },
      ),
    );
  }
}