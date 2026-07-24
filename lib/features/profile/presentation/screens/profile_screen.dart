import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/services/avatar_picker.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/lingua_button.dart';
import '../../../../shared/widgets/premium_card.dart';
import '../../../../shared/widgets/safe_body.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../vocabulary/application/vocabulary_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(authControllerProvider).user ?? MockData.currentUser;
    final s = ref.watch(appStringsProvider);
    final vocab = ref.watch(vocabularyProvider);
    final user = me;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.profile),
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeBody(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Center(
              child: GestureDetector(
                onTap: () => context.push('/profile/edit'),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AppAvatar(
                      name: user.displayName,
                      url: user.avatarUrl,
                      size: 104,
                      status: user.status,
                      showStatus: true,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              user.displayName,
              textAlign: TextAlign.center,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '@${user.username}',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            PremiumCard(
              child: Row(
                children: [
                  _Stat(
                    label: s.profileStreak,
                    value: '${user.streak}',
                    icon: Icons.local_fire_department_rounded,
                    color: AppColors.streakOrange,
                  ),
                  _Stat(
                    label: s.mastered,
                    value: '${vocab.masteredCount}',
                    icon: Icons.emoji_events_rounded,
                    color: AppColors.xpGold,
                  ),
                  _Stat(
                    label: s.wordsLearned,
                    value: '${vocab.deck.length}',
                    icon: Icons.menu_book_outlined,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LinguaButton(
              label: s.editProfile,
              isOutlined: true,
              onPressed: () => context.push('/profile/edit'),
            ),
            const SizedBox(height: 8),
            LinguaButton(
              label: s.navPractice,
              onPressed: () => context.go('/practice'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(label, style: context.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _bio;
  var _ready = false;
  String? _avatarPath;
  var _clearAvatar = false;
  var _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    final user = ref.read(authControllerProvider).user ?? MockData.currentUser;
    _name = TextEditingController(text: user.displayName);
    _bio = TextEditingController(text: user.bio);
    _avatarPath = user.avatarUrl;
    _ready = true;
  }

  @override
  void dispose() {
    if (_ready) {
      _name.dispose();
      _bio.dispose();
    }
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final path = await AvatarPicker().pickAndSave(source: source);
      if (path == null || !mounted) return;
      setState(() {
        _avatarPath = path;
        _clearAvatar = false;
      });
    } catch (_) {
      if (mounted) {
        context.showSnack('Could not open photo picker', isError: true);
      }
    }
  }

  void _showAvatarSheet() {
    final s = ref.read(appStringsProvider);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(s.chooseFromGallery),
                onTap: () {
                  Navigator.pop(ctx);
                  _pick(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(s.takePhoto),
                onTap: () {
                  Navigator.pop(ctx);
                  _pick(ImageSource.camera);
                },
              ),
              if (_avatarPath != null && !_clearAvatar)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(s.removePhoto),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _avatarPath = null;
                      _clearAvatar = true;
                    });
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    final s = ref.read(appStringsProvider);
    setState(() => _saving = true);
    final ok = await ref.read(authControllerProvider.notifier).updateProfile(
          displayName: _name.text.trim(),
          bio: _bio.text.trim(),
          avatarUrl: _clearAvatar ? null : _avatarPath,
          clearAvatar: _clearAvatar,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      context.showSnack(s.profileUpdated);
      context.pop();
    } else {
      context.showSnack(s.profileUpdateFailed, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final s = ref.watch(appStringsProvider);
    final previewName =
        _name.text.trim().isEmpty ? 'User' : _name.text.trim();

    return Scaffold(
      appBar: AppBar(title: Text(s.editProfile)),
      body: SafeBody(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AppAvatar(
                    name: previewName,
                    url: _clearAvatar ? null : _avatarPath,
                    size: 104,
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Material(
                      color: AppColors.primary,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _showAvatarSheet,
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _showAvatarSheet,
                child: Text(s.changePhoto),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: s.displayName),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bio,
              maxLines: 4,
              decoration: InputDecoration(labelText: s.bio),
            ),
            const SizedBox(height: 24),
            LinguaButton(
              label: s.save,
              isLoading: _saving,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
