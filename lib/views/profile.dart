import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:api_practice/Provider/user.dart';
import 'package:api_practice/services/auth.dart';
import 'package:api_practice/utils/app_theme.dart';
import 'package:api_practice/views/login.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool isUpdating = false;

  Future<void> _editName(BuildContext context, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.getToken();

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Full name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty || token == null) return;

    setState(() => isUpdating = true);
    try {
      await AuthServices().UpdateProfile(token: token, name: newName);
      final refreshed = await AuthServices().getProfile(token);
      userProvider.setUser(refreshed);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name updated')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => isUpdating = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log out?'),
        content: const Text('You will need to log in again to see your tasks.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!context.mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.getToken();

    // Best-effort call to invalidate the session server-side; local
    // session is cleared regardless of whether this succeeds.
    if (token != null) {
      await AuthServices().logoutUser(token);
    }

    await userProvider.logout();

    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.getUser().user;
    final name = user?.name ?? '';
    final email = user?.email ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              name.isNotEmpty ? name : 'No name set',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              email,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
                  title: const Text('Edit name'),
                  trailing: isUpdating
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  onTap: isUpdating ? null : () => _editName(context, name),
                ),
                const Divider(height: 1, color: AppColors.border),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.danger),
                  title: const Text(
                    'Log out',
                    style: TextStyle(color: AppColors.danger),
                  ),
                  onTap: () => _logout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
