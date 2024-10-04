class Product {
  final String reference;
  final String designation;
  final int quantity;

  Product(
      {required this.reference,
      required this.designation,
      required this.quantity});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      reference: json['reference'],
      designation: json['designation'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'designation': designation,
      'quantity': quantity,
    };
  }
}
