class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    this.isFavorite = false,
  });

  // تحويل من JSON إلى Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      category: json['category'],
      image: json['image'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  // تحويل من Product إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
      'isFavorite': isFavorite,
    };
  }
}