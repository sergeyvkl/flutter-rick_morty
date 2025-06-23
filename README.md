Flutter приложение "Рик и Морти" с избранными персонажами<br>

План разработки мобильного приложения на Flutter для работы с персонажами "Рик и Морти".<br>

Архитектура приложения<br>
Стек технологий:<br>
Flutter SDK<br>
Dart<br>
HTTP для API запросов<br>
SQLite (через sqflite) для локального хранения избранного<br>
SharedPreferences или Hive для кеширования данных персонажей<br>
Providerдля управления состоянием<br>


Структура проекта:<br>

rick_morty/<br>
├── models/<br>
│	├── character.dart<br>
├── services/<br>
│	├── api_service.dart<br>
│   ├── database_service.dart<br>
│   └── cache_service.dart<br>
├── repositories/<br>
│   └── character_repository.dart<br>
├── providers/<br>
│   ├── character_provider.dart<br>
│   └── favorites_provider.dart<br>
├── screens/<br>
│   ├── home_screen.dart<br>
│   ├── favorites_screen.dart<br>
│   └── character_detail_screen.dart<br>
├── widgets/<br>
│   ├── character_card.dart<br>
│   ├── loading_indicator.dart<br>
│   └── error_widget.dart<br>
└── main.dart<br>

Особенности реализации<br>

Кеширование изображений:<br>
    Используется CachedNetworkImage для загрузки и кеширования изображений <br>
    оказываются плейсхолдеры во время загрузки<br>

Оффлайн-режим:<br>
    Все данные персонажей сохраняются в SQLite<br>
    При отсутствии интернета показываются кешированные данные<br>
    Визуальный индикатор оффлайн-режима<br>

Поиск персонажей:<br>
    Поиск по имени через API<br>
    Локальный поиск в кешированных данных при отсутствии интернета<br>
    Очистка поиска по кнопке<br>

Анимации:
    Анимации списка с помощью flutter_staggered_animations<br>
    Плавные переходы между экранами<br>
    Анимация добавления/удаления из избранного<br>
    Hero-анимация для изображений персонажей<br>

Сортировка избранного:<br>
    По имени<br>
    По статусу<br>

Индикаторы загрузки:<br>
    Shimmer-эффект для плейсхолдеров<br>
    Индикатор подгрузки новых элементов<br>
    Pull-to-refresh для обновления данных<br>

Управление состоянием:<br>
    Используется Provider для эффективного управления состоянием<br>
    Разделение на CharacterProvider и FavoritesProvider<br>
