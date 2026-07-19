import 'package:equatable/equatable.dart';

enum LanguageLevel { a1, a2, b1, b2, c1, c2 }

enum OnlineStatus { online, offline, away }

class LearningLanguage extends Equatable {
  const LearningLanguage({
    required this.code,
    required this.name,
    required this.level,
  });

  final String code;
  final String name;
  final LanguageLevel level;

  @override
  List<Object?> get props => [code, name, level];

  factory LearningLanguage.fromJson(Map<String, dynamic> json) {
    return LearningLanguage(
      code: json['code'] as String,
      name: json['name'] as String,
      level: LanguageLevel.values.firstWhere(
        (e) => e.name == (json['level'] as String).toLowerCase(),
        orElse: () => LanguageLevel.a1,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'level': level.name.toUpperCase(),
      };
}

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.username,
    required this.nativeLanguage,
    required this.learningLanguages,
    this.avatarUrl,
    this.country,
    this.countryCode,
    this.gender,
    this.age,
    this.interests = const [],
    this.bio = '',
    this.status = OnlineStatus.offline,
    this.streak = 0,
    this.xp = 0,
    this.level = 1,
    this.badges = const [],
    this.isPremium = false,
    this.isFriend = false,
    this.isFollowing = false,
    this.isBlocked = false,
  });

  final String id;
  final String displayName;
  final String username;
  final String? avatarUrl;
  final String? country;
  final String? countryCode;
  final String nativeLanguage;
  final List<LearningLanguage> learningLanguages;
  final String? gender;
  final int? age;
  final List<String> interests;
  final String bio;
  final OnlineStatus status;
  final int streak;
  final int xp;
  final int level;
  final List<String> badges;
  final bool isPremium;
  final bool isFriend;
  final bool isFollowing;
  final bool isBlocked;

  String get primaryLearning {
    if (learningLanguages.isEmpty) return '';
    return learningLanguages.first.name;
  }

  String get levelLabel {
    if (learningLanguages.isEmpty) return 'A1';
    return learningLanguages.first.level.name.toUpperCase();
  }

  UserProfile copyWith({
    String? displayName,
    String? username,
    String? avatarUrl,
    bool clearAvatarUrl = false,
    String? country,
    String? countryCode,
    String? nativeLanguage,
    List<LearningLanguage>? learningLanguages,
    String? gender,
    int? age,
    List<String>? interests,
    String? bio,
    OnlineStatus? status,
    int? streak,
    int? xp,
    int? level,
    List<String>? badges,
    bool? isPremium,
    bool? isFriend,
    bool? isFollowing,
    bool? isBlocked,
  }) {
    return UserProfile(
      id: id,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      avatarUrl: clearAvatarUrl ? null : (avatarUrl ?? this.avatarUrl),
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      learningLanguages: learningLanguages ?? this.learningLanguages,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      interests: interests ?? this.interests,
      bio: bio ?? this.bio,
      status: status ?? this.status,
      streak: streak ?? this.streak,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      badges: badges ?? this.badges,
      isPremium: isPremium ?? this.isPremium,
      isFriend: isFriend ?? this.isFriend,
      isFollowing: isFollowing ?? this.isFollowing,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      displayName: json['displayName'] as String? ?? '',
      username: json['username'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      country: json['country'] as String?,
      countryCode: json['countryCode'] as String?,
      nativeLanguage: json['nativeLanguage'] as String? ?? '',
      learningLanguages: (json['learningLanguages'] as List<dynamic>? ?? [])
          .map((e) => LearningLanguage.fromJson(e as Map<String, dynamic>))
          .toList(),
      gender: json['gender'] as String?,
      age: json['age'] as int?,
      interests: (json['interests'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      bio: json['bio'] as String? ?? '',
      status: OnlineStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'offline'),
        orElse: () => OnlineStatus.offline,
      ),
      streak: json['streak'] as int? ?? 0,
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      badges: (json['badges'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      isPremium: json['isPremium'] as bool? ?? false,
      isFriend: json['isFriend'] as bool? ?? false,
      isFollowing: json['isFollowing'] as bool? ?? false,
      isBlocked: json['isBlocked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'username': username,
        'avatarUrl': avatarUrl,
        'country': country,
        'countryCode': countryCode,
        'nativeLanguage': nativeLanguage,
        'learningLanguages':
            learningLanguages.map((e) => e.toJson()).toList(),
        'gender': gender,
        'age': age,
        'interests': interests,
        'bio': bio,
        'status': status.name,
        'streak': streak,
        'xp': xp,
        'level': level,
        'badges': badges,
        'isPremium': isPremium,
      };

  @override
  List<Object?> get props =>
      [id, username, displayName, avatarUrl, bio, xp, streak, status];
}
