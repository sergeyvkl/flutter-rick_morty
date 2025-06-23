Flutter приложение "Рик и Морти" с избранными персонажами

План разработки мобильного приложения на Flutter для работы с персонажами "Рик и Морти".

Архитектура приложения
Стек технологий:
Flutter SDK
Dart
HTTP для API запросов
SQLite (через sqflite) для локального хранения избранного
SharedPreferences или Hive для кеширования данных персонажей
Providerдля управления состоянием

Структура проекта:
rick_morty/
├── models/
│   ├── character.dart
├── services/
│   ├── api_service.dart
│   ├── database_service.dart
│   └── cache_service.dart
├── repositories/
│   └── character_repository.dart
├── providers/
│   ├── character_provider.dart
│   └── favorites_provider.dart
├── screens/
│   ├── home_screen.dart
│   ├── favorites_screen.dart
│   └── character_detail_screen.dart
├── widgets/
│   ├── character_card.dart
│   ├── loading_indicator.dart
│   └── error_widget.dart
└── main.dart

Особенности реализации

Кеширование изображений:
    Используется CachedNetworkImage для загрузки и кеширования изображений  
    оказываются плейсхолдеры во время загрузки

Оффлайн-режим:
    Все данные персонажей сохраняются в SQLite
    При отсутствии интернета показываются кешированные данные
    Визуальный индикатор оффлайн-режима

Поиск персонажей:
    Поиск по имени через API
    Локальный поиск в кешированных данных при отсутствии интернета
    Очистка поиска по кнопке

Анимации:
    Анимации списка с помощью flutter_staggered_animations
    Плавные переходы между экранами
    Анимация добавления/удаления из избранного
    Hero-анимация для изображений персонажей

Сортировка избранного:
    По имени
    По статусу

Индикаторы загрузки:
    Shimmer-эффект для плейсхолдеров
    Индикатор подгрузки новых элементов
    Pull-to-refresh для обновления данных

Управление состоянием:
    Используется Provider для эффективного управления состоянием
    Разделение на CharacterProvider и FavoritesProvider
