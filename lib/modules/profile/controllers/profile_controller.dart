
import 'package:get/get.dart';

import '../services/profile_service.dart';

class ProfileController extends GetxController {
  final ProfileService _service = ProfileService();

  final profile = Rxn<Map<String, dynamic>>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _service.getProfile();

      final user = response['user'];
      final data = response['profile'];

      if (user is Map) {
        profile.value = Map<String, dynamic>.from(user);
      } else if (data is Map) {
        profile.value = Map<String, dynamic>.from(data);
      } else {
        errorMessage.value =
        'The profile response does not contain user information.';
      }
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
