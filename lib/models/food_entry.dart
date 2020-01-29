import 'dart:io';

class Food {
  final String id;
  final File image;
  final String name;
  final int carbohydrates;
  final String category;
  final String description;

  Food({
    this.id,
    this.image,
    this.name,
    this.carbohydrates,
    this.category,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
      'name': name,
      'carbohydrates': carbohydrates,
      'category': category,
      'description': description,
    };
  }
}
