import 'package:flutter/material.dart';

/// Simple in-app translations (EN / RU / UZ).
/// Add keys here when expanding UI language coverage.
class AppStrings {
  AppStrings(this.code);

  final String code;

  static const _en = <String, String>{
    'navHome': 'Home',
    'navChats': 'Chats',
    'navRooms': 'Rooms',
    'navProfile': 'Profile',
    'settings': 'Settings',
    'preferences': 'Preferences',
    'theme': 'Theme',
    'appLanguage': 'App language',
    'appLanguageHint': 'Russian & Uzbek available — more coming soon',
    'notifications': 'Notifications',
    'privacySecurity': 'Privacy & security',
    'privacy': 'Privacy',
    'deviceSessions': 'Device sessions',
    'blockedUsers': 'Blocked users',
    'premium': 'Premium',
    'about': 'About',
    'logOut': 'Log out',
    'deleteAccount': 'Delete account',
    'deleteAccountTitle': 'Delete account?',
    'deleteAccountBody': 'This permanently deletes your Lingua account.',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'languageChanged': 'App language updated',
    'hello': 'Hello, {name}',
    'dayStreak': '{n} day streak',
    'dailyGoal': 'Daily goal',
    'goalMap': 'Goal Map',
    'dailyGoalHint': 'Tap to set a level goal by date — we track you every day.',
    'explore': 'Explore',
    'discover': 'Discover',
    'saves': 'Saves',
    'games': 'Games',
    'continueLearning': 'Continue learning',
    'flashcards': 'Flashcards',
    'speaking': 'Speaking',
    'voiceCoach': 'Voice coach',
    'social': 'Social',
    'roomsTables': 'Rooms & tables',
    'aiSuggestions': 'AI suggestions',
    'onlineNow': 'Online now',
    'chats': 'Chats',
    'newGroup': 'New group',
    'findGroups': 'Find groups',
    'profile': 'Profile',
    'editProfile': 'Edit profile',
    'learning': 'Learning',
    'themeLight': 'Light',
    'themeDark': 'Dark',
    'themeSystem': 'System',
    'questsCards': 'Quests & cards',
    'learner': 'Learner',
    'recommendedFriends': 'Recommended friends',
    'seeAll': 'See all',
    'chat': 'Chat',
    'recentChats': 'Recent chats',
    'open': 'Open',
    'dueCount': '{n} due',
    'practiceByPlaying': 'Practice by playing',
    'gamesHubHint': 'Flashcards, AI quests, and picture word challenges.',
    'play': 'Play',
    'levels': 'Levels',
    'alsoAvailable': 'Also available',
    'freeAiTutor': 'Free AI tutor',
    'freeAiTutorHint': 'Open chat without quest goals',
    'voiceCoachHint': 'Pronunciation feedback',
    'savesTitle': 'Saves',
    'memorizer': 'Memorizer',
    'all': 'All',
    'words': 'Words',
    'phrases': 'Phrases',
    'roomGroups': 'Groups',
    'roomTables': 'Tables',
    'roomGames': 'Games',
    'hostTable': 'Host a table',
    'createMafia': 'Create Mafia',
    'mafia': 'Mafia',
    'mafiaHint': 'Classic social deduction — practice speaking while you play.',
    'seatsLeft': 'seats left',
    'starting': 'Starting',
    'inMinutes': 'in {n}m',
    'host': 'Host',
    'leave': 'Leave',
    'join': 'Join',
    'full': 'Full',
    'joinedTable': 'Joined the table',
    'tableFull': 'Table is full',
    'lobby': 'Lobby',
    'playing': 'Live',
    'ended': 'Ended',
    'roomTitle': 'Room title',
    'language': 'Language',
    'minPlayers': 'Min',
    'maxPlayers': 'Max',
    'roomNotFound': 'Room not found',
    'yourRole': 'Your role',
    'players': 'Players',
    'alive': 'Alive',
    'eliminated': 'Eliminated',
    'startGame': 'Start game',
    'needPlayers': 'Need',
    'needPlayersHint': 'Not enough players to start',
    'waitingHost': 'Waiting for the host to start…',
    'nightPhase': 'Night — mafia chooses a target',
    'dayVote': 'Day — discuss and vote',
    'eliminate': 'Eliminate',
    'skipNight': 'Resolve night',
    'vote': 'Vote out',
    'youAreOut': 'You are out — watch the round.',
    'backToRooms': 'Back to rooms',
    'directInbox': 'Direct chats',
  };

  static const _ru = <String, String>{
    'navHome': 'Главная',
    'navChats': 'Чаты',
    'navRooms': 'Комнаты',
    'navProfile': 'Профиль',
    'settings': 'Настройки',
    'preferences': 'Параметры',
    'theme': 'Тема',
    'appLanguage': 'Язык приложения',
    'appLanguageHint': 'Доступны русский и узбекский — скоро больше',
    'notifications': 'Уведомления',
    'privacySecurity': 'Конфиденциальность',
    'privacy': 'Приватность',
    'deviceSessions': 'Сессии устройств',
    'blockedUsers': 'Заблокированные',
    'premium': 'Премиум',
    'about': 'О приложении',
    'logOut': 'Выйти',
    'deleteAccount': 'Удалить аккаунт',
    'deleteAccountTitle': 'Удалить аккаунт?',
    'deleteAccountBody': 'Аккаунт Lingua будет удалён навсегда.',
    'cancel': 'Отмена',
    'delete': 'Удалить',
    'languageChanged': 'Язык приложения изменён',
    'hello': 'Привет, {name}',
    'dayStreak': 'Серия {n} дн.',
    'dailyGoal': 'Цель дня',
    'goalMap': 'Карта цели',
    'dailyGoalHint': 'Нажми, чтобы поставить цель по уровню и дате.',
    'explore': 'Обзор',
    'discover': 'Поиск',
    'saves': 'Сохранения',
    'games': 'Игры',
    'continueLearning': 'Продолжить',
    'flashcards': 'Карточки',
    'speaking': 'Говорение',
    'voiceCoach': 'Голосовой тренер',
    'social': 'Соцсеть',
    'roomsTables': 'Комнаты и столы',
    'aiSuggestions': 'Идеи от ИИ',
    'onlineNow': 'Сейчас онлайн',
    'chats': 'Чаты',
    'newGroup': 'Новая группа',
    'findGroups': 'Найти группы',
    'profile': 'Профиль',
    'editProfile': 'Редактировать',
    'learning': 'Обучение',
    'themeLight': 'Светлая',
    'themeDark': 'Тёмная',
    'themeSystem': 'Системная',
    'questsCards': 'Квесты и карточки',
    'learner': 'Ученик',
    'recommendedFriends': 'Рекомендуемые друзья',
    'seeAll': 'Все',
    'chat': 'Чат',
    'recentChats': 'Недавние чаты',
    'open': 'Открыть',
    'dueCount': '{n} к повтору',
    'practiceByPlaying': 'Учись в игре',
    'gamesHubHint': 'Карточки, AI-квесты и слова по картинкам.',
    'play': 'Играть',
    'levels': 'Уровни',
    'alsoAvailable': 'Также доступно',
    'freeAiTutor': 'Свободный AI-тьютор',
    'freeAiTutorHint': 'Чат без целей квеста',
    'voiceCoachHint': 'Обратная связь по произношению',
    'savesTitle': 'Сохранения',
    'memorizer': 'Запоминалка',
    'all': 'Все',
    'words': 'Слова',
    'phrases': 'Фразы',
    'roomGroups': 'Группы',
    'roomTables': 'Столики',
    'roomGames': 'Игры',
    'hostTable': 'Создать столик',
    'createMafia': 'Создать мафию',
    'mafia': 'Мафия',
    'mafiaHint': 'Классическая игра — практикуй речь за столом.',
    'seatsLeft': 'мест свободно',
    'starting': 'Скоро',
    'inMinutes': 'через {n} м',
    'host': 'Хост',
    'leave': 'Выйти',
    'join': 'Войти',
    'full': 'Полный',
    'joinedTable': 'Вы за столиком',
    'tableFull': 'Столик занят',
    'lobby': 'Лобби',
    'playing': 'Идёт',
    'ended': 'Конец',
    'roomTitle': 'Название комнаты',
    'language': 'Язык',
    'minPlayers': 'Мин.',
    'maxPlayers': 'Макс.',
    'roomNotFound': 'Комната не найдена',
    'yourRole': 'Ваша роль',
    'players': 'Игроки',
    'alive': 'В игре',
    'eliminated': 'Выбыл',
    'startGame': 'Начать игру',
    'needPlayers': 'Нужно',
    'needPlayersHint': 'Мало игроков для старта',
    'waitingHost': 'Ждём, пока хост начнёт…',
    'nightPhase': 'Ночь — мафия выбирает цель',
    'dayVote': 'День — обсуждение и голосование',
    'eliminate': 'Убрать',
    'skipNight': 'Завершить ночь',
    'vote': 'Голосовать',
    'youAreOut': 'Вы выбыли — смотрите раунд.',
    'backToRooms': 'К комнатам',
    'directInbox': 'Личные чаты',
  };

  static const _uz = <String, String>{
    'navHome': 'Bosh sahifa',
    'navChats': 'Chatlar',
    'navRooms': 'Xonalar',
    'navProfile': 'Profil',
    'settings': 'Sozlamalar',
    'preferences': 'Parametrlar',
    'theme': 'Mavzu',
    'appLanguage': 'Ilova tili',
    'appLanguageHint': 'Rus va o‘zbek tillari bor — tez orada yana',
    'notifications': 'Bildirishnomalar',
    'privacySecurity': 'Maxfiylik',
    'privacy': 'Shaxsiy hayot',
    'deviceSessions': 'Qurilma sessiyalari',
    'blockedUsers': 'Bloklanganlar',
    'premium': 'Premium',
    'about': 'Ilova haqida',
    'logOut': 'Chiqish',
    'deleteAccount': 'Hisobni o‘chirish',
    'deleteAccountTitle': 'Hisob o‘chirilsinmi?',
    'deleteAccountBody': 'Lingua hisobi butunlay o‘chiriladi.',
    'cancel': 'Bekor',
    'delete': 'O‘chirish',
    'languageChanged': 'Ilova tili o‘zgartirildi',
    'hello': 'Salom, {name}',
    'dayStreak': '{n} kunlik seriya',
    'dailyGoal': 'Kunlik maqsad',
    'goalMap': 'Maqsad xaritasi',
    'dailyGoalHint': 'Bosib daraja va sana bo‘yicha maqsad qo‘ying.',
    'explore': 'Kashf etish',
    'discover': 'Qidiruv',
    'saves': 'Saqlanganlar',
    'games': 'O‘yinlar',
    'continueLearning': 'Davom ettirish',
    'flashcards': 'Kartochkalar',
    'speaking': 'Gapirish',
    'voiceCoach': 'Ovoz murabbiyi',
    'social': 'Ijtimoiy',
    'roomsTables': 'Xonalar va stollar',
    'aiSuggestions': 'AI takliflari',
    'onlineNow': 'Hozir onlayn',
    'chats': 'Chatlar',
    'newGroup': 'Yangi guruh',
    'findGroups': 'Guruh topish',
    'profile': 'Profil',
    'editProfile': 'Tahrirlash',
    'learning': 'O‘qish',
    'themeLight': 'Yorug‘',
    'themeDark': 'Qorong‘u',
    'themeSystem': 'Tizim',
    'questsCards': 'Kvestlar va kartalar',
    'learner': 'O‘quvchi',
    'recommendedFriends': 'Tavsiya etilgan do‘stlar',
    'seeAll': 'Hammasi',
    'chat': 'Chat',
    'recentChats': 'So‘nggi chatlar',
    'open': 'Ochish',
    'dueCount': '{n} takrorlash',
    'practiceByPlaying': 'O‘ynab o‘rganing',
    'gamesHubHint': 'Kartochkalar, AI kvestlar va rasm so‘zlari.',
    'play': 'O‘ynash',
    'levels': 'Darajalar',
    'alsoAvailable': 'Yana mavjud',
    'freeAiTutor': 'Erkin AI murabbiy',
    'freeAiTutorHint': 'Kvest maqsadisiz chat',
    'voiceCoachHint': 'Talaffuz bo‘yicha fikr',
    'savesTitle': 'Saqlanganlar',
    'memorizer': 'Yodlagich',
    'all': 'Hammasi',
    'words': 'So‘zlar',
    'phrases': 'Iboralar',
    'roomGroups': 'Guruhlar',
    'roomTables': 'Stollar',
    'roomGames': 'O‘yinlar',
    'hostTable': 'Stol ochish',
    'createMafia': 'Mafiya yaratish',
    'mafia': 'Mafiya',
    'mafiaHint': 'Klassik o‘yin — gapirishni mashq qiling.',
    'seatsLeft': 'joy qoldi',
    'starting': 'Boshlanmoqda',
    'inMinutes': '{n} daq. ichida',
    'host': 'Mezbon',
    'leave': 'Chiqish',
    'join': 'Kirish',
    'full': 'To‘liq',
    'joinedTable': 'Stolga qo‘shildingiz',
    'tableFull': 'Stol band',
    'lobby': 'Lobbi',
    'playing': 'O‘yin',
    'ended': 'Tugadi',
    'roomTitle': 'Xona nomi',
    'language': 'Til',
    'minPlayers': 'Min',
    'maxPlayers': 'Maks',
    'roomNotFound': 'Xona topilmadi',
    'yourRole': 'Rolingiz',
    'players': 'O‘yinchilar',
    'alive': 'Tirik',
    'eliminated': 'Chiqaildi',
    'startGame': 'O‘yinni boshlash',
    'needPlayers': 'Kerak',
    'needPlayersHint': 'Boshlash uchun o‘yinchi yetarli emas',
    'waitingHost': 'Mezbon boshlashini kuting…',
    'nightPhase': 'Tun — mafiya nishon tanlaydi',
    'dayVote': 'Kun — muhokama va ovoz',
    'eliminate': 'Yo‘q qilish',
    'skipNight': 'Tunni yakunlash',
    'vote': 'Ovoz berish',
    'youAreOut': 'Siz chiqdingiz — raundni kuzating.',
    'backToRooms': 'Xonalarga',
    'directInbox': 'Shaxsiy chatlar',
  };

  Map<String, String> get _table {
    switch (code) {
      case 'ru':
        return _ru;
      case 'uz':
        return _uz;
      default:
        return _en;
    }
  }

  String t(String key, [Map<String, String>? vars]) {
    var value = _table[key] ?? _en[key] ?? key;
    if (vars != null) {
      vars.forEach((k, v) {
        value = value.replaceAll('{$k}', v);
      });
    }
    return value;
  }

  String get navHome => t('navHome');
  String get navChats => t('navChats');
  String get navRooms => t('navRooms');
  String get navProfile => t('navProfile');
  String get settings => t('settings');
  String get preferences => t('preferences');
  String get theme => t('theme');
  String get appLanguage => t('appLanguage');
  String get appLanguageHint => t('appLanguageHint');
  String get notifications => t('notifications');
  String get privacySecurity => t('privacySecurity');
  String get privacy => t('privacy');
  String get deviceSessions => t('deviceSessions');
  String get blockedUsers => t('blockedUsers');
  String get premium => t('premium');
  String get about => t('about');
  String get logOut => t('logOut');
  String get deleteAccount => t('deleteAccount');
  String get deleteAccountTitle => t('deleteAccountTitle');
  String get deleteAccountBody => t('deleteAccountBody');
  String get cancel => t('cancel');
  String get delete => t('delete');
  String get languageChanged => t('languageChanged');
  String get dailyGoal => t('dailyGoal');
  String get goalMap => t('goalMap');
  String get dailyGoalHint => t('dailyGoalHint');
  String get explore => t('explore');
  String get discover => t('discover');
  String get saves => t('saves');
  String get games => t('games');
  String get continueLearning => t('continueLearning');
  String get flashcards => t('flashcards');
  String get speaking => t('speaking');
  String get voiceCoach => t('voiceCoach');
  String get social => t('social');
  String get roomsTables => t('roomsTables');
  String get aiSuggestions => t('aiSuggestions');
  String get onlineNow => t('onlineNow');
  String get chats => t('chats');
  String get newGroup => t('newGroup');
  String get findGroups => t('findGroups');
  String get profile => t('profile');
  String get editProfile => t('editProfile');
  String get learning => t('learning');
  String get questsCards => t('questsCards');
  String get learner => t('learner');
  String get recommendedFriends => t('recommendedFriends');
  String get seeAll => t('seeAll');
  String get chat => t('chat');
  String get recentChats => t('recentChats');
  String get open => t('open');
  String get practiceByPlaying => t('practiceByPlaying');
  String get gamesHubHint => t('gamesHubHint');
  String get play => t('play');
  String get levels => t('levels');
  String get alsoAvailable => t('alsoAvailable');
  String get freeAiTutor => t('freeAiTutor');
  String get freeAiTutorHint => t('freeAiTutorHint');
  String get voiceCoachHint => t('voiceCoachHint');
  String get savesTitle => t('savesTitle');
  String get memorizer => t('memorizer');
  String get all => t('all');
  String get words => t('words');
  String get phrases => t('phrases');
  String get roomGroups => t('roomGroups');
  String get roomTables => t('roomTables');
  String get roomGames => t('roomGames');
  String get hostTable => t('hostTable');
  String get createMafia => t('createMafia');
  String get mafia => t('mafia');
  String get mafiaHint => t('mafiaHint');
  String get seatsLeft => t('seatsLeft');
  String get starting => t('starting');
  String get host => t('host');
  String get leave => t('leave');
  String get join => t('join');
  String get full => t('full');
  String get joinedTable => t('joinedTable');
  String get tableFull => t('tableFull');
  String get lobby => t('lobby');
  String get playing => t('playing');
  String get ended => t('ended');
  String get roomTitle => t('roomTitle');
  String get language => t('language');
  String get minPlayers => t('minPlayers');
  String get maxPlayers => t('maxPlayers');
  String get roomNotFound => t('roomNotFound');
  String get yourRole => t('yourRole');
  String get players => t('players');
  String get alive => t('alive');
  String get eliminated => t('eliminated');
  String get startGame => t('startGame');
  String get needPlayers => t('needPlayers');
  String get needPlayersHint => t('needPlayersHint');
  String get waitingHost => t('waitingHost');
  String get nightPhase => t('nightPhase');
  String get dayVote => t('dayVote');
  String get eliminate => t('eliminate');
  String get skipNight => t('skipNight');
  String get vote => t('vote');
  String get youAreOut => t('youAreOut');
  String get backToRooms => t('backToRooms');
  String get directInbox => t('directInbox');

  String hello(String name) => t('hello', {'name': name});
  String dayStreak(int n) => t('dayStreak', {'n': '$n'});
  String dueCount(int n) => t('dueCount', {'n': '$n'});
  String inMinutes(int n) => t('inMinutes', {'n': '$n'});

  String themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return t('themeLight');
      case ThemeMode.dark:
        return t('themeDark');
      case ThemeMode.system:
        return t('themeSystem');
    }
  }
}
