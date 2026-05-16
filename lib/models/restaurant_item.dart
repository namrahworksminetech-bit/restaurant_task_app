class RestaurantItem {
  final int id;
  final String name;
  final String description;
  final String image;
  final double price;

  final String calories;
  final String carbs;
  final String fats;
  final String proteins;

  RestaurantItem({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.calories,
    required this.carbs,
    required this.fats,
    required this.proteins,
  });
factory RestaurantItem.fromJson(
  Map<String, dynamic> json,
) {
  return RestaurantItem(
    id: json['id'] ?? 0,

    name: json['name'] ?? '',

    description:
        json['description'] ??
            json['shortDescription'] ??
            '',

    image:
        json['defaultImage'] ?? '',

    price:
        (json['finalPrice'] ?? 0)
            .toDouble(),

    calories:
        json['calories'] ?? '',

    carbs:
        json['carbs'] ?? '',

    fats:
        json['fats'] ?? '',

    proteins:
        json['proteins'] ?? '',
  );
}
}