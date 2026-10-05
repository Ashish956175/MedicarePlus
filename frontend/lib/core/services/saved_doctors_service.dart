import 'package:shared_preferences/shared_preferences.dart';

class SavedDoctorsService {
  static const String _savedDoctorsKey = 'saved_doctors';

  // Get list of saved doctor IDs
  Future<List<int>> getSavedDoctors() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = prefs.getStringList(_savedDoctorsKey) ?? [];
    return savedIds.map((id) => int.parse(id)).toList();
  }

  // Check if a doctor is saved
  Future<bool> isDoctorSaved(int doctorId) async {
    final savedDoctors = await getSavedDoctors();
    return savedDoctors.contains(doctorId);
  }

  // Toggle saved status
  Future<void> toggleSavedDoctor(int doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    final savedDoctors = await getSavedDoctors();
    
    if (savedDoctors.contains(doctorId)) {
      savedDoctors.remove(doctorId);
    } else {
      savedDoctors.add(doctorId);
    }
    
    await prefs.setStringList(
      _savedDoctorsKey,
      savedDoctors.map((id) => id.toString()).toList(),
    );
  }
}
