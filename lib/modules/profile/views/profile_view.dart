
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  static const Color darkBlue = Color(0xFF1A5490);
  static const Color mediumBlue = Color(0xFF178FB4);
  static const Color cyan = Color(0xFF2BB6C6);
  static const Color purple = Color(0xFF7652E8);
  static const Color background = Color(0xFFF5F8FC);
  static const Color textColor = Color(0xFF18324D);
  static const Color mutedColor = Color(0xFF718096);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: textColor),
        actions: [
          IconButton(
            tooltip: 'Refresh profile',
            onPressed: controller.loadProfile,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.profile.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: mediumBlue),
          );
        }

        return RefreshIndicator(
          color: mediumBlue,
          onRefresh: controller.loadProfile,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
            children: [
              _profileHeader(controller),
              const SizedBox(height: 20),

              if (controller.errorMessage.value.isNotEmpty)
                _messageCard(
                  controller.errorMessage.value,
                  isError: true,
                ),

              if (controller.successMessage.value.isNotEmpty)
                _messageCard(
                  controller.successMessage.value,
                  isError: false,
                ),

              _sectionTitle('Personal information'),
              const SizedBox(height: 12),

              _infoCard([
                _infoRow(
                  Icons.person_outline_rounded,
                  'Full name',
                  controller.displayName,
                ),
                _infoRow(
                  Icons.email_outlined,
                  'Email address',
                  controller.email,
                ),
                _infoRow(
                  Icons.phone_outlined,
                  'Phone number',
                  controller.phone,
                ),
                _infoRow(
                  Icons.work_outline_rounded,
                  'Designation',
                  controller.designation,
                ),
                _infoRow(
                  Icons.business_outlined,
                  'Department',
                  controller.department,
                ),
              ]),

              const SizedBox(height: 22),

              _sectionTitle('Profile photo'),
              const SizedBox(height: 6),
              const Text(
                'Choose a clear photo from your device gallery. '
                    'JPG, PNG or WEBP, up to 2 MB.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: mutedColor,
                ),
              ),
              const SizedBox(height: 14),

              OutlinedButton.icon(
                onPressed: controller.isUploading.value
                    ? null
                    : controller.chooseAvatar,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Choose from Gallery'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: darkBlue,
                  side: const BorderSide(color: mediumBlue),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              if (controller.selectedImage.value != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE4EBF3)),
                  ),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Selected photo preview',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      CircleAvatar(
                        radius: 58,
                        backgroundColor: const Color(0xFFEAF5FA),
                        backgroundImage: FileImage(
                          controller.selectedImage.value!,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isUploading.value
                              ? null
                              : controller.uploadAvatar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: controller.isUploading.value
                              ? const SizedBox(
                            height: 21,
                            width: 21,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Text(
                            'Upload Profile Photo',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _profileHeader(ProfileController controller) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [darkBlue, mediumBlue, cyan],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withValues(alpha: 0.16),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              _avatar(controller, 43),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 17,
                  color: darkBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            controller.displayName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            controller.email.isEmpty
                ? 'Email not available'
                : controller.email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
            ),
          ),
          if (controller.designation.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                controller.designation,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _avatar(ProfileController controller, double radius) {
    final localImage = controller.selectedImage.value;
    final url = controller.avatarUrl;

    if (localImage != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(localImage),
      );
    }

    if (url.startsWith('https://') || url.startsWith('http://')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white,
        child: ClipOval(
          child: Image.network(
            url,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initials(controller),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      child: _initials(controller),
    );
  }

  Widget _initials(ProfileController controller) {
    final name = controller.displayName.trim();
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();

    return Text(
      initial,
      style: const TextStyle(
        color: darkBlue,
        fontWeight: FontWeight.w800,
        fontSize: 30,
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: textColor,
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _infoCard(List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7EDF5)),
      ),
      child: Column(children: rows),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    final hasValue = value.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5FA),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: mediumBlue, size: 21),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: mutedColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  hasValue ? value : 'Not provided by API',
                  style: TextStyle(
                    color: hasValue ? textColor : mutedColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageCard(String message, {required bool isError}) {
    final color = isError
        ? const Color(0xFFB42318)
        : const Color(0xFF16805D);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: color,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
