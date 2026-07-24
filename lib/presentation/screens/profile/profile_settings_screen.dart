import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
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
    // Extraemos únicamente los 10 dígitos locales si el teléfono ya tenía +52 o prefijos
    String initialPhoneDigits = _userPhone.replaceAll('+52', '').replaceAll(RegExp(r'\D'), '');
    if (initialPhoneDigits.length > 10) {
      initialPhoneDigits = initialPhoneDigits.substring(initialPhoneDigits.length - 10);
    }
    final phoneController = TextEditingController(text: initialPhoneDigits);
    final editFormKey = GlobalKey<FormState>();

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
          child: SingleChildScrollView(
            child: Form(
              key: editFormKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
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
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                    decoration: _inputDecoration(
                      'Nombre de usuario',
                      Icons.alternate_email,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre de usuario es requerido';
                      }
                      if (value.contains(' ')) {
                        return 'El usuario no debe llevar espacios (ej. adrian_67)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: fullNameController,
                    style: const TextStyle(color: Colors.white),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r"[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]"),
                      ),
                    ],
                    decoration: _inputDecoration('Nombre completo', Icons.person),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre completo es requerido';
                      }
                      final trimmed = value.trim();
                      if (trimmed.length < 3) {
                        return 'El nombre debe tener al menos 3 caracteres';
                      }
                      if (RegExp(r'[0-9]').hasMatch(value)) {
                        return 'El nombre no puede contener números';
                      }
                      if (!RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$").hasMatch(trimmed)) {
                        return 'El nombre solo debe contener letras y espacios';
                      }
                      return null;
                    },
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
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: _inputDecoration('Número de teléfono', Icons.phone).copyWith(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.phone, color: Colors.white54, size: 20),
                            const SizedBox(width: 8),
                            const Text('🇲🇽', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 4),
                            const Text(
                              '+52',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(width: 1, height: 18, color: Colors.white24),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Requerido';
                      final clean = value.replaceAll(RegExp(r'\D'), '');
                      if (clean.length != 10) {
                        return 'Debe tener exactamente 10 dígitos';
                      }
                      return null;
                    },
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
                        if (!editFormKey.currentState!.validate()) return;
                        if (widget.currentUser == null) return;
                        
                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        
                        final phoneDigits = phoneController.text.trim();
                        final phoneToSave = phoneDigits.isNotEmpty ? '+52 $phoneDigits' : '';

                        final exito = await _userRepository.updateProfileInfo(
                          userId: widget.currentUser!.id,
                          nombres: fullNameController.text.trim(),
                          apellidos: '',
                          alias: aliasController.text.trim(),
                          telefono: phoneToSave,
                        );
                        
                        if (!mounted) return;
                        
                        if (exito) {
                          final updatedUser = widget.currentUser!.copyWith(
                            nombres: fullNameController.text.trim(),
                            apellidos: '',
                            telefono: phoneToSave,
                            alias: aliasController.text.trim(),
                          );
                          setState(() {
                            _userName = fullNameController.text.trim();
                            _userAlias = aliasController.text.trim();
                            _userPhone = phoneToSave;
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
            ),
          ),
        );
      },
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final passFormKey = GlobalKey<FormState>();
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
            final isDifferentFromCurrent = newPassword != currentController.text.trim();
            final canSubmit =
                currentController.text.trim().isNotEmpty &&
                hasMinLength &&
                hasUppercase &&
                hasNumber &&
                hasSpecial &&
                isDifferentFromCurrent;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: passFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        onChanged: (_) => setModalState(() {}),
                        decoration: _inputDecoration(
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
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Debes ingresar tu contraseña actual';
                          }
                          if (value.trim().length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: newController,
                        obscureText: obscureNew,
                        style: const TextStyle(color: Colors.white),
                        onChanged: (value) =>
                            setModalState(() => newPassword = value),
                        decoration: _inputDecoration(
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
                            onPressed: () => setModalState(
                                () => obscureNew = !obscureNew),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Debes ingresar la nueva contraseña';
                          }
                          if (value.length < 8) {
                            return 'La contraseña debe tener al menos 8 caracteres';
                          }
                          if (!value.contains(RegExp(r'[A-Z]'))) {
                            return 'Debe contener al menos una letra mayúscula';
                          }
                          if (!value.contains(RegExp(r'[0-9]'))) {
                            return 'Debe contener al menos un número';
                          }
                          if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                            return 'Debe contener al menos un carácter especial (!@#\$&*)';
                          }
                          if (value == currentController.text.trim()) {
                            return 'La nueva contraseña debe ser diferente a la actual';
                          }
                          return null;
                        },
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
                                  if (!passFormKey.currentState!.validate()) {
                                    return;
                                  }
                                  if (widget.currentUser == null) return;

                                  final navigator = Navigator.of(context);
                                  final messenger =
                                      ScaffoldMessenger.of(context);

                                  final actualizado = await _userRepository
                                      .updateUserPassword(
                                    userId: widget.currentUser!.id,
                                    currentPassword:
                                        currentController.text.trim(),
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
                ),
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
      errorStyle: const TextStyle(color: Colors.redAccent),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent),
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