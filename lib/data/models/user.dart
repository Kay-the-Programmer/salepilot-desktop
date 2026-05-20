class AppUser {
  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.currentStoreId,
    this.profilePicture,
    this.isVerified,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? currentStoreId;
  final String? profilePicture;
  final bool? isVerified;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      phone: json['phone']?.toString(),
      currentStoreId: json['currentStoreId']?.toString(),
      profilePicture: json['profilePicture']?.toString(),
      isVerified: json['isVerified'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        if (phone != null) 'phone': phone,
        if (currentStoreId != null) 'currentStoreId': currentStoreId,
        if (profilePicture != null) 'profilePicture': profilePicture,
        if (isVerified != null) 'isVerified': isVerified,
      };

  bool get canPerformSales => const {
        'admin',
        'staff',
        'superadmin',
        'inventory_manager',
      }.contains(role);
}
