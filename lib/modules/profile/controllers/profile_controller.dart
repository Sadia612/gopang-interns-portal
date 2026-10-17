
import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../services/profile_service.dart';

class ProfileController extends GetxController {
  final ProfileService _service = ProfileService();
  final ImagePicker _imagePicker = ImagePicker();

  final profile = Rxn<Map<String, dynamic>>();
  final selectedImage = Rxn<File>();

  final isLoading = false.obs;
  final isUploading = false.obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Map<String, dynamic> get profileData => profile.value ?? {};

  String _firstValue(List<String> keys, {String fallback = ''}) {
    for (final key in keys) {
      final value = profileData[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return fallback;
  }


  String get displayName => _firstValue(
    ['name', 'full_name', 'username'],
    fallback: 'My Profile',
  );

  String get email => _firstValue(['email']);

  String get phone => _firstValue([
    'phone',
    'phone_number',
    'mobile',
  ]);

  Map<String, dynamic> get employeeData {
    final employee = profileData['employee'];

    if (employee is Map) {
      return Map<String, dynamic>.from(employee);
    }

    return {};
  }

  String get designation =>
      employeeData['designation']?.toString().trim() ?? '';

  String get department =>
      employeeData['department']?.toString().trim() ?? '';

  String get employeeCode =>
      employeeData['employee_code']?.toString().trim() ?? '';

  String get joiningDate =>
      employeeData['joining_date']?.toString().trim() ?? '';

  String get employmentStatus =>
      employeeData['employment_status']?.toString().trim() ?? '';

  String get avatarUrl =>
      _firstValue(['avatar_url', 'profile_photo_url', 'photo_url']);


  Future<void> loadProfile() async {
    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final response = await _service.getProfile();

      final user = response['user'];
      final profileResponse = response['profile'];

      if (user is Map) {
        profile.value = Map<String, dynamic>.from(user);
      } else if (profileResponse is Map) {
        profile.value = Map<String, dynamic>.from(profileResponse);
      } else {
        errorMessage.value =
        'Profile information was not found in the API response.';
      }
    } catch (error) {
      errorMessage.value = _cleanError(error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> chooseAvatar() async {
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (pickedFile == null) return;

      final imageFile = File(pickedFile.path);
      final size = await imageFile.length();
      final extension = pickedFile.path.split('.').last.toLowerCase();

      if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
        errorMessage.value = 'Choose a JPG, PNG, or WEBP image.';
        return;
      }

      if (size > 2 * 1024 * 1024) {
        errorMessage.value = 'Image size must not exceed 2 MB.';
        return;
      }

      selectedImage.value = imageFile;
    } catch (error) {
      errorMessage.value = 'Could not select image: ${_cleanError(error)}';
    }
  }

  Future<void> uploadAvatar() async {
    final imageFile = selectedImage.value;

    if (imageFile == null) {
      errorMessage.value = 'Please select a photo first.';
      return;
    }

    isUploading.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final response = await _service.uploadAvatar(imageFile);
      final url = response['avatar_url'].toString();

      final updatedProfile = Map<String, dynamic>.from(profileData);
      updatedProfile['avatar_url'] = url;
      updatedProfile.remove('avatar');
      profile.value = updatedProfile;

      selectedImage.value = null;
      successMessage.value =
          response['message']?.toString() ??
              'Profile photo updated.';

      // Refresh the profile from the API so the server remains the source
      // of truth for the displayed profile information.
      await loadProfileAfterUpload();
    } catch (error) {
      errorMessage.value = _cleanError(error);
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> loadProfileAfterUpload() async {
    try {
      final response = await _service.getProfile();
      final user = response['user'];
      final profileResponse = response['profile'];

      if (user is Map) {
        profile.value = Map<String, dynamic>.from(user);
      } else if (profileResponse is Map) {
        profile.value = Map<String, dynamic>.from(profileResponse);
      }
    } catch (_) {
      // Keep the avatar_url returned by the successful upload response.
    }
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
