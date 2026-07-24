import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dreamers_movies_app_bv/domain/repositories/user_repositories.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/profile/profile_list_item.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';

import 'package:dreamers_movies_app_bv/presentation/widgets/shared/app_refresh_indicator.dart';

class ProfilePickerScreen extends StatefulWidget {
  static const name = 'profile-picker-screen';

  const ProfilePickerScreen({super.key});

  @override
  State<ProfilePickerScreen> createState() => _ProfilePickerScreenState();
}

class _ProfilePickerScreenState extends State<ProfilePickerScreen> {
  final UserRepository _userRepository = UserRepository();
  List<Map<String, dynamic>> _profiles = [];
  int? _activeProfileId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId == null) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      return;
    }

    final profiles = await _userRepository.getProfilesForCurrentUser();
    final activeProfileId = prefs.getInt('active_profile_id');

    if (!mounted) return;
    setState(() {
      _profiles = profiles;
      _activeProfileId = activeProfileId;
      _isLoading = false;
    });
  }

  Future<void> _addProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId == null) return;

    final controller = TextEditingController();
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.secondaryColor,
          title: const Text('Crear perfil', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Nombre del perfil',
              hintStyle: TextStyle(color: Colors.white54),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Crear', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    final name = controller.text.trim();
    if (name.isEmpty) return;

    final newProfileId = await _userRepository.createProfile(userId, name);
    if (newProfileId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo crear el perfil')),
      );
      return;
    }

    await _loadProfiles();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Perfil "$name" creado')),
    );
  }

  Future<void> _selectProfile(int profileId) async {
    final success = await _userRepository.selectProfile(profileId);
    if (!success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo activar el perfil')),
      );
      return;
    }

    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    if (!mounted) return;
    setState(() => _activeProfileId = profileId);

    if (context.canPop()) {
      context.pop(true);
    } else {
      context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Quién está viendo?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: AppRefreshIndicator(
        onRefresh: _loadProfiles,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: _profiles.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          if (index == _profiles.length) {
                            return InkWell(
                              onTap: _addProfile,
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: const Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Colors.white12,
                                      child: Icon(Icons.add, color: Colors.white),
                                    ),
                                    SizedBox(width: 14),
                                    Text(
                                      'Agregar perfil',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final profile = _profiles[index];
                          final profileId = profile['id_perfil'] as int;
                          final profileName = profile['nombre_perfil']?.toString() ?? 'Perfil';
                          final avatarUrl = profile['avatar_url'];

                          return ProfileListItem(
                            title: profileName,
                            subtitle: _activeProfileId == profileId ? 'Seleccionado' : 'Abrir perfil',
                            isSelected: _activeProfileId == profileId,
                            avatarUrl: avatarUrl?.toString(),
                            onTap: () => _selectProfile(profileId),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
