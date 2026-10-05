import '../constants/api_constants.dart';

class Doctor {
  final int id;
  final String name;
  final String specialization;
  final double rating;
  final int reviews;
  final String image;
  final double fee;
  final int experience;
  final String about;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    this.rating = 0.0,
    this.reviews = 0,
    this.image = 'https://i.pravatar.cc/150', // Default placeholder
    required this.fee,
    required this.experience,
    required this.about,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    String img = json['image'] ?? '';

    // If image is a local asset filename (e.g. doc1.png), prepend path
    if (img.isNotEmpty && !img.startsWith('http') && !img.contains('/')) {
        img = 'assets/images/$img';
    } else if (img.isEmpty) {
        img = 'https://i.pravatar.cc/150?img=${json['id']}';
    }

    return Doctor(
      id: json['id'],
      name: json['name'],
      specialization: json['specialization'],
      fee: (json['fee'] as num).toDouble(),
      experience: json['experience'],
      about: json['about'] ?? '',
      // Defaults for fields not in backend
      rating: 4.5, 
      reviews: 0,
      image: json['profileImage'] != null 
          ? '${ApiConstants.profileImage}/${json['profileImage']}'
          : (img.isEmpty ? 'https://i.pravatar.cc/150?img=${json['id']}' : img),
    );
  }
}

// Mock Data Removed - fetching from API now
