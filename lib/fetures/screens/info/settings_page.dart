import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mafia_store/core/app_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _darkMode = appDarkMode.value;
  }

  Widget _tile({
    required IconData icon,
    required String title,
    String? trailingText,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        child: Icon(icon, size: 20),
      ),
      title: Text(title),
      trailing: trailing ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailingText != null)
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Text(trailingText,
                      style: const TextStyle(color: Colors.grey)),
                ),
              const Icon(Icons.chevron_right),
            ],
          ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _tile(
                  icon: Icons.edit,
                  title: 'Edit Profile',
                  onTap: () {},
                ),
                const Divider(height: 0),
                _tile(
                  icon: Icons.notifications_active,
                  title: 'Notifications',
                  onTap: () {},
                ),
                const Divider(height: 0),
                _tile(
                  icon: Icons.language,
                  title: 'Language',
                  trailingText: 'EN',
                  onTap: () {},
                ),
                const Divider(height: 0),
                _tile(
                  icon: Icons.dark_mode,
                  title: 'Dark Mode',
                  trailing: Switch(
                    value: _darkMode,
                    onChanged: (v) {
                      setState(() => _darkMode = v);
                      appDarkMode.value = v;
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _tile(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () async {
                    try {
                      await FirebaseAuth.instance.signOut();
                    } finally {
                      if (mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/login', (_) => false);
                      }
                    }
                  },
                ),
                const Divider(height: 0),
                _tile(
                  icon: Icons.delete_forever,
                  title: 'Delete Account',
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Account'),
                        content: const Text(
                            'Are you sure you want to delete your account?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete')),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      try {
                        await FirebaseAuth.instance.currentUser?.delete();
                        if (mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/login', (_) => false);
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed to delete account: $e')),
                          );
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _tile(
                  icon: Icons.info_outline,
                  title: 'About App',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Mafia Store',
                      applicationVersion: '1.0.0',
                      applicationIcon: const FlutterLogo(),
                      children: const [
                        Text('A simple store app for demo purposes.'),
                      ],
                    );
                  },
                ),
                const Divider(height: 0),
                _tile(
                  icon: Icons.phone_in_talk,
                  title: 'Contact Us',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Contact Us'),
                        content: const Text(
                            'Email: support@mafiastore.app\nPhone: +20 100 000 0000'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('OK')),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
