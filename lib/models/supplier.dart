class Supplier {
  final String id;
  String name;
  String phone;
  String city;
  String address;
  String representative;

  Supplier({
    required this.id,
    required this.name,
    required this.phone,
    required this.city,
    this.address = '',
    this.representative = '',
  });

  Supplier copyWith({
    String? id,
    String? name,
    String? phone,
    String? city,
    String? address,
    String? representative,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      address: address ?? this.address,
      representative: representative ?? this.representative,
    );
  }
}
