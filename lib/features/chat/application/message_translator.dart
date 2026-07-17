import '../../../shared/models/app_language.dart';

/// Mock offline translator for chat messages (NestJS `/ai/translate` later).
class MessageTranslator {
  MessageTranslator._();

  static List<({String code, String label, String flag})> get targets => [
        for (final lang in AppLanguages.all)
          (code: lang.code, label: lang.name, flag: lang.flag),
      ];

  /// Phrase-level dictionary: lowercase source → translations by target code.
  static const Map<String, Map<String, String>> _phrases = {
    'hola': {
      'en': 'Hello',
      'ru': 'Привет',
      'uz': 'Salom',
      'de': 'Hallo',
      'fr': 'Bonjour',
      'pt': 'Olá',
      'ja': 'こんにちは',
      'es': 'Hola',
    },
    '¿cómo estás hoy? 😊': {
      'en': 'How are you today? 😊',
      'ru': 'Как ты сегодня? 😊',
      'uz': 'Bugun qandaysiz? 😊',
      'de': 'Wie geht es dir heute? 😊',
      'fr': 'Comment vas-tu aujourd’hui ? 😊',
      'pt': 'Como você está hoje? 😊',
      'ja': '今日の調子はどう？😊',
      'es': '¿Cómo estás hoy? 😊',
    },
    'cómo estás hoy': {
      'en': 'How are you today',
      'ru': 'Как ты сегодня',
      'uz': 'Bugun qandaysiz',
      'de': 'Wie geht es dir heute',
      'fr': 'Comment vas-tu aujourd’hui',
      'pt': 'Como você está hoje',
      'ja': '今日の調子はどう',
      'es': 'Cómo estás hoy',
    },
    'merci pour la correction!': {
      'en': 'Thanks for the correction!',
      'ru': 'Спасибо за исправление!',
      'uz': 'Tuzatish uchun rahmat!',
      'de': 'Danke für die Korrektur!',
      'fr': 'Merci pour la correction!',
      'pt': 'Obrigado pela correção!',
      'ja': '訂正ありがとう！',
      'es': '¡Gracias por la corrección!',
    },
    'who wants to do a 10-min voice round?': {
      'en': 'Who wants to do a 10-min voice round?',
      'ru': 'Кто хочет 10-минутный голосовой раунд?',
      'uz': 'Kim 10 daqiqalik ovozli raund qilmoqchi?',
      'es': '¿Quién quiere una ronda de voz de 10 min?',
      'de': 'Wer will eine 10-Minuten-Sprachrunde?',
      'fr': 'Qui veut un round vocal de 10 min ?',
      'pt': 'Quem quer uma rodada de voz de 10 min?',
      'ja': '10分のボイスラウンドやりたい人？',
    },
    'guten morgen everyone ☕': {
      'en': 'Good morning everyone ☕',
      'ru': 'Доброе утро всем ☕',
      'uz': 'Hammaga xayrli tong ☕',
      'es': 'Buenos días a todos ☕',
      'de': 'Guten Morgen everyone ☕',
      'fr': 'Bonjour à tous ☕',
      'pt': 'Bom dia a todos ☕',
      'ja': 'みんなおはよう ☕',
    },
    'nice! keep practicing 💬': {
      'en': 'Nice! Keep practicing 💬',
      'ru': 'Отлично! Продолжай практиковать 💬',
      'uz': 'Ajoyib! Mashq qilishda davom eting 💬',
      'es': '¡Genial! Sigue practicando 💬',
      'de': 'Super! Weiter üben 💬',
      'fr': 'Super ! Continue à pratiquer 💬',
      'pt': 'Ótimo! Continue praticando 💬',
      'ja': 'いいね！練習を続けて 💬',
    },
    'nice point! anyone else want to add something?': {
      'en': 'Nice point! Anyone else want to add something?',
      'ru': 'Хороший аргумент! Кто-то ещё хочет добавить?',
      'uz': 'Yaxshi fikr! Yana kimdir qo‘shmoqchimisi?',
      'es': '¡Buen punto! ¿Alguien más quiere añadir algo?',
      'de': 'Guter Punkt! Möchte noch jemand etwas sagen?',
      'fr': 'Bon point ! Quelqu’un d’autre veut ajouter quelque chose ?',
      'pt': 'Bom ponto! Alguém mais quer acrescentar?',
      'ja': 'いい指摘！他に付け足したい人は？',
    },
    '¡hola! ready to practice spanish today?': {
      'en': 'Hi! Ready to practice Spanish today?',
      'ru': 'Привет! Готов практиковать испанский сегодня?',
      'uz': 'Salom! Bugun ispan tilini mashq qilishga tayyormisiz?',
      'es': '¡Hola! ¿Listo para practicar español hoy?',
      'de': 'Hallo! Bereit, heute Spanisch zu üben?',
      'fr': 'Salut ! Prêt à pratiquer l’espagnol aujourd’hui ?',
      'pt': 'Olá! Pronto para praticar espanhol hoje?',
      'ja': 'こんにちは！今日スペイン語の練習する？',
    },
    'welcome to the group! let’s keep messages in the target language 💬': {
      'en': 'Welcome to the group! Let’s keep messages in the target language 💬',
      'ru': 'Добро пожаловать в группу! Пишем на языке практики 💬',
      'uz': 'Guruhga xush kelibsiz! Maqsad tilida yozamiz 💬',
      'es': '¡Bienvenido al grupo! Mantengamos los mensajes en el idioma objetivo 💬',
      'de': 'Willkommen in der Gruppe! Bleiben wir in der Zielsprache 💬',
      'fr': 'Bienvenue dans le groupe ! Restons dans la langue cible 💬',
      'pt': 'Bem-vindo ao grupo! Vamos manter as mensagens no idioma-alvo 💬',
      'ja': 'グループへようこそ！目標言語で話そう 💬',
    },
    'excited to practice with everyone!': {
      'en': 'Excited to practice with everyone!',
      'ru': 'Рад практиковать со всеми!',
      'uz': 'Hammaga bilan mashq qilishdan xursandman!',
      'es': '¡Emocionado de practicar con todos!',
      'de': 'Freue mich, mit allen zu üben!',
      'fr': 'Ravi de pratiquer avec tout le monde !',
      'pt': 'Animado para praticar com todos!',
      'ja': 'みんなと練習できて嬉しい！',
    },
    'same here — any topic for today?': {
      'en': 'Same here — any topic for today?',
      'ru': 'Тоже самое — какая тема на сегодня?',
      'uz': 'Men ham — bugun qanday mavzu?',
      'es': 'Igual aquí — ¿algún tema para hoy?',
      'de': 'Ebenso — irgendein Thema für heute?',
      'fr': 'Pareil ici — un sujet pour aujourd’hui ?',
      'pt': 'Aqui também — algum tema para hoje?',
      'ja': '同じく！今日のトピックある？',
    },
    'how about travel & food?': {
      'en': 'How about travel & food?',
      'ru': 'Как насчёт путешествий и еды?',
      'uz': 'Sayohat va ovqat haqida nima deysiz?',
      'es': '¿Qué tal viajes y comida?',
      'de': 'Wie wäre es mit Reisen & Essen?',
      'fr': 'Et si on parlait voyage et cuisine ?',
      'pt': 'Que tal viagem e comida?',
      'ja': '旅行と食べ物はどう？',
    },
    'assalomu alaykum': {
      'en': 'Peace be upon you / Hello',
      'ru': 'Ассаламу алейкум / Здравствуйте',
      'uz': 'Assalomu alaykum',
      'es': 'La paz sea contigo / Hola',
      'de': 'Friede sei mit dir / Hallo',
      'fr': 'Que la paix soit sur vous / Bonjour',
      'pt': 'A paz esteja convosco / Olá',
      'ja': 'アッサラーム・アレイコム',
    },
    'привет': {
      'en': 'Hi',
      'ru': 'Привет',
      'uz': 'Salom',
      'es': 'Hola',
      'de': 'Hallo',
      'fr': 'Salut',
      'pt': 'Oi',
      'ja': 'こんにちは',
    },
  };

  static const Map<String, Map<String, String>> _words = {
    'hola': {
      'en': 'hello',
      'ru': 'привет',
      'uz': 'salom',
      'de': 'hallo',
      'fr': 'bonjour',
      'pt': 'olá',
      'ja': 'こんにちは',
      'es': 'hola',
    },
    'salom': {
      'en': 'hello',
      'ru': 'привет',
      'uz': 'salom',
      'es': 'hola',
      'de': 'hallo',
      'fr': 'bonjour',
      'pt': 'olá',
      'ja': 'こんにちは',
    },
    'привет': {
      'en': 'hi',
      'ru': 'привет',
      'uz': 'salom',
      'es': 'hola',
      'de': 'hallo',
      'fr': 'salut',
      'pt': 'oi',
      'ja': 'こんにちは',
    },
    'merci': {
      'en': 'thanks',
      'ru': 'спасибо',
      'uz': 'rahmat',
      'de': 'danke',
      'fr': 'merci',
      'pt': 'obrigado',
      'ja': 'ありがとう',
      'es': 'gracias',
    },
    'gracias': {
      'en': 'thanks',
      'ru': 'спасибо',
      'uz': 'rahmat',
      'de': 'danke',
      'fr': 'merci',
      'pt': 'obrigado',
      'ja': 'ありがとう',
      'es': 'gracias',
    },
    'rahmat': {
      'en': 'thanks',
      'ru': 'спасибо',
      'uz': 'rahmat',
      'es': 'gracias',
      'de': 'danke',
      'fr': 'merci',
      'pt': 'obrigado',
      'ja': 'ありがとう',
    },
    'bonjour': {
      'en': 'good morning',
      'ru': 'доброе утро',
      'uz': 'xayrli tong',
      'de': 'guten morgen',
      'fr': 'bonjour',
      'pt': 'bom dia',
      'ja': 'おはよう',
      'es': 'buenos días',
    },
    'guten': {
      'en': 'good',
      'ru': 'добрый',
      'uz': 'yaxshi',
      'de': 'guten',
      'fr': 'bon',
      'pt': 'bom',
      'ja': '良い',
      'es': 'buen',
    },
    'morgen': {
      'en': 'morning',
      'ru': 'утро',
      'uz': 'tong',
      'de': 'morgen',
      'fr': 'matin',
      'pt': 'manhã',
      'ja': '朝',
      'es': 'mañana',
    },
    'today': {
      'en': 'today',
      'ru': 'сегодня',
      'uz': 'bugun',
      'es': 'hoy',
      'de': 'heute',
      'fr': "aujourd'hui",
      'pt': 'hoje',
      'ja': '今日',
    },
    'practice': {
      'en': 'practice',
      'ru': 'практика',
      'uz': 'mashq',
      'es': 'practicar',
      'de': 'üben',
      'fr': 'pratiquer',
      'pt': 'praticar',
      'ja': '練習',
    },
    'group': {
      'en': 'group',
      'ru': 'группа',
      'uz': 'guruh',
      'es': 'grupo',
      'de': 'gruppe',
      'fr': 'groupe',
      'pt': 'grupo',
      'ja': 'グループ',
    },
  };

  static Future<String> translate(
    String text, {
    required String targetCode,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final trimmed = text.trim();
    if (trimmed.isEmpty) return '';

    final lower = trimmed.toLowerCase();
    final phrase = _phrases[lower];
    if (phrase != null && phrase[targetCode] != null) {
      return phrase[targetCode]!;
    }

    // Soft match: strip trailing emoji-ish noise for lookup
    final soft = lower
        .replaceAll(RegExp(r'[😊☕💬✈️¡!?.…]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    for (final entry in _phrases.entries) {
      final keySoft = entry.key
          .replaceAll(RegExp(r'[😊☕💬✈️¡!?.…]'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (keySoft == soft && entry.value[targetCode] != null) {
        return entry.value[targetCode]!;
      }
    }

    final translatedWords = <String>[];
    for (final raw in trimmed.split(RegExp(r'\s+'))) {
      final clean = raw.toLowerCase().replaceAll(RegExp(r'[^\wÀ-ÿ-]'), '');
      final punct = raw.replaceAll(RegExp(r'[\wÀ-ÿ-]'), '');
      final map = _words[clean];
      if (map != null && map[targetCode] != null) {
        translatedWords.add('${map[targetCode]}$punct');
      } else {
        translatedWords.add(raw);
      }
    }

    final joined = translatedWords.join(' ');
    final label = targets
        .firstWhere(
          (t) => t.code == targetCode,
          orElse: () => (code: targetCode, label: targetCode, flag: ''),
        )
        .label;

    if (joined.toLowerCase() == lower) {
      return '[$label] $trimmed';
    }
    return joined;
  }
}
