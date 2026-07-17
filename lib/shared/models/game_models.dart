import 'package:flutter/material.dart';

/// A single checklist goal inside an AI roleplay quest.
class QuestGoal {
  const QuestGoal({
    required this.id,
    required this.label,
    required this.keywords,
  });

  final String id;
  final String label;

  /// User message must contain at least one keyword (case-insensitive).
  final List<String> keywords;
}

/// Difficulty / unlock level for AI quests.
enum QuestDifficulty {
  beginner,
  intermediate,
  advanced,
  expert,
}

extension QuestDifficultyX on QuestDifficulty {
  String get label {
    switch (this) {
      case QuestDifficulty.beginner:
        return 'Beginner';
      case QuestDifficulty.intermediate:
        return 'Intermediate';
      case QuestDifficulty.advanced:
        return 'Advanced';
      case QuestDifficulty.expert:
        return 'Expert';
    }
  }

  Color get color {
    switch (this) {
      case QuestDifficulty.beginner:
        return const Color(0xFF10B981);
      case QuestDifficulty.intermediate:
        return const Color(0xFF06B6D4);
      case QuestDifficulty.advanced:
        return const Color(0xFFF59E0B);
      case QuestDifficulty.expert:
        return const Color(0xFFEF4444);
    }
  }
}

/// One AI roleplay scenario with goals that get harder by level.
class AiQuest {
  const AiQuest({
    required this.id,
    required this.level,
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.roleName,
    required this.setting,
    required this.difficulty,
    required this.xpReward,
    required this.intro,
    required this.goals,
    required this.icon,
  });

  final String id;
  final int level;
  final String theme;
  final String title;
  final String subtitle;
  final String roleName;
  final String setting;
  final QuestDifficulty difficulty;
  final int xpReward;
  final String intro;
  final List<QuestGoal> goals;
  final IconData icon;
}

class QuestChatMessage {
  const QuestChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String role; // user | assistant | system
  final String content;
  final DateTime createdAt;
}

/// Catalog of leveled AI quests (mock content).
class GameCatalog {
  GameCatalog._();

  static final List<AiQuest> quests = [
    AiQuest(
      id: 'q1_hotel',
      level: 1,
      theme: 'Travel',
      title: 'Book a hotel',
      subtitle: 'Reserve a room for the weekend',
      roleName: 'Receptionist',
      setting: 'City Hotel front desk',
      difficulty: QuestDifficulty.beginner,
      xpReward: 40,
      icon: Icons.hotel_outlined,
      intro:
          'Welcome to City Hotel! How can I help you today? (Try to book a room — say dates, guests, and room type.)',
      goals: const [
        QuestGoal(
          id: 'g1',
          label: 'Greet and ask for a room',
          keywords: ['room', 'book', 'reservation', 'stay', 'night'],
        ),
        QuestGoal(
          id: 'g2',
          label: 'Give dates or nights',
          keywords: [
            'friday',
            'saturday',
            'weekend',
            'night',
            'nights',
            'tomorrow',
            'july',
            'august',
            'date',
          ],
        ),
        QuestGoal(
          id: 'g3',
          label: 'Confirm guests / room type',
          keywords: [
            'single',
            'double',
            'twin',
            'guest',
            'people',
            'person',
            'two',
            'one',
          ],
        ),
      ],
    ),
    AiQuest(
      id: 'q2_bank',
      level: 2,
      theme: 'Banking',
      title: 'Open a bank card',
      subtitle: 'Apply for a debit card at the branch',
      roleName: 'Bank clerk',
      setting: 'Downtown bank branch',
      difficulty: QuestDifficulty.beginner,
      xpReward: 55,
      icon: Icons.credit_card_outlined,
      intro:
          'Good afternoon. Welcome to Lingua Bank. Are you here to open an account or get a card?',
      goals: const [
        QuestGoal(
          id: 'g1',
          label: 'Ask to open a card / account',
          keywords: ['card', 'account', 'debit', 'credit', 'open', 'apply'],
        ),
        QuestGoal(
          id: 'g2',
          label: 'Share ID / personal details',
          keywords: [
            'passport',
            'id',
            'identity',
            'name',
            'address',
            'phone',
            'document',
          ],
        ),
        QuestGoal(
          id: 'g3',
          label: 'Choose card type and confirm',
          keywords: [
            'debit',
            'credit',
            'visa',
            'mastercard',
            'please',
            'yes',
            'confirm',
            'choose',
          ],
        ),
      ],
    ),
    AiQuest(
      id: 'q3_cafe',
      level: 3,
      theme: 'Daily life',
      title: 'Order at a café',
      subtitle: 'Order drinks and ask about allergens',
      roleName: 'Barista',
      setting: 'Busy neighborhood café',
      difficulty: QuestDifficulty.intermediate,
      xpReward: 65,
      icon: Icons.local_cafe_outlined,
      intro:
          'Hi there! What can I get started for you? We have coffee, tea, and pastries.',
      goals: const [
        QuestGoal(
          id: 'g1',
          label: 'Order a drink',
          keywords: [
            'coffee',
            'latte',
            'cappuccino',
            'tea',
            'espresso',
            'americano',
            'please',
          ],
        ),
        QuestGoal(
          id: 'g2',
          label: 'Ask about size or extras',
          keywords: [
            'large',
            'medium',
            'small',
            'milk',
            'oat',
            'sugar',
            'extra',
            'size',
          ],
        ),
        QuestGoal(
          id: 'g3',
          label: 'Ask about allergens / takeaway',
          keywords: [
            'allergy',
            'allergen',
            'gluten',
            'nut',
            'dairy',
            'takeaway',
            'to go',
            'take out',
          ],
        ),
      ],
    ),
    AiQuest(
      id: 'q4_clinic',
      level: 4,
      theme: 'Health',
      title: 'Visit the doctor',
      subtitle: 'Describe symptoms and ask for advice',
      roleName: 'Doctor',
      setting: 'Clinic consultation room',
      difficulty: QuestDifficulty.intermediate,
      xpReward: 80,
      icon: Icons.medical_services_outlined,
      intro:
          'Hello, please take a seat. What brings you in today? Tell me about your symptoms.',
      goals: const [
        QuestGoal(
          id: 'g1',
          label: 'Describe the main symptom',
          keywords: [
            'pain',
            'fever',
            'cough',
            'headache',
            'sore',
            'hurt',
            'sick',
            'throat',
          ],
        ),
        QuestGoal(
          id: 'g2',
          label: 'Say how long it has lasted',
          keywords: [
            'day',
            'days',
            'week',
            'since',
            'yesterday',
            'morning',
            'hour',
          ],
        ),
        QuestGoal(
          id: 'g3',
          label: 'Ask for medicine or next steps',
          keywords: [
            'medicine',
            'prescription',
            'what should',
            'advice',
            'test',
            'rest',
            'pharmacy',
          ],
        ),
      ],
    ),
    AiQuest(
      id: 'q5_job',
      level: 5,
      theme: 'Jobs',
      title: 'Job interview',
      subtitle: 'Introduce yourself and answer questions',
      roleName: 'Hiring manager',
      setting: 'Tech company interview',
      difficulty: QuestDifficulty.advanced,
      xpReward: 100,
      icon: Icons.work_outline_rounded,
      intro:
          'Thanks for coming in. Let’s start — tell me a bit about yourself and why you applied.',
      goals: const [
        QuestGoal(
          id: 'g1',
          label: 'Introduce experience / role',
          keywords: [
            'i am',
            "i'm",
            'experience',
            'worked',
            'developer',
            'student',
            'years',
            'job',
          ],
        ),
        QuestGoal(
          id: 'g2',
          label: 'Explain motivation',
          keywords: [
            'because',
            'interested',
            'want',
            'learn',
            'team',
            'company',
            'grow',
            'passion',
          ],
        ),
        QuestGoal(
          id: 'g3',
          label: 'Ask a smart question back',
          keywords: [
            '?',
            'team',
            'role',
            'day-to-day',
            'culture',
            'next step',
            'when',
            'project',
          ],
        ),
      ],
    ),
    AiQuest(
      id: 'q6_complaint',
      level: 6,
      theme: 'Customer service',
      title: 'Handle a complaint',
      subtitle: 'Politely resolve a delayed delivery',
      roleName: 'Support agent',
      setting: 'Online shop support chat',
      difficulty: QuestDifficulty.expert,
      xpReward: 130,
      icon: Icons.support_agent_outlined,
      intro:
          'Hello, this is support. I see you contacted us about an order — how can I help?',
      goals: const [
        QuestGoal(
          id: 'g1',
          label: 'Explain the problem clearly',
          keywords: [
            'delay',
            'delayed',
            'missing',
            'wrong',
            'order',
            'package',
            'delivery',
            'not arrived',
          ],
        ),
        QuestGoal(
          id: 'g2',
          label: 'Request a solution',
          keywords: [
            'refund',
            'replace',
            'resend',
            'compensate',
            'discount',
            'please',
            'can you',
            'would like',
          ],
        ),
        QuestGoal(
          id: 'g3',
          label: 'Confirm and close politely',
          keywords: [
            'thank',
            'thanks',
            'appreciate',
            'confirm',
            'okay',
            'alright',
            'understood',
          ],
        ),
      ],
    ),
  ];
}

/// One level of the Picture Words game.
class PictureWordLevel {
  const PictureWordLevel({
    required this.id,
    required this.level,
    required this.word,
    required this.hint,
    required this.icon,
    required this.color,
    required this.minWords,
    required this.acceptedWords,
    required this.xpReward,
  });

  final String id;
  final int level;

  /// Object shown to the player (e.g. "ball").
  final String word;
  final String hint;
  final IconData icon;
  final Color color;

  /// Minimum accepted words required to clear the level.
  final int minWords;

  /// Valid associations (lowercase).
  final List<String> acceptedWords;
  final int xpReward;
}

/// Picture Words catalog (levels get harder: more words required).
class PictureWordsCatalog {
  PictureWordsCatalog._();

  static final List<PictureWordLevel> levels = [
    PictureWordLevel(
      id: 'pw1_ball',
      level: 1,
      word: 'Ball',
      hint: 'Sports · what can you say about it?',
      icon: Icons.sports_soccer,
      color: const Color(0xFF22C55E),
      minWords: 3,
      xpReward: 30,
      acceptedWords: const [
        'round',
        'kick',
        'play',
        'bounce',
        'goal',
        'football',
        'soccer',
        'throw',
        'catch',
        'sport',
        'game',
        'team',
        'circle',
        'roll',
        'hit',
      ],
    ),
    PictureWordLevel(
      id: 'pw2_apple',
      level: 2,
      word: 'Apple',
      hint: 'Food · taste, color, actions…',
      icon: Icons.apple,
      color: const Color(0xFFEF4444),
      minWords: 4,
      xpReward: 40,
      acceptedWords: const [
        'red',
        'green',
        'sweet',
        'fruit',
        'eat',
        'juice',
        'healthy',
        'tree',
        'crunchy',
        'fresh',
        'slice',
        'seed',
        'pie',
        'ripe',
        'organic',
      ],
    ),
    PictureWordLevel(
      id: 'pw3_rain',
      level: 3,
      word: 'Rain',
      hint: 'Weather · feelings and things you use',
      icon: Icons.umbrella,
      color: const Color(0xFF3B82F6),
      minWords: 5,
      xpReward: 55,
      acceptedWords: const [
        'wet',
        'umbrella',
        'cloud',
        'water',
        'drop',
        'storm',
        'cold',
        'puddle',
        'coat',
        'boots',
        'weather',
        'pour',
        'drizzle',
        'thunder',
        'forecast',
      ],
    ),
    PictureWordLevel(
      id: 'pw4_kitchen',
      level: 4,
      word: 'Kitchen',
      hint: 'Home · tools, verbs, places',
      icon: Icons.kitchen_outlined,
      color: const Color(0xFFF59E0B),
      minWords: 6,
      xpReward: 70,
      acceptedWords: const [
        'cook',
        'knife',
        'pan',
        'stove',
        'oven',
        'plate',
        'fork',
        'spoon',
        'wash',
        'cut',
        'recipe',
        'fridge',
        'boil',
        'fry',
        'bake',
        'sink',
        'food',
      ],
    ),
    PictureWordLevel(
      id: 'pw5_city',
      level: 5,
      word: 'City',
      hint: 'Places · transport, people, buildings',
      icon: Icons.location_city,
      color: const Color(0xFF8B5CF6),
      minWords: 7,
      xpReward: 90,
      acceptedWords: const [
        'street',
        'building',
        'traffic',
        'bus',
        'metro',
        'crowd',
        'noise',
        'shop',
        'park',
        'bridge',
        'taxi',
        'lights',
        'people',
        'skyscraper',
        'subway',
        'downtown',
        'urban',
      ],
    ),
    PictureWordLevel(
      id: 'pw6_happiness',
      level: 6,
      word: 'Happiness',
      hint: 'Abstract · feelings and related ideas',
      icon: Icons.sentiment_very_satisfied,
      color: const Color(0xFFEC4899),
      minWords: 8,
      xpReward: 120,
      acceptedWords: const [
        'smile',
        'joy',
        'laugh',
        'love',
        'friend',
        'peace',
        'hope',
        'fun',
        'celebrate',
        'grateful',
        'warm',
        'bright',
        'delight',
        'cheer',
        'success',
        'family',
        'kindness',
      ],
    ),
  ];
}

