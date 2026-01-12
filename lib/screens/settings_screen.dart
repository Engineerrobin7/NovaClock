import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nova_clock/screens/welcome_screen.dart';
import 'package:nova_clock/services/auth_service.dart';
import 'package:nova_clock/services/settings_service.dart';
import 'package:nova_clock/widgets/glass_container.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final settingsState = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Title
              Text(
                'Settings',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Profile Section
              GlassContainer(
                padding: const EdgeInsets.all(20),
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            color: Theme.of(context).primaryColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authState.user?.name ?? 'User',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                authState.user?.email ?? '',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await ref.read(authProvider.notifier).logout();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WelcomeScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Theme Section
              _buildSection(
                context,
                'Theme',
                Icons.palette_outlined,
                [
                  _buildSwitchTile(
                    context,
                    'Dark Mode',
                    settingsState.isDarkMode,
                    (value) => ref.read(settingsProvider.notifier).toggleDarkMode(),
                    Icons.dark_mode,
                  ),
                  const SizedBox(height: 12),
                  _buildTextTile(
                    context,
                    'Accent Color',
                    Icons.color_lens,
                    onTap: () => _showAccentColorPicker(context, ref),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Notifications Section
              _buildSection(
                context,
                'Notifications',
                Icons.notifications_outlined,
                [
                  _buildSwitchTile(
                    context,
                    'Enable Notifications',
                    settingsState.notificationsEnabled,
                    (value) => ref.read(settingsProvider.notifier).toggleNotifications(),
                    Icons.notifications,
                  ),
                  const SizedBox(height: 12),
                  _buildSwitchTile(
                    context,
                    'Alarm Notifications',
                    settingsState.alarmNotifications,
                    (value) => ref.read(settingsProvider.notifier).toggleAlarmNotifications(),
                    Icons.alarm,
                  ),
                  const SizedBox(height: 12),
                  _buildSwitchTile(
                    context,
                    'Timer Notifications',
                    settingsState.timerNotifications,
                    (value) => ref.read(settingsProvider.notifier).toggleTimerNotifications(),
                    Icons.timer,
                  ),
                  const SizedBox(height: 12),
                  _buildSwitchTile(
                    context,
                    'Focus Notifications',
                    settingsState.focusNotifications,
                    (value) => ref.read(settingsProvider.notifier).toggleFocusNotifications(),
                    Icons.rocket_launch,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Sound Section
              _buildSection(
                context,
                'Sound',
                Icons.volume_up_outlined,
                [
                  _buildTextTile(
                    context,
                    'Alarm Sound',
                    Icons.music_note,
                    trailing: Text(
                      settingsState.alarmSound,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => _showSoundPicker(
                      context,
                      ref,
                      'Alarm Sound',
                      settingsState.alarmSound,
                      (sound) => ref.read(settingsProvider.notifier).setAlarmSound(sound),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTextTile(
                    context,
                    'Notification Sound',
                    Icons.music_note,
                    trailing: Text(
                      settingsState.notificationSound,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => _showSoundPicker(
                      context,
                      ref,
                      'Notification Sound',
                      settingsState.notificationSound,
                      (sound) => ref.read(settingsProvider.notifier).setNotificationSound(sound),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // About Section
              _buildSection(
                context,
                'About',
                Icons.info_outline,
                [
                  _buildTextTile(
                    context,
                    'App Version',
                    Icons.apps,
                    trailing: const Text(
                      '1.0.0',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTextTile(
                    context,
                    'Privacy Policy',
                    Icons.privacy_tip_outlined,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Privacy Policy - Coming Soon')),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextTile(
                    context,
                    'Terms & Conditions',
                    Icons.description_outlined,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Terms & Conditions - Coming Soon')),
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor.withOpacity(0.7),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  Widget _buildTextTile(
    BuildContext context,
    String title,
    IconData icon, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).primaryColor.withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
            if (trailing != null) trailing,
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: Colors.white.withOpacity(0.5),
              ),
          ],
        ),
      ),
    );
  }

  void _showAccentColorPicker(BuildContext context, WidgetRef ref) {
    final colors = [
      const Color(0xFF7F5AF0), // Purple
      const Color(0xFF2CB67D), // Green
      const Color(0xFFFF6B6B), // Red
      const Color(0xFF4ECDC4), // Cyan
      const Color(0xFFFFBE0B), // Yellow
      const Color(0xFFFF006E), // Pink
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF242629),
        title: const Text(
          'Choose Accent Color',
          style: TextStyle(color: Colors.white),
        ),
        content: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: List.generate(colors.length, (index) {
            return GestureDetector(
              onTap: () {
                ref.read(settingsProvider.notifier).setAccentColor(index);
                Navigator.pop(context);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: colors[index],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  void _showSoundPicker(
    BuildContext context,
    WidgetRef ref,
    String title,
    String currentSound,
    Function(String) onSelect,
  ) {
    final sounds = ['default', 'gentle', 'classic', 'digital', 'nature'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF242629),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: sounds.map((sound) {
            final isSelected = sound == currentSound;
            return ListTile(
              title: Text(
                sound.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                  : null,
              onTap: () {
                onSelect(sound);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
