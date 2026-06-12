class CartItem {
  final int? id;
  final int productId;
  final String title;
  final double price;
  final String image;
  final int quantity;

  CartItem({
    this.id,
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'title': title,
      'price': price,
      'image': image,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      productId: map['product_id'],
      title: map['title'],
      price: map['price'],
      image: map['image'],
      quantity: map['quantity'],
    );
  }
}