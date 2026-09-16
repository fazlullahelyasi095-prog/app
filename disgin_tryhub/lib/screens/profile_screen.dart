import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'Edit_profile.dart';
import 'followers_screen.dart';
import 'menu_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int followers = 12500;
  int following = 320;
  int likes = 45600;

  final ImagePicker _picker = ImagePicker();

  XFile? profileImage;

  // ============================================================
  // انتخاب عکس از گالری
  // ============================================================

  Future<void> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1000,
      maxHeight: 1000,
    );

    if (image == null) return;

    setState(() {
      profileImage = image;
    });
  }

  // ============================================================
  // گرفتن عکس از دوربین
  // ============================================================

  Future<void> takePhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1000,
      maxHeight: 1000,
    );

    if (image == null) return;

    setState(() {
      profileImage = image;
    });
  }

  // ============================================================
  // منوی عکس پروفایل
  // ============================================================

  void showProfilePhotoMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181818),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Profile Photo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(bottomContext);
                    pickImageFromGallery();
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Take Photo',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(bottomContext);
                    takePhoto();
                  },
                ),

                if (profileImage != null)
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Remove Photo',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(bottomContext);

                      setState(() {
                        profileImage = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // عکس پروفایل
  // ============================================================

  Widget buildProfileImage() {
    if (profileImage == null) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: const CircleAvatar(
          radius: 48,
          backgroundColor: Colors.white,
          child: Icon(Icons.person, size: 58, color: Colors.black),
        ),
      );
    }

    if (kIsWeb) {
      return ClipOval(
        child: Image.network(
          profileImage!.path,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    }

    return ClipOval(
      child: Image.file(
        File(profileImage!.path),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      ),
    );
  }

  // ============================================================
  // باز کردن Menu از راست به چپ
  // ============================================================

  void openMenu() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 1000),
        reverseTransitionDuration: const Duration(milliseconds: 1250),

        pageBuilder: (context, animation, secondaryAnimation) {
          return Align(
            alignment: Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.70,
              // اندازه صفحه Menu
              child: const MenuScreen(),
            ),
          );
        },

        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slideAnimation =
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );

          return SlideTransition(position: slideAnimation, child: child);
        },
      ),
    );
  }
  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,

        title: const Text(
          '@tryhub_user',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),

        actions: [
          IconButton(
            onPressed: openMenu,
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),

            // ====================================================
            // PROFILE PHOTO
            // ====================================================
            Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: showProfilePhotoMenu,
                  child: buildProfileImage(),
                ),

                Positioned(
                  right: -1,
                  bottom: 1,
                  child: GestureDetector(
                    onTap: showProfilePhotoMenu,
                    child: Container(
                      width: 31,
                      height: 31,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFE2C55),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 3),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 13),

            const Text(
              'TryHub User',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              '@tryhub_user',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),

            const SizedBox(height: 21),

            // ====================================================
            // STATS
            // ====================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                profileStat('Following', following, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FollowersScreen(title: 'Following'),
                    ),
                  );
                }),

                Container(width: 1, height: 36, color: Colors.grey.shade800),

                profileStat('Followers', followers, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FollowersScreen(title: 'Followers'),
                    ),
                  );
                }),

                Container(width: 1, height: 36, color: Colors.grey.shade800),

                profileStat('Likes', likes, () {}),
              ],
            ),

            const SizedBox(height: 21),

            // ====================================================
            // BUTTONS
            // ====================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 43,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfilePage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                SizedBox(
                  width: 47,
                  height: 43,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      side: BorderSide(color: Colors.grey.shade700),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () {},
                    child: const Icon(
                      Icons.person_4_outlined,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                SizedBox(
                  width: 47,
                  height: 43,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      side: BorderSide(color: Colors.grey.shade700),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () {},
                    child: const Icon(
                      Icons.share_outlined,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Welcome to my TryHub profile 🔥',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),

            const SizedBox(height: 21),

            const Divider(height: 1, color: Color(0xFF242424)),

            // ====================================================
            // TABS
            // ====================================================
            const SizedBox(
              height: 50,
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Icon(Icons.grid_on, color: Colors.white, size: 24),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Icon(
                        Icons.lock_outline,
                        color: Colors.grey,
                        size: 23,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Icon(
                        Icons.favorite_border,
                        color: Colors.grey,
                        size: 23,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: MediaQuery.of(context).size.width / 3,
                height: 2,
                color: Colors.white,
              ),
            ),

            // ====================================================
            // VIDEO GRID
            // ====================================================
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                return Container(
                  color: Colors.grey.shade900,
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white24,
                          size: 42,
                        ),
                      ),

                      Positioned(
                        left: 5,
                        bottom: 5,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 15,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${index + 1}.2K',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE STAT
  // ============================================================

  Widget profileStat(String title, int value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 100,
        child: Column(
          children: [
            Text(
              formatNumber(value),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }

    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }

    return number.toString();
  }
}
