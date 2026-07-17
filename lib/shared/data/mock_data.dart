import '../models/learning_stats.dart';
import '../models/message.dart';
import '../models/user_profile.dart';
import '../models/vocabulary_item.dart';
import '../models/conversation.dart';

/// Demo dataset so the app runs fully without a backend.
class MockData {
  MockData._();

  static final currentUser = UserProfile(
    id: 'me',
    displayName: 'Alex Rivera',
    username: 'alexr',
    avatarUrl: null,
    country: 'United States',
    countryCode: 'US',
    nativeLanguage: 'English',
    learningLanguages: const [
      LearningLanguage(code: 'es', name: 'Spanish', level: LanguageLevel.b1),
      LearningLanguage(code: 'fr', name: 'French', level: LanguageLevel.a2),
    ],
    interests: const ['Travel', 'Music', 'Cooking', 'Tech'],
    bio: 'Learning Spanish for travel. Happy to help with English!',
    status: OnlineStatus.online,
    streak: 12,
    xp: 2480,
    level: 8,
    badges: const ['early_bird', 'week_streak', 'chatty'],
    isPremium: false,
  );

  static final users = <UserProfile>[
    UserProfile(
      id: 'u1',
      displayName: 'María García',
      username: 'mariag',
      country: 'Spain',
      countryCode: 'ES',
      nativeLanguage: 'Spanish',
      learningLanguages: const [
        LearningLanguage(code: 'en', name: 'English', level: LanguageLevel.b2),
      ],
      interests: const ['Cinema', 'Hiking', 'Books'],
      bio: 'Madrileña. Let’s practice together 🇪🇸',
      status: OnlineStatus.online,
      streak: 45,
      xp: 9200,
      level: 22,
      badges: const ['polyglot', 'mentor'],
      isFriend: true,
    ),
    UserProfile(
      id: 'u2',
      displayName: 'Hans Müller',
      username: 'hansm',
      country: 'Germany',
      countryCode: 'DE',
      nativeLanguage: 'German',
      learningLanguages: const [
        LearningLanguage(code: 'en', name: 'English', level: LanguageLevel.c1),
      ],
      interests: const ['Football', 'Engineering'],
      bio: 'Berlin-based engineer. Native DE speaker.',
      status: OnlineStatus.online,
      streak: 7,
      xp: 3100,
      level: 11,
      badges: const ['mentor'],
    ),
    UserProfile(
      id: 'u3',
      displayName: 'Yuki Tanaka',
      username: 'yukit',
      country: 'Japan',
      countryCode: 'JP',
      nativeLanguage: 'Japanese',
      learningLanguages: const [
        LearningLanguage(code: 'en', name: 'English', level: LanguageLevel.b1),
      ],
      interests: const ['Anime', 'Photography', 'Tea'],
      bio: 'Tokyo. Looking for language pals!',
      status: OnlineStatus.away,
      streak: 3,
      xp: 890,
      level: 4,
    ),
    UserProfile(
      id: 'u4',
      displayName: 'Sophie Dubois',
      username: 'sophied',
      country: 'France',
      countryCode: 'FR',
      nativeLanguage: 'French',
      learningLanguages: const [
        LearningLanguage(code: 'en', name: 'English', level: LanguageLevel.b2),
        LearningLanguage(code: 'es', name: 'Spanish', level: LanguageLevel.a2),
      ],
      interests: const ['Art', 'Wine', 'Travel'],
      bio: 'Parisian. Échange linguistique welcome.',
      status: OnlineStatus.online,
      streak: 21,
      xp: 5600,
      level: 15,
      isFollowing: true,
    ),
    UserProfile(
      id: 'u5',
      displayName: 'Carlos Silva',
      username: 'carloss',
      country: 'Brazil',
      countryCode: 'BR',
      nativeLanguage: 'Portuguese',
      learningLanguages: const [
        LearningLanguage(code: 'en', name: 'English', level: LanguageLevel.a2),
      ],
      interests: const ['Samba', 'Football', 'Cooking'],
      bio: 'Rio. Teaching PT-BR, learning EN.',
      status: OnlineStatus.offline,
      streak: 1,
      xp: 220,
      level: 2,
    ),
  ];

  static List<ChatConversation> conversations() {
    final now = DateTime.now();
    return [
      ChatConversation(
        id: 'g1',
        type: ConversationType.group,
        title: 'Spanish Practice 🇪🇸',
        description: 'Daily speaking practice — A2 to B2',
        members: [currentUser, users[0], users[3], users[4]],
        adminIds: const ['me', 'u1'],
        unreadCount: 5,
        updatedAt: now.subtract(const Duration(minutes: 1)),
        lastMessage: ChatMessage(
          id: 'gm1',
          conversationId: 'g1',
          senderId: 'u1',
          type: MessageType.text,
          text: 'Who wants to do a 10-min voice round?',
          createdAt: now.subtract(const Duration(minutes: 1)),
          status: MessageStatus.delivered,
        ),
      ),
      ChatConversation(
        id: 'c1',
        peer: users[0],
        unreadCount: 2,
        updatedAt: now.subtract(const Duration(minutes: 3)),
        lastMessage: ChatMessage(
          id: 'm1',
          conversationId: 'c1',
          senderId: 'u1',
          type: MessageType.text,
          text: '¿Cómo estás hoy? 😊',
          createdAt: now.subtract(const Duration(minutes: 3)),
          status: MessageStatus.delivered,
        ),
      ),
      ChatConversation(
        id: 'g2',
        type: ConversationType.group,
        title: 'Polyglot Café',
        description: 'EN · ES · FR · DE — casual chat',
        members: [currentUser, users[0], users[1], users[2], users[3]],
        adminIds: const ['me'],
        unreadCount: 0,
        updatedAt: now.subtract(const Duration(hours: 5)),
        lastMessage: ChatMessage(
          id: 'gm2',
          conversationId: 'g2',
          senderId: 'u2',
          type: MessageType.text,
          text: 'Guten Morgen everyone ☕',
          createdAt: now.subtract(const Duration(hours: 5)),
          status: MessageStatus.read,
        ),
      ),
      ChatConversation(
        id: 'c2',
        peer: users[3],
        unreadCount: 0,
        updatedAt: now.subtract(const Duration(hours: 2)),
        lastMessage: ChatMessage(
          id: 'm2',
          conversationId: 'c2',
          senderId: 'me',
          type: MessageType.text,
          text: 'Merci pour la correction!',
          createdAt: now.subtract(const Duration(hours: 2)),
          status: MessageStatus.read,
        ),
      ),
      ChatConversation(
        id: 'c3',
        peer: users[1],
        unreadCount: 0,
        updatedAt: now.subtract(const Duration(days: 1)),
        lastMessage: ChatMessage(
          id: 'm3',
          conversationId: 'c3',
          senderId: 'u2',
          type: MessageType.voice,
          voiceDurationSec: 12,
          createdAt: now.subtract(const Duration(days: 1)),
          status: MessageStatus.read,
        ),
      ),
    ];
  }

  static List<ChatMessage> groupMessages(String conversationId) {
    final now = DateTime.now();
    return [
      ChatMessage(
        id: 'gmsg1',
        conversationId: conversationId,
        senderId: 'u1',
        type: MessageType.text,
        text: 'Welcome to the group! Let’s keep messages in the target language 💬',
        createdAt: now.subtract(const Duration(hours: 2)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'gmsg2',
        conversationId: conversationId,
        senderId: 'me',
        type: MessageType.text,
        text: 'Excited to practice with everyone!',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 40)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'gmsg3',
        conversationId: conversationId,
        senderId: 'u3',
        type: MessageType.text,
        text: 'Same here — any topic for today?',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 20)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'gmsg4',
        conversationId: conversationId,
        senderId: 'u2',
        type: MessageType.text,
        text: 'How about travel & food?',
        createdAt: now.subtract(const Duration(minutes: 40)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'gmsg5',
        conversationId: conversationId,
        senderId: 'u1',
        type: MessageType.text,
        text: 'Who wants to do a 10-min voice round?',
        createdAt: now.subtract(const Duration(minutes: 1)),
        status: MessageStatus.delivered,
      ),
    ];
  }

  static List<ChatMessage> messagesFor(String conversationId) {
    if (conversationId.startsWith('g')) {
      return groupMessages(conversationId);
    }
    final now = DateTime.now();
    return [
      ChatMessage(
        id: 'msg1',
        conversationId: conversationId,
        senderId: 'u1',
        type: MessageType.text,
        text: '¡Hola! Ready to practice Spanish today?',
        createdAt: now.subtract(const Duration(hours: 1)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'msg2',
        conversationId: conversationId,
        senderId: 'me',
        type: MessageType.text,
        text: 'Yes! I want to talk about travel plans.',
        createdAt: now.subtract(const Duration(minutes: 55)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'msg3',
        conversationId: conversationId,
        senderId: 'u1',
        type: MessageType.text,
        text: 'Perfecto. ¿Adónde te gustaría viajar?',
        createdAt: now.subtract(const Duration(minutes: 50)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'msg4',
        conversationId: conversationId,
        senderId: 'me',
        type: MessageType.text,
        text: 'Me gustaria visitar Barcelona el proximo verano.',
        createdAt: now.subtract(const Duration(minutes: 45)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'msg5',
        conversationId: conversationId,
        senderId: 'u1',
        type: MessageType.text,
        text: '¡Genial! Small tip: "Me gustaría" with accent 😊',
        createdAt: now.subtract(const Duration(minutes: 40)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'msg6',
        conversationId: conversationId,
        senderId: 'u1',
        type: MessageType.text,
        text: '¿Cómo estás hoy? 😊',
        createdAt: now.subtract(const Duration(minutes: 3)),
        status: MessageStatus.delivered,
      ),
    ];
  }

  static const dailyGoal = DailyGoal(
    minutesDone: 8,
    messagesDone: 6,
    voiceDone: 1,
    wordsDone: 3,
    aiLessonsDone: 0,
  );

  static const stats = LearningStats(
    weeklyMinutes: [12, 25, 18, 30, 8, 22, 15],
    monthlyXp: [120, 200, 150, 300, 180, 220, 90],
    totalXp: 2480,
    totalWords: 186,
    totalMessages: 412,
    currentStreak: 12,
    longestStreak: 28,
    level: 8,
  );

  static final vocabulary = <VocabularyItem>[
    VocabularyItem(
      id: 'v1',
      word: 'gustaría',
      translation: 'would like',
      definition: 'Conditional form of gustar — polite desire.',
      example: 'Me gustaría viajar a España.',
      pronunciation: 'goos-tah-REE-ah',
      sourceLanguage: 'es',
      targetLanguage: 'en',
      isFavorite: true,
      nextReviewAt: DateTime.now().add(const Duration(hours: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    VocabularyItem(
      id: 'v2',
      word: 'próximo',
      translation: 'next / upcoming',
      definition: 'Coming after the present in time.',
      example: 'El próximo verano.',
      pronunciation: 'PROHK-see-moh',
      sourceLanguage: 'es',
      targetLanguage: 'en',
      nextReviewAt: DateTime.now().add(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    VocabularyItem(
      id: 'v3',
      word: 'corriger',
      translation: 'to correct',
      definition: 'To make something right; to fix mistakes.',
      example: 'Peux-tu corriger ma phrase?',
      pronunciation: 'ko-ree-ZHAY',
      sourceLanguage: 'fr',
      targetLanguage: 'en',
      isFavorite: false,
      nextReviewAt: DateTime.now(),
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  static final notifications = <AppNotification>[
    AppNotification(
      id: 'n1',
      title: 'Friend request',
      body: 'Sophie Dubois wants to connect',
      type: 'friend_request',
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
    AppNotification(
      id: 'n2',
      title: 'Daily goal reminder',
      body: 'You are 40% toward today’s goal. Keep going!',
      type: 'daily_goal',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: true,
    ),
    AppNotification(
      id: 'n3',
      title: 'Vocabulary review',
      body: '3 words are due for review',
      type: 'vocabulary',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  static const aiSuggestions = [
    'Practice ordering food in Spanish',
    '5-minute pronunciation drill',
    'Travel English: airport phrases',
    'Grammar: ser vs estar',
  ];
}
