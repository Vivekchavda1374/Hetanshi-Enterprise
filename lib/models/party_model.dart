class Party {
  final String id;
  final String name;
  final String mobile;
  final String address;

  Party({
    required this.id,
    required this.name,
    required this.mobile,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'address': address,
    };
  }

  factory Party.fromMap(Map<String, dynamic> map, String documentId) {
    return Party(
      id: documentId,
      name: map['name'] ?? '',
      mobile: map['mobile'] ?? '',
      address: map['address'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Party &&
      other.id == id &&
      other.name == name &&
      other.mobile == mobile &&
      other.address == address;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      mobile.hashCode ^
      address.hashCode;
  }
}
