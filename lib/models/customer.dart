class Customer {
  final String id;
  String name;
  String phone;
  String address;
  String cnic;
  double creditLimit;
  String notes;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.cnic = '',
    this.creditLimit = 150000.0,
    this.notes = '',
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? cnic,
    double? creditLimit,
    String? notes,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      cnic: cnic ?? this.cnic,
      creditLimit: creditLimit ?? this.creditLimit,
      notes: notes ?? this.notes,
    );
  }
}
