
import '../../dashboard/services/dashboard_service.dart';

class ProfileService {
  final DashboardService _dashboardService = DashboardService();

  Future<Map<String, dynamic>> getProfile() {
    return _dashboardService.getProfile();
  }
}
