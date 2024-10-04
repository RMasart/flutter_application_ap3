class Product {
  final String reference;
  final String designation;
  final int quantity;

  Product({
    required this.reference,
    required this.designation,
    required this.quantity,
  });

  // Convertir un JSON en Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      reference: json['reference'],
      designation: json['designation'],
      quantity: json['quantity'],
    );
  }

  // Convertir un Product en JSON
  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'designation': designation,
      'quantity': quantity,
    };
  }
}
