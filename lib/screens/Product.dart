class Product {
  final String reference; // Numéro
  final String entreprise; // Entreprise
  final int quantity; // Quantité

  Product({
    required this.reference,
    required this.entreprise,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'entreprise': entreprise,
      'quantity': quantity,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      reference: json['reference'],
      entreprise: json['entreprise'],
      quantity: json['quantity'],
    );
  }
}
