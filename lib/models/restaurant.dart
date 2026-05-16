class Restaurant {
  final int id;
  final String name;
  final String description;
  final String image;
  final double rating;
  final int deliveryTime;
  final double distance;
final int isOpen;
  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.rating,
    required this.deliveryTime,
    required this.distance,
    required this.isOpen,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      deliveryTime: json['deliveryTime'] ?? 0,
      distance: (json['distance'] ?? 0).toDouble(),
      isOpen: json['isOpen'] ?? 0,
    );
  }
}