
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A5490),
        elevation: 0,
      ),
      body: GetX<ProfileController>(
        init: ProfileController(),
        builder: (profileController) {
          if (profileController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (profileController.errorMessage.value.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 44,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profileController.errorMessage.value,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: profileController.loadProfile,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final user = profileController.profile.value ?? {};

          if (user.isEmpty) {
            return const Center(
              child: Text('No profile information available.'),
            );
          }

          String displayValue(String key) {
            final value = user[key];
            if (value == null || value.toString().trim().isEmpty) {
              return 'Not provided';
            }
            return value.toString();
          }

          final name = displayValue('name');

          return RefreshIndicator(
            onRefresh: profileController.loadProfile,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: const Color(0xFFE5F3FA),
                        child: Text(
                          name == 'Not provided' || name.isEmpty
                              ? '?'
                              : name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A5490),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A5490),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        displayValue('email'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _infoCard('Name', name),
                _infoCard('Email', displayValue('email')),
                _infoCard('Phone', displayValue('phone')),
                _infoCard('Department', displayValue('department')),
                _infoCard('Designation', displayValue('designation')),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A5490),
            ),
          ),
        ),
      ),
    );
  }
}
