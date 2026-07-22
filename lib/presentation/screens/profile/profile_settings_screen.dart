import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dreamers_movies_app_bv/domain/entities/user_entities.dart';
import 'package:dreamers_movies_app_bv/domain/repositories/user_repositories.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final UserEntity? currentUser;
  final ValueChanged<UserEntity>? onUserUpdated;

  const ProfileSettingsScreen({
    super.key,
    this.currentUser,
    this.onUserUpdated,
  });

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late String _userName;
  late String _userAlias;
  late String _userEmail;
  late String _userPhone;

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final UserRepository _userRepository = UserRepository();

  @override
  void initState() {
    super.initState();
    _userName = widget.currentUser?.nombres ?? 'Usuario';
    _userAlias =
        widget.currentUser?.alias ?? widget.currentUser?.nombres ?? 'Usuario';
    _userEmail = widget.currentUser?.email ?? 'Sin correo';
    _userPhone = widget.currentUser?.telefono ?? 'Sin número';
    _loadPersistedAvatar();
  }

  Future<void> _loadPersistedAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAvatar =
        prefs.getString('active_profile_avatar') ??
        prefs.getString('user_avatar') ??
        '';
    if (savedAvatar.isEmpty) return;

    final file = File(savedAvatar);
    if (!await file.exists()) return;

    if (!mounted) return;
    setState(() {
      _profileImage = file;
    });
  }

  ImageProvider<Object>? _buildAvatarProvider() {
    if (_profileImage != null) return FileImage(_profileImage!);

    final savedAvatar = widget.currentUser?.avatarUrl ?? '';
    if (savedAvatar.startsWith('http')) return NetworkImage(savedAvatar);
    if (savedAvatar.isNotEmpty) {
      final file = File(savedAvatar);
      if (file.existsSync()) return FileImage(file);
    }

    return const NetworkImage('https://i.pravatar.cc/300');
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;

    final archivo = File(pickedFile.path);
    final bytes = await archivo.length();
    final megas = bytes / (1024 * 1024);

    if (megas < 0.01 || megas > 5.0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ La imagen debe pesar entre 10 KB y 5 MB.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _profileImage = archivo;
    });

    if (widget.currentUser == null) return;

    final exito = await _userRepository.updateAvatar(
      widget.currentUser!.id,
      archivo.path,
    );

    if (!mounted) return;

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Foto de perfil actualizada')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ No se pudo actualizar la foto de perfil'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _verificarHuellaYCambiarPassword() async {
    if (!mounted) return;
    _showChangePasswordSheet(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Configuración',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 65,
                          backgroundImage: _buildAvatarProvider(),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 5,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.secondaryColor,
                              width: 3,
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(8),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '@$_userAlias',
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _userEmail,
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  _buildSettingsItem(
                    icon: Icons.person_outline,
                    title: 'Datos personales',
                    subtitle: 'Nombre, Correo, Teléfono',
                    onTap: () => _showEditProfileSheet(context),
                  ),
                  const Divider(color: Colors.white12, height: 1, indent: 65),
                  _buildSettingsItem(
                    icon: Icons.lock_outline,
                    title: 'Seguridad',
                    subtitle: 'Cambiar contraseña (requiere huella)',
                    onTap: _verificarHuellaYCambiarPassword,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context) {
    final aliasController = TextEditingController(text: _userAlias);
    final fullNameController = TextEditingController(text: _userName);
    final emailController = TextEditingController(text: _userEmail);
    final phoneController = TextEditingController(text: _userPhone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.secondaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Editar Datos Personales',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: aliasController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  'Nombre de usuario',
                  Icons.alternate_email,
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: fullNameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Nombre completo', Icons.person),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: emailController,
                enabled: false,
                style: const TextStyle(color: Colors.white70),
                decoration: _inputDecoration('Correo electrónico', Icons.email),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: phoneController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration('Número de teléfono', Icons.phone),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () async {
                    if (widget.currentUser == null) return;

                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);

                    final exito = await _userRepository.updateProfileInfo(
                      userId: widget.currentUser!.id,
                      nombres: fullNameController.text.trim(),
                      apellidos: '',
                      alias: aliasController.text.trim(),
                      telefono: phoneController.text.trim(),
                    );

                    if (!mounted) return;

                    if (exito) {
                      final updatedUser = widget.currentUser!.copyWith(
                        nombres: fullNameController.text.trim(),
                        apellidos: '',
                        telefono: phoneController.text.trim(),
                        alias: aliasController.text.trim(),
                      );

                      setState(() {
                        _userName = fullNameController.text.trim();
                        _userAlias = aliasController.text.trim();
                        _userPhone = phoneController.text.trim();
                      });

                      widget.onUserUpdated?.call(updatedUser);
                      navigator.pop();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('✅ Datos actualizados correctamente'),
                        ),
                      );
                    } else {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('❌ Error al actualizar los datos'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Guardar cambios',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    String newPassword = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.secondaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final hasMinLength = newPassword.length >= 8;
            final hasUppercase = newPassword.contains(RegExp(r'[A-Z]'));
            final hasNumber = newPassword.contains(RegExp(r'[0-9]'));
            final hasSpecial = newPassword.contains(
              RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
            );
            final canSubmit =
                hasMinLength && hasUppercase && hasNumber && hasSpecial;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Cambiar Contraseña',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextFormField(
                    controller: currentController,
                    obscureText: obscureCurrent,
                    style: const TextStyle(color: Colors.white),
                    decoration:
                        _inputDecoration(
                          'Contraseña actual',
                          Icons.lock,
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureCurrent
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white54,
                            ),
                            onPressed: () => setModalState(
                              () => obscureCurrent = !obscureCurrent,
                            ),
                          ),
                        ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: newController,
                    obscureText: obscureNew,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) =>
                        setModalState(() => newPassword = value),
                    decoration:
                        _inputDecoration(
                          'Nueva contraseña',
                          Icons.lock_outline,
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNew
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white54,
                            ),
                            onPressed: () =>
                                setModalState(() => obscureNew = !obscureNew),
                          ),
                        ),
                  ),
                  const SizedBox(height: 15),
                  _buildValidationRow('Mínimo 8 caracteres', hasMinLength),
                  _buildValidationRow('Una letra mayúscula', hasUppercase),
                  _buildValidationRow('Un número', hasNumber),
                  _buildValidationRow(
                    'Un carácter especial (!@#\$&*)',
                    hasSpecial,
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canSubmit
                            ? Colors.blueAccent
                            : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: canSubmit
                          ? () async {
                              if (widget.currentUser == null) return;

                              final navigator = Navigator.of(context);
                              final messenger = ScaffoldMessenger.of(context);

                              final actualizado = await _userRepository
                                  .updateUserPassword(
                                    userId: widget.currentUser!.id,
                                    currentPassword: currentController.text
                                        .trim(),
                                    newPassword: newController.text.trim(),
                                  );

                              if (!mounted) return;
                              navigator.pop();

                              if (actualizado) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      '✅ Contraseña actualizada con éxito',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      '❌ La contraseña actual es incorrecta',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          : null,
                      child: const Text(
                        'Actualizar contraseña',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildValidationRow(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isValid ? Colors.greenAccent : Colors.white38,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isValid ? Colors.white : Colors.white38,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white54, fontSize: 13),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white38,
        size: 16,
      ),
      onTap: onTap,
    );
  }
}