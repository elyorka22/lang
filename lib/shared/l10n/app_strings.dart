import 'package:flutter/material.dart';

/// Simple in-app translations (EN / RU / UZ).
/// Add keys here when expanding UI language coverage.
class AppStrings {
  AppStrings(this.code);

  final String code;

  static const _en = <String, String>{
    'navHome': 'Home',
    'navChats': 'Chats',
    'navAi': 'AI',
    'navVocab': 'Vocabulary',
    'navWords': 'Words',
    'navPractice': 'Practice',
    'navGames': 'Games',
    'navRooms': 'Rooms',
    'navProfile': 'Profile',
    'searchWords': 'Search words',
    'wordsLearnedToday': '{n} new words today',
    'wordsToReview': 'To review',
    'reviewDue': 'Review {n} due',
    'weeklyProgress': 'Weekly progress',
    'accuracy': 'Accuracy',
    'srsNew': 'New',
    'srsLearning': 'Learning',
    'srsReview': 'Review',
    'srsMastered': 'Mastered',
    'definition': 'Definition',
    'exampleSentence': 'Example',
    'synonyms': 'Synonyms',
    'antonyms': 'Antonyms',
    'collocations': 'Collocations',
    'verbForms': 'Verb forms',
    'addToDeck': 'Add to deck',
    'addedToDeck': 'Added to your deck',
    'sessionComplete': 'Session complete!',
    'noWordsDue': 'Nothing due right now. Great job!',
    'practiceAnyway': 'Practice 10 words',
    'restart': 'Restart',
    'tapToFlip': 'Tap to flip',
    'again': 'Again',
    'good': 'Good',
    'score': 'Score',
    'done': 'Done',
    'reset': 'Reset',
    'gameMatchMeaning': 'Match Word → Meaning',
    'gameMatchMeaningHint': 'Pair English words with translations',
    'gameImageWord': 'Match Image → Word',
    'gameImageWordHint': 'Choose the word for each prompt',
    'gameWordBuilder': 'Word Builder',
    'gameWordBuilderHint': 'Unscramble the letters',
    'gameMemoryCards': 'Memory Cards',
    'gameMemoryCardsHint': 'Flip and match pairs',
    'quickActions': 'Quick actions',
    'startPracticing': 'START PRACTICING NOW',
    'findPartner': 'Find Partner',
    'joinVoiceRoom': 'Join Voice Room',
    'practiceWithAi': 'Practice with AI',
    'peopleOnline': 'People Online',
    'recommendedPartners': 'Recommended Partners',
    'vocabularyReview': 'Vocabulary Review',
    'trendingVoiceRooms': 'Trending Voice Rooms',
    'popularGames': 'Popular Games',
    'wordsDue': '{n} words due',
    'onlineCount': '{n} online',
    'follow': 'Follow',
    'message': 'Message',
    'friends': 'Friends',
    'voiceHours': 'Voice hours',
    'wordsLearned': 'Words learned',
    'achievements': 'Achievements',
    'learningStats': 'Learning stats',
    'easy': 'Easy',
    'medium': 'Medium',
    'hard': 'Hard',
    'review': 'Review',
    'dailyLesson': 'Daily lesson',
    'translation': 'Translation',
    'pronunciation': 'Pronunciation',
    'grammar': 'Grammar',
    'roleplay': 'Roleplay',
    'aiTutor': 'AI Tutor',
    'noWordsYet': 'No words yet',
    'noWordsHint': 'Browse the deck or clear your search filters',
    'thinking': 'Thinking…',
    'askAnything': 'Ask anything about languages…',
    'nativeLang': 'Native',
    'learningLang': 'Learning',
    'addFriend': 'Add friend',
    'socialMentors': 'Social & mentors',
    'voiceMessage': 'Voice message',
    'emptyChatsHint': 'Find a partner or create a group to start talking',
    'mentor': 'Mentor',
    'live': 'Live',
    'playersCount': '{n} players',
    'remainingFree': '{n} left',
    'tutor': 'Tutor',
    'ielts': 'IELTS',
    'vocabStats': 'Your progress',
    'totalWords': 'Total',
    'favorites': 'Favorites',
    'mastered': 'Mastered',
    'profileStreak': 'Streak',
    'profileXp': 'XP',
    'profileLevel': 'Level',
    'languages': 'Languages',
    'interests': 'Interests',
    'badges': 'Badges',
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
    'recommendedGroups': 'Recommended groups',
    'seeAll': 'See all',
    'chat': 'Chat',
    'recentChats': 'Recent chats',
    'open': 'Open',
    'dueCount': '{n} due',
    'practiceByPlaying': 'Practice by playing',
    'gamesHubHint': 'Four vocab games: match, images, builder, memory.',
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
    'discussHint': 'Discuss here — convince the town',
    'nightSilence': 'Night silence — chat opens at dawn',
    'send': 'Send',
    'dayDiscuss': 'Day · discuss',
    'autoIn': 'Auto in',
    'pickTargetHint': 'Optional: pick a target before night ends',
    'waitNightHint': 'Night is automatic — wait for dawn tips',
    'pickTarget': 'Pick',
    'locked': 'Locked',
    'changePhoto': 'Change photo',
    'chooseFromGallery': 'Choose from gallery',
    'takePhoto': 'Take a photo',
    'removePhoto': 'Remove photo',
    'displayName': 'Display name',
    'bio': 'Bio',
    'save': 'Save',
    'profileUpdated': 'Profile updated',
    'profileUpdateFailed': 'Could not update profile',
    'stopListening': 'Stop',
    'listening': 'Listening… speak now',
    'recognizedText': 'Recognized',
    'pronunciationCorrect': 'Correct!',
    'pronunciationScore': 'Score: {n}%',
    'overallScore': 'Overall Score: {n}%',
    'matchedWords': 'Matched words',
    'missingWords': 'Missing words',
    'extraWords': 'Extra words',
    'incorrectWords': 'Incorrect words',
    'ratingExcellent': 'Excellent',
    'ratingGood': 'Good',
    'ratingNeedsPractice': 'Needs Practice',
    'tapMicToPractice': 'Tap the microphone to practice pronunciation',
  };

  static const _ru = <String, String>{
    'navHome': 'Главная',
    'navChats': 'Чаты',
    'navAi': 'ИИ',
    'navVocab': 'Словарь',
    'navWords': 'Слова',
    'navPractice': 'Практика',
    'navGames': 'Игры',
    'navRooms': 'Комнаты',
    'navProfile': 'Профиль',
    'searchWords': 'Поиск слов',
    'wordsLearnedToday': '{n} новых слов сегодня',
    'wordsToReview': 'К повторению',
    'reviewDue': 'Повторить {n}',
    'weeklyProgress': 'Прогресс за неделю',
    'accuracy': 'Точность',
    'srsNew': 'Новые',
    'srsLearning': 'Изучение',
    'srsReview': 'Повтор',
    'srsMastered': 'Выучено',
    'definition': 'Определение',
    'exampleSentence': 'Пример',
    'synonyms': 'Синонимы',
    'antonyms': 'Антонимы',
    'collocations': 'Коллокации',
    'verbForms': 'Формы глагола',
    'addToDeck': 'В колоду',
    'addedToDeck': 'Добавлено в колоду',
    'sessionComplete': 'Сессия завершена!',
    'noWordsDue': 'Сейчас нечего повторять.',
    'practiceAnyway': 'Практиковать 10 слов',
    'restart': 'Заново',
    'tapToFlip': 'Нажмите, чтобы перевернуть',
    'again': 'Снова',
    'good': 'Хорошо',
    'score': 'Счёт',
    'done': 'Готово',
    'reset': 'Сброс',
    'gameMatchMeaning': 'Слово → Значение',
    'gameMatchMeaningHint': 'Соедините слова и переводы',
    'gameImageWord': 'Образ → Слово',
    'gameImageWordHint': 'Выберите слово по подсказке',
    'gameWordBuilder': 'Сборщик слов',
    'gameWordBuilderHint': 'Соберите буквы',
    'gameMemoryCards': 'Карточки памяти',
    'gameMemoryCardsHint': 'Найдите пары',
    'quickActions': 'Быстрые действия',
    'startPracticing': 'НАЧАТЬ ПРАКТИКУ',
    'findPartner': 'Найти партнёра',
    'joinVoiceRoom': 'Голосовая комната',
    'practiceWithAi': 'Практика с ИИ',
    'peopleOnline': 'Сейчас онлайн',
    'recommendedPartners': 'Рекомендуемые партнёры',
    'vocabularyReview': 'Повторение слов',
    'trendingVoiceRooms': 'Популярные комнаты',
    'popularGames': 'Популярные игры',
    'wordsDue': '{n} слов к повторению',
    'onlineCount': '{n} онлайн',
    'follow': 'Подписаться',
    'message': 'Написать',
    'friends': 'Друзья',
    'voiceHours': 'Часы голоса',
    'wordsLearned': 'Выучено слов',
    'achievements': 'Достижения',
    'learningStats': 'Статистика',
    'easy': 'Легко',
    'medium': 'Средне',
    'hard': 'Сложно',
    'review': 'Повторить',
    'dailyLesson': 'Урок дня',
    'translation': 'Перевод',
    'pronunciation': 'Произношение',
    'grammar': 'Грамматика',
    'roleplay': 'Ролевая игра',
    'aiTutor': 'ИИ-репетитор',
    'noWordsYet': 'Пока нет слов',
    'noWordsHint': 'Откройте колоду или сбросьте фильтры поиска',
    'thinking': 'Думаю…',
    'askAnything': 'Спросите что угодно о языках…',
    'nativeLang': 'Родной',
    'learningLang': 'Изучает',
    'addFriend': 'Добавить в друзья',
    'socialMentors': 'Соцсеть и менторы',
    'voiceMessage': 'Голосовое сообщение',
    'emptyChatsHint': 'Найдите партнёра или создайте группу',
    'mentor': 'Ментор',
    'live': 'В эфире',
    'playersCount': '{n} игроков',
    'remainingFree': 'Осталось {n}',
    'tutor': 'Репетитор',
    'ielts': 'IELTS',
    'vocabStats': 'Ваш прогресс',
    'totalWords': 'Всего',
    'favorites': 'Избранное',
    'mastered': 'Выучено',
    'profileStreak': 'Серия',
    'profileXp': 'XP',
    'profileLevel': 'Уровень',
    'languages': 'Языки',
    'interests': 'Интересы',
    'badges': 'Значки',
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
    'recommendedGroups': 'Рекомендуемые группы',
    'seeAll': 'Все',
    'chat': 'Чат',
    'recentChats': 'Недавние чаты',
    'open': 'Открыть',
    'dueCount': '{n} к повтору',
    'practiceByPlaying': 'Учись в игре',
    'gamesHubHint': 'Четыре игры: пары, картинки, конструктор, память.',
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
    'discussHint': 'Обсуждайте здесь — убедите город',
    'nightSilence': 'Ночная тишина — чат откроется днём',
    'send': 'Отправить',
    'dayDiscuss': 'День · обсуждение',
    'autoIn': 'Авто через',
    'pickTargetHint': 'Можно выбрать цель до конца ночи',
    'waitNightHint': 'Ночь идёт сама — ждите подсказки рассвета',
    'pickTarget': 'Выбрать',
    'locked': 'Выбрано',
    'changePhoto': 'Сменить фото',
    'chooseFromGallery': 'Выбрать из галереи',
    'takePhoto': 'Сделать фото',
    'removePhoto': 'Удалить фото',
    'displayName': 'Имя',
    'bio': 'О себе',
    'save': 'Сохранить',
    'profileUpdated': 'Профиль обновлён',
    'profileUpdateFailed': 'Не удалось обновить профиль',
    'stopListening': 'Стоп',
    'listening': 'Слушаю… говорите',
    'recognizedText': 'Распознано',
    'pronunciationCorrect': 'Верно!',
    'pronunciationScore': 'Оценка: {n}%',
    'overallScore': 'Общая оценка: {n}%',
    'matchedWords': 'Совпавшие слова',
    'missingWords': 'Пропущенные слова',
    'extraWords': 'Лишние слова',
    'incorrectWords': 'Неверные слова',
    'ratingExcellent': 'Отлично',
    'ratingGood': 'Хорошо',
    'ratingNeedsPractice': 'Нужна практика',
    'tapMicToPractice': 'Нажмите микрофон для практики произношения',
  };

  static const _uz = <String, String>{
    'navHome': 'Bosh sahifa',
    'navChats': 'Chatlar',
    'navAi': 'AI',
    'navVocab': 'Lug‘at',
    'navWords': 'So‘zlar',
    'navPractice': 'Mashq',
    'navGames': 'O‘yinlar',
    'navRooms': 'Xonalar',
    'navProfile': 'Profil',
    'searchWords': 'So‘z qidirish',
    'wordsLearnedToday': 'Bugun {n} yangi so‘z',
    'wordsToReview': 'Takrorlash',
    'reviewDue': '{n} ta takrorlash',
    'weeklyProgress': 'Haftalik progress',
    'accuracy': 'Aniqlik',
    'srsNew': 'Yangi',
    'srsLearning': 'O‘rganilmoqda',
    'srsReview': 'Takror',
    'srsMastered': 'O‘zlashtirilgan',
    'definition': 'Ta’rif',
    'exampleSentence': 'Misol',
    'synonyms': 'Sinonimlar',
    'antonyms': 'Antonımlar',
    'collocations': 'Birikmalar',
    'verbForms': 'Fe’l shakllari',
    'addToDeck': 'Daftarga qo‘shish',
    'addedToDeck': 'Daftarga qo‘shildi',
    'sessionComplete': 'Sessiya tugadi!',
    'noWordsDue': 'Hozircha takrorlash yo‘q.',
    'practiceAnyway': '10 so‘z mashq qilish',
    'restart': 'Qayta boshlash',
    'tapToFlip': 'O‘girish uchun bosing',
    'again': 'Yana',
    'good': 'Yaxshi',
    'score': 'Ball',
    'done': 'Tayyor',
    'reset': 'Tozalash',
    'gameMatchMeaning': 'So‘z → Ma’no',
    'gameMatchMeaningHint': 'So‘z va tarjimani bog‘lang',
    'gameImageWord': 'Rasm → So‘z',
    'gameImageWordHint': 'To‘g‘ri so‘zni tanlang',
    'gameWordBuilder': 'So‘z yig‘ish',
    'gameWordBuilderHint': 'Harflarni joylashtiring',
    'gameMemoryCards': 'Xotira kartalari',
    'gameMemoryCardsHint': 'Juftlarni toping',
    'quickActions': 'Tezkor amallar',
    'startPracticing': 'HOZIR MASHQ QILING',
    'findPartner': 'Hamkor topish',
    'joinVoiceRoom': 'Ovozli xona',
    'practiceWithAi': 'AI bilan mashq',
    'peopleOnline': 'Onlayn odamlar',
    'recommendedPartners': 'Tavsiya etilgan hamkorlar',
    'vocabularyReview': 'Lug‘at takrorlash',
    'trendingVoiceRooms': 'Mashhur ovozli xonalar',
    'popularGames': 'Mashhur o‘yinlar',
    'wordsDue': '{n} so‘z takrorlash uchun',
    'onlineCount': '{n} onlayn',
    'follow': 'Kuzatish',
    'message': 'Xabar',
    'friends': 'Do‘stlar',
    'voiceHours': 'Ovoz soatlari',
    'wordsLearned': 'O‘rganilgan so‘zlar',
    'achievements': 'Yutuqlar',
    'learningStats': 'Statistika',
    'easy': 'Oson',
    'medium': 'O‘rtacha',
    'hard': 'Qiyin',
    'review': 'Takrorlash',
    'dailyLesson': 'Kunlik dars',
    'translation': 'Tarjima',
    'pronunciation': 'Talaffuz',
    'grammar': 'Grammatika',
    'roleplay': 'Rolli o‘yin',
    'aiTutor': 'AI o‘qituvchi',
    'noWordsYet': 'Hali so‘zlar yo‘q',
    'noWordsHint': 'Daftarni oching yoki qidiruv filtrlarini tozalang',
    'thinking': 'O‘ylayapman…',
    'askAnything': 'Tillar haqida so‘rang…',
    'nativeLang': 'Ona tili',
    'learningLang': 'O‘rganadi',
    'addFriend': 'Do‘st qo‘shish',
    'socialMentors': 'Ijtimoiy va mentorlar',
    'voiceMessage': 'Ovozli xabar',
    'emptyChatsHint': 'Hamkor toping yoki guruh yarating',
    'mentor': 'Mentor',
    'live': 'Jonli',
    'playersCount': '{n} o‘yinchi',
    'remainingFree': '{n} qoldi',
    'tutor': 'O‘qituvchi',
    'ielts': 'IELTS',
    'vocabStats': 'Sizning progress',
    'totalWords': 'Jami',
    'favorites': 'Sevimlilar',
    'mastered': 'O‘zlashtirilgan',
    'profileStreak': 'Seriya',
    'profileXp': 'XP',
    'profileLevel': 'Daraja',
    'languages': 'Tillar',
    'interests': 'Qiziqishlar',
    'badges': 'Nishonlar',
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
    'recommendedGroups': 'Tavsiya etilgan guruhlar',
    'seeAll': 'Hammasi',
    'chat': 'Chat',
    'recentChats': 'So‘nggi chatlar',
    'open': 'Ochish',
    'dueCount': '{n} takrorlash',
    'practiceByPlaying': 'O‘ynab o‘rganing',
    'gamesHubHint': 'To‘rt o‘yin: juftlash, rasm, quruvchi, xotira.',
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
    'discussHint': 'Bu yerda muhokama qiling',
    'nightSilence': 'Tun jimligi — suhbat kunduzi ochiladi',
    'send': 'Yuborish',
    'dayDiscuss': 'Kun · muhokama',
    'autoIn': 'Avto',
    'pickTargetHint': 'Tun tugashidan oldin nishon tanlash mumkin',
    'waitNightHint': 'Tun avtomatik — tong maslahatini kuting',
    'pickTarget': 'Tanlash',
    'locked': 'Tanlandi',
    'changePhoto': 'Fotoni almashtirish',
    'chooseFromGallery': 'Galereyadan tanlash',
    'takePhoto': 'Rasmga olish',
    'removePhoto': 'Fotoni olib tashlash',
    'displayName': 'Ism',
    'bio': 'Bio',
    'save': 'Saqlash',
    'profileUpdated': 'Profil yangilandi',
    'profileUpdateFailed': 'Profilni yangilab bo‘lmadi',
    'stopListening': 'To‘xtatish',
    'listening': 'Tinglayapman… gapiring',
    'recognizedText': 'Tanildi',
    'pronunciationCorrect': 'To‘g‘ri!',
    'pronunciationScore': 'Ball: {n}%',
    'overallScore': 'Umumiy ball: {n}%',
    'matchedWords': 'Mos kelgan so‘zlar',
    'missingWords': 'Yetishmayotgan so‘zlar',
    'extraWords': 'Ortiqcha so‘zlar',
    'incorrectWords': 'Noto‘g‘ri so‘zlar',
    'ratingExcellent': 'A’lo',
    'ratingGood': 'Yaxshi',
    'ratingNeedsPractice': 'Mashq kerak',
    'tapMicToPractice': 'Talaffuz mashqi uchun mikrofonga bosing',
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
  String get navAi => t('navAi');
  String get navVocab => t('navVocab');
  String get navWords => t('navWords');
  String get navPractice => t('navPractice');
  String get navGames => t('navGames');
  String get navRooms => t('navRooms');
  String get navProfile => t('navProfile');
  String get searchWords => t('searchWords');
  String wordsLearnedToday(int n) => t('wordsLearnedToday', {'n': '$n'});
  String get wordsToReview => t('wordsToReview');
  String reviewDue(int n) => t('reviewDue', {'n': '$n'});
  String get weeklyProgress => t('weeklyProgress');
  String get accuracy => t('accuracy');
  String get srsNew => t('srsNew');
  String get srsLearning => t('srsLearning');
  String get srsReview => t('srsReview');
  String get srsMastered => t('srsMastered');
  String get definition => t('definition');
  String get exampleSentence => t('exampleSentence');
  String get synonyms => t('synonyms');
  String get antonyms => t('antonyms');
  String get collocations => t('collocations');
  String get verbForms => t('verbForms');
  String get addToDeck => t('addToDeck');
  String get addedToDeck => t('addedToDeck');
  String get sessionComplete => t('sessionComplete');
  String get noWordsDue => t('noWordsDue');
  String get practiceAnyway => t('practiceAnyway');
  String get restart => t('restart');
  String get tapToFlip => t('tapToFlip');
  String get again => t('again');
  String get good => t('good');
  String get score => t('score');
  String get done => t('done');
  String get reset => t('reset');
  String get gameMatchMeaning => t('gameMatchMeaning');
  String get gameMatchMeaningHint => t('gameMatchMeaningHint');
  String get gameImageWord => t('gameImageWord');
  String get gameImageWordHint => t('gameImageWordHint');
  String get gameWordBuilder => t('gameWordBuilder');
  String get gameWordBuilderHint => t('gameWordBuilderHint');
  String get gameMemoryCards => t('gameMemoryCards');
  String get gameMemoryCardsHint => t('gameMemoryCardsHint');
  String get quickActions => t('quickActions');
  String get startPracticing => t('startPracticing');
  String get findPartner => t('findPartner');
  String get joinVoiceRoom => t('joinVoiceRoom');
  String get practiceWithAi => t('practiceWithAi');
  String get peopleOnline => t('peopleOnline');
  String get recommendedPartners => t('recommendedPartners');
  String get vocabularyReview => t('vocabularyReview');
  String get trendingVoiceRooms => t('trendingVoiceRooms');
  String get popularGames => t('popularGames');
  String wordsDue(int n) => t('wordsDue', {'n': '$n'});
  String onlineCount(int n) => t('onlineCount', {'n': '$n'});
  String get follow => t('follow');
  String get message => t('message');
  String get friends => t('friends');
  String get voiceHours => t('voiceHours');
  String get wordsLearned => t('wordsLearned');
  String get achievements => t('achievements');
  String get learningStats => t('learningStats');
  String get easy => t('easy');
  String get medium => t('medium');
  String get hard => t('hard');
  String get review => t('review');
  String get dailyLesson => t('dailyLesson');
  String get translation => t('translation');
  String get pronunciation => t('pronunciation');
  String get grammar => t('grammar');
  String get roleplay => t('roleplay');
  String get aiTutor => t('aiTutor');
  String get noWordsYet => t('noWordsYet');
  String get noWordsHint => t('noWordsHint');
  String get thinking => t('thinking');
  String get askAnything => t('askAnything');
  String get nativeLang => t('nativeLang');
  String get learningLang => t('learningLang');
  String get addFriend => t('addFriend');
  String get socialMentors => t('socialMentors');
  String get voiceMessage => t('voiceMessage');
  String get emptyChatsHint => t('emptyChatsHint');
  String get mentor => t('mentor');
  String get live => t('live');
  String playersCount(int n) => t('playersCount', {'n': '$n'});
  String remainingFree(int n) => t('remainingFree', {'n': '$n'});
  String get tutor => t('tutor');
  String get ielts => t('ielts');
  String get vocabStats => t('vocabStats');
  String get totalWords => t('totalWords');
  String get favorites => t('favorites');
  String get mastered => t('mastered');
  String get profileStreak => t('profileStreak');
  String get profileXp => t('profileXp');
  String get profileLevel => t('profileLevel');
  String get languages => t('languages');
  String get interests => t('interests');
  String get badges => t('badges');
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
  String get recommendedGroups => t('recommendedGroups');
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
  String get discussHint => t('discussHint');
  String get nightSilence => t('nightSilence');
  String get send => t('send');
  String get dayDiscuss => t('dayDiscuss');
  String get autoIn => t('autoIn');
  String get pickTargetHint => t('pickTargetHint');
  String get waitNightHint => t('waitNightHint');
  String get pickTarget => t('pickTarget');
  String get locked => t('locked');
  String get changePhoto => t('changePhoto');
  String get chooseFromGallery => t('chooseFromGallery');
  String get takePhoto => t('takePhoto');
  String get removePhoto => t('removePhoto');
  String get displayName => t('displayName');
  String get bio => t('bio');
  String get save => t('save');
  String get profileUpdated => t('profileUpdated');
  String get profileUpdateFailed => t('profileUpdateFailed');
  String get stopListening => t('stopListening');
  String get listening => t('listening');
  String get recognizedText => t('recognizedText');
  String get pronunciationCorrect => t('pronunciationCorrect');
  String get matchedWords => t('matchedWords');
  String get missingWords => t('missingWords');
  String get extraWords => t('extraWords');
  String get incorrectWords => t('incorrectWords');
  String get ratingExcellent => t('ratingExcellent');
  String get ratingGood => t('ratingGood');
  String get ratingNeedsPractice => t('ratingNeedsPractice');
  String get tapMicToPractice => t('tapMicToPractice');
  String pronunciationScore(int n) => t('pronunciationScore', {'n': '$n'});
  String overallScore(int n) => t('overallScore', {'n': '$n'});

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
