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
}
