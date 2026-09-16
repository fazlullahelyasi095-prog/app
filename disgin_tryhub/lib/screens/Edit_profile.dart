import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController(
    text: 'Fazlullah',
  );

  final TextEditingController usernameController = TextEditingController(
    text: 'fazlullah',
  );

  final TextEditingController bioController = TextEditingController(
    text: 'Welcome to my TryHub profile',
  );

  final TextEditingController websiteController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 22,
          ),
        ),

        title: const Text(
          'Edit profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),

        centerTitle: true,

        actions: [
          TextButton(
            onPressed: () {
              saveProfile();
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xFFFF2C55),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            const SizedBox(height: 25),

            // PROFILE PHOTO
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 105,
                    height: 105,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 2),
                    ),
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFF262626),
                      child: Icon(
                        Icons.person,
                        color: Colors.white54,
                        size: 55,
                      ),
                    ),
                  ),

                  Positioned(
                    right: 0,
                    bottom: 3,
                    child: GestureDetector(
                      onTap: changeProfilePhoto,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF2C55),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF0F0F0F),
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            GestureDetector(
              onTap: changeProfilePhoto,
              child: const Text(
                'Change photo',
                style: TextStyle(
                  color: Color(0xFFFF2C55),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 30),

            profileSection(
              title: 'Profile information',
              children: [
                profileField(
                  title: 'Name',
                  controller: nameController,
                  icon: Icons.person_outline,
                ),

                profileField(
                  title: 'Username',
                  controller: usernameController,
                  icon: Icons.alternate_email,
                  prefixText: '@',
                ),

                profileField(
                  title: 'Bio',
                  controller: bioController,
                  icon: Icons.notes_rounded,
                  maxLines: 3,
                  maxLength: 80,
                ),
              ],
            ),

            const SizedBox(height: 18),

            profileSection(
              title: 'Social',
              children: [
                profileField(
                  title: 'Website',
                  controller: websiteController,
                  icon: Icons.link_rounded,
                  hintText: 'Add website',
                ),

                actionRow(
                  icon: Icons.camera_alt_outlined,
                  title: 'Instagram',
                  subtitle: 'Add Instagram',
                  onTap: () {},
                ),

                actionRow(
                  icon: Icons.play_circle_outline,
                  title: 'YouTube',
                  subtitle: 'Add YouTube',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 18),

            profileSection(
              title: 'Account',
              children: [
                actionRow(
                  icon: Icons.lock_outline,
                  title: 'Privacy',
                  subtitle: 'Manage profile privacy',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2C55),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Save changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget profileSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 9),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF191919),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget profileField({
    required String title,
    required TextEditingController controller,
    required IconData icon,
    String? hintText,
    String? prefixText,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          counterText: '',
          prefixIcon: Icon(icon, color: Colors.white54, size: 21),
          prefixText: prefixText,
          prefixStyle: const TextStyle(color: Colors.white70, fontSize: 15),
          labelText: title,
          labelStyle: const TextStyle(color: Colors.white54),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white30),
          filled: true,
          fillColor: const Color(0xFF202020),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFF2C55), width: 1.3),
          ),
        ),
      ),
    );
  }

  Widget actionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white70, size: 21),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white24,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void changeProfilePhoto() {
    // بعداً image_picker را اینجا وصل می‌کنیم
  }

  void saveProfile() {
    debugPrint('Name: ${nameController.text}');
    debugPrint('Username: ${usernameController.text}');
    debugPrint('Bio: ${bioController.text}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }
}
