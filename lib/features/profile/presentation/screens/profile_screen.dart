import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spendly/features/auth/presentation/providers/auth_provider.dart';
import 'package:spendly/features/auth/presentation/screens/get_started_screen.dart';
import 'package:spendly/shared/theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Hero header ──────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F2440),
                    AppColors.primary,
                    Color(0xFF2A4A7F),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -20,
                    right: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.04),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.tertiary.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 36),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const _AvatarWidget(),
                            const SizedBox(height: 14),
                            Text(
                              user?.name ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Settings sections ────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionLabel('ACCOUNT'),
                  const SizedBox(height: 10),
                  _MenuCard(
                    items: [
                      _MenuItemData(
                        icon: Icons.person_outline_rounded,
                        iconColor: AppColors.tertiary,
                        label: 'Edit Profile',
                        onTap: () => _showEditProfile(context, ref, user?.name ?? ''),
                      ),
                      _MenuItemData(
                        icon: Icons.lock_outline_rounded,
                        iconColor: AppColors.secondary,
                        label: 'Change Password',
                        onTap: () => _showChangePassword(context, ref),
                      ),
                      _MenuItemData(
                        icon: Icons.notifications_none_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        label: 'Notifications',
                        onTap: () => _showNotifications(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const _SectionLabel('MORE'),
                  const SizedBox(height: 10),
                  _MenuCard(
                    items: [
                      _MenuItemData(
                        icon: Icons.help_outline_rounded,
                        iconColor: AppColors.primary,
                        label: 'Help & Support',
                        onTap: () => _showHelp(context),
                      ),
                      _MenuItemData(
                        icon: Icons.info_outline_rounded,
                        iconColor: AppColors.textSecondary,
                        label: 'About',
                        onTap: () => _showAbout(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Logout button ──────────────────────────
                  GestureDetector(
                    onTap: () => _confirmLogout(context, ref),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            size: 18,
                            color: AppColors.error,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Log Out',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Spendly',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfile(BuildContext context, WidgetRef ref, String currentName) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(currentName: currentName, ref: ref),
    );
  }

  void _showChangePassword(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChangePasswordSheet(ref: ref),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NotificationsSheet(),
    );
  }

  void _showHelp(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _HelpSheet(),
    );
  }

  void _showAbout(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AboutSheet(),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log out?',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'You will be returned to the sign in screen.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const GetStartedScreen()),
                  (_) => false,
                );
              }
            },
            child: const Text(
              'Log Out',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Avatar Widget
// ─────────────────────────────────────────────────────────

class _AvatarWidget extends ConsumerStatefulWidget {
  const _AvatarWidget();

  @override
  ConsumerState<_AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends ConsumerState<_AvatarWidget> {
  bool _uploading = false;

  Future<void> _pick() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 512,
    );
    if (image == null || !mounted) return;
    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() => _uploading = true);
    try {
      await ref
          .read(authProvider.notifier)
          .updateAvatar(bytes: bytes);
    } catch (e) {
      debugPrint('Avatar upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).valueOrNull;
    final initial = (user?.name.isNotEmpty == true)
        ? user!.name[0].toUpperCase()
        : '?';
    final avatarUrl = user?.avatarUrl;

    return GestureDetector(
      onTap: _uploading ? null : _pick,
      child: SizedBox(
        width: 88,
        height: 88,
        child: Stack(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 2.5,
                ),
              ),
              child: _uploading
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                            width: 88,
                            height: 88,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _MenuItemData {
  const _MenuItemData({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.items});
  final List<_MenuItemData> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _MenuRow(data: items[i]),
            if (i < items.length - 1)
              const Padding(
                padding: EdgeInsets.only(left: 56),
                child: Divider(height: 1, color: AppColors.border),
              ),
          ],
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.data});
  final _MenuItemData data;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: data.iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(data.icon, size: 18, color: data.iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                data.label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Bottom Sheets
// ─────────────────────────────────────────────────────────

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.currentName, required this.ref});
  final String currentName;
  final WidgetRef ref;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Name cannot be empty.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await widget.ref.read(authProvider.notifier).updateProfile(name: name);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetWrapper(
      title: 'Edit Profile',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Display Name',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Enter your name',
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: _loading ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Change Password ──────────────────────────────────────

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet({required this.ref});
  final WidgetRef ref;

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _error;

  @override
  void dispose() {
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final pw = _newCtrl.text;
    final confirm = _confirmCtrl.text;
    if (pw.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    if (pw != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await widget.ref.read(authProvider.notifier).updatePassword(newPassword: pw);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetWrapper(
      title: 'Change Password',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _PwField(
            controller: _newCtrl,
            label: 'New Password',
            hint: 'At least 6 characters',
            obscure: _obscureNew,
            onToggle: () => setState(() => _obscureNew = !_obscureNew),
          ),
          const SizedBox(height: 14),
          _PwField(
            controller: _confirmCtrl,
            label: 'Confirm Password',
            hint: 'Re-enter new password',
            obscure: _obscureConfirm,
            onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: _loading ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Update Password', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PwField extends StatelessWidget {
  const _PwField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.obscure,
    required this.onToggle,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
              onPressed: onToggle,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Notifications ────────────────────────────────────────

class _NotificationsSheet extends StatefulWidget {
  const _NotificationsSheet();

  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  bool _push = true;
  bool _weekly = false;

  @override
  Widget build(BuildContext context) {
    return _BottomSheetWrapper(
      title: 'Notifications',
      child: Column(
        children: [
          _ToggleRow(
            icon: Icons.notifications_active_outlined,
            iconColor: const Color(0xFFF59E0B),
            label: 'Push Notifications',
            subtitle: 'Alerts for transactions and reminders',
            value: _push,
            onChanged: (v) => setState(() => _push = v),
          ),
          const Divider(height: 1, color: AppColors.border),
          _ToggleRow(
            icon: Icons.bar_chart_rounded,
            iconColor: AppColors.tertiary,
            label: 'Weekly Summary',
            subtitle: 'Spending report every Monday',
            value: _weekly,
            onChanged: (v) => setState(() => _weekly = v),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: AppColors.secondary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Full notification support coming soon.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.secondary,
          ),
        ],
      ),
    );
  }
}

// ── Help & Support ───────────────────────────────────────

class _HelpSheet extends StatelessWidget {
  const _HelpSheet();

  @override
  Widget build(BuildContext context) {
    return _BottomSheetWrapper(
      title: 'Help & Support',
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.email_outlined,
            iconColor: AppColors.tertiary,
            label: 'Email Support',
            value: 'support@spendly.app',
          ),
          const Divider(height: 1, color: AppColors.border),
          _InfoRow(
            icon: Icons.language_rounded,
            iconColor: AppColors.secondary,
            label: 'Website',
            value: 'www.spendly.app',
          ),
          const Divider(height: 1, color: AppColors.border),
          _InfoRow(
            icon: Icons.question_answer_outlined,
            iconColor: const Color(0xFFF59E0B),
            label: 'FAQ',
            value: 'View frequently asked questions',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Close',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── About ────────────────────────────────────────────────

class _AboutSheet extends StatelessWidget {
  const _AboutSheet();

  @override
  Widget build(BuildContext context) {
    return _BottomSheetWrapper(
      title: 'About Spendly',
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 14),
          const Text(
            'Spendly',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Version 1.0.0',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          const Text(
            'Spendly helps you track your income and expenses with ease. Stay on top of your finances with real-time insights and smart categorisation.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 20),
          _InfoRow(
            icon: Icons.code_rounded,
            iconColor: AppColors.primary,
            label: 'Built with',
            value: 'Flutter & Supabase',
          ),
          const Divider(height: 1, color: AppColors.border),
          _InfoRow(
            icon: Icons.shield_outlined,
            iconColor: AppColors.secondary,
            label: 'Privacy Policy',
            value: 'View policy',
          ),
        ],
      ),
    );
  }
}

// ── Shared helpers ───────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetWrapper extends StatelessWidget {
  const _BottomSheetWrapper({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}
