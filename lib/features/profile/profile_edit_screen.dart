// lib/features/profile/profile_edit_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // для kIsWeb
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();

  final Color _primaryPurple = const Color(0xFF8B5CF6);

  bool _isLoading = false;
  String? _avatarUrl;
  File? _imageFile;
  Uint8List? _webImageBytes; // Для хранения байтов изображения на Web

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final user = Supabase.instance.client.auth.currentUser;

    setState(() {
      _nameController.text = prefs.getString('userName') ?? '';
      _bioController.text = prefs.getString('userBio') ?? '';
      _phoneController.text = prefs.getString('userPhone') ?? '';
      _avatarUrl = prefs.getString('avatarUrl');
    });

    // Загружаем данные профиля из Supabase
    if (user != null) {
      try {
        final response = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (response != null) {
          setState(() {
            _nameController.text = response['full_name'] ?? '';
            _bioController.text = response['bio'] ?? '';
            _phoneController.text = response['phone'] ?? '';
            _avatarUrl = response['avatar_url'];
          });
        }
      } catch (e) {
        debugPrint('Error loading profile: $e');
        // Если таблицы нет, создаем начальный профиль
        _createInitialProfile(user);
      }
    }
  }

  Future<void> _createInitialProfile(User user) async {
    try {
      await Supabase.instance.client.from('profiles').upsert({
        'id': user.id,
        'full_name': _nameController.text.isNotEmpty
            ? _nameController.text
            : 'New User',
        'bio': _bioController.text,
        'phone': _phoneController.text,
        'avatar_url': _avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error creating initial profile: $e');
    }
  }

  Future<void> _uploadAvatar() async {
    if (_imageFile == null && _webImageBytes == null) return;

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Пользователь не авторизован');

      Uint8List bytes; // Измените тип на Uint8List
      String fileExt;

      if (kIsWeb && _webImageBytes != null) {
        bytes = _webImageBytes!;
        fileExt = 'jpg';
      } else if (!kIsWeb && _imageFile != null) {
        // Читаем байты из файла
        bytes = await _imageFile!.readAsBytes();
        fileExt = _imageFile!.path.split('.').last.toLowerCase();
      } else {
        throw Exception('Нет данных изображения');
      }

      // Определяем MIME-тип
      String mimeType = 'image/jpeg';
      if (fileExt == 'png') {
        mimeType = 'image/png';
      } else if (fileExt == 'gif') {
        mimeType = 'image/gif';
      } else if (fileExt == 'webp') {
        mimeType = 'image/webp';
      }

      final fileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = fileName;

      // Загружаем в Supabase Storage
      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(
            // Используйте uploadBinary для байтов
            filePath,
            bytes,
            fileOptions: FileOptions(contentType: mimeType, upsert: true),
          );

      // Получаем публичный URL
      final imageUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(filePath);

      setState(() {
        _avatarUrl = imageUrl;
        _imageFile = null;
        _webImageBytes = null;
      });

      // Сохраняем URL в SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatarUrl', imageUrl);

      _showSnackBar('Аватар успешно загружен!');
    } catch (e) {
      debugPrint('Upload error details: $e');
      _showSnackBar('Ошибка загрузки: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty) {
      _showSnackBar('Пожалуйста, введите имя', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Пользователь не авторизован');

      // Сначала сохраняем профиль без аватара
      final Map<String, dynamic> profileData = {
        'id': user.id,
        'full_name': _nameController.text,
        'bio': _bioController.text,
        'phone': _phoneController.text,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Если есть новое изображение, загружаем его
      if (_imageFile != null || _webImageBytes != null) {
        await _uploadAvatar();
        // После загрузки добавляем URL аватара к данным
        if (_avatarUrl != null) {
          profileData['avatar_url'] = _avatarUrl;
        }
      } else if (_avatarUrl != null) {
        // Если аватар уже был загружен, используем существующий URL
        profileData['avatar_url'] = _avatarUrl;
      }

      // Сохраняем в SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text);
      await prefs.setString('userBio', _bioController.text);
      await prefs.setString('userPhone', _phoneController.text);
      if (_avatarUrl != null) {
        await prefs.setString('avatarUrl', _avatarUrl!);
      }

      // Сохраняем в Supabase
      await Supabase.instance.client.from('profiles').upsert(profileData);

      if (!mounted) return;
      _showSnackBar('Профиль успешно сохранен!');

      // Возвращаемся назад с результатом
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Save profile error: $e');
      _showSnackBar('Ошибка сохранения: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Выберите источник',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryPurple.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.camera_alt, color: _primaryPurple),
              ),
              title: const Text('Камера'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryPurple.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.photo_library, color: _primaryPurple),
              ),
              title: const Text('Галерея'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_avatarUrl != null ||
                _imageFile != null ||
                _webImageBytes != null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                title: const Text('Удалить фото'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _imageFile = null;
                    _webImageBytes = null;
                    _avatarUrl = null;
                  });
                },
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarWidget() {
    if (kIsWeb && _webImageBytes != null) {
      // Для Web с новым изображением
      return Image.memory(_webImageBytes!, fit: BoxFit.cover);
    } else if (!kIsWeb && _imageFile != null) {
      // Для мобильных платформ с новым изображением
      return Image.file(_imageFile!, fit: BoxFit.cover);
    } else if (_avatarUrl != null) {
      // Для загруженного изображения с сервера
      return Image.network(
        _avatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    } else {
      // Дефолтный аватар
      return _buildDefaultAvatar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // Градиентный фон
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_primaryPurple, const Color(0xFF7C3AED)],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Avatar Section
                        Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: .1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipOval(child: _buildAvatarWidget()),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _showImageSourceDialog,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _primaryPurple,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _primaryPurple.withValues(
                                          alpha: .4,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // Form Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name Field
                              _buildLabel('Full Name'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _nameController,
                                hint: 'Enter your name',
                                icon: Icons.person_outline,
                              ),

                              const SizedBox(height: 20),

                              // Bio Field
                              _buildLabel('Bio'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _bioController,
                                hint: 'Tell us about yourself',
                                icon: Icons.edit_note,
                                maxLines: 3,
                              ),

                              const SizedBox(height: 20),

                              // Phone Field
                              _buildLabel('Phone Number'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _phoneController,
                                hint: '+7 (___) ___-__-__',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                              ),

                              const SizedBox(height: 20),

                              // Email (read-only)
                              _buildLabel('Email'),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.email_outlined,
                                      color: Colors.grey[400],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        Supabase
                                                .instance
                                                .client
                                                .auth
                                                .currentUser
                                                ?.email ??
                                            'Not logged in',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.lock_outline,
                                      color: Colors.grey[400],
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        'Save Changes',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: const Color(0xFFE0D4FC),
      child: Icon(Icons.person, size: 60, color: _primaryPurple),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryPurple, width: 2),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          // Для Web читаем байты
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
            _imageFile = File(pickedFile.path);
          });
        } else {
          // Для мобильных платформ
          setState(() {
            _imageFile = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      _showSnackBar('Ошибка при выборе изображения: $e', isError: true);
    }
  }
}
