class CustomerInput {
  final String name;
  final String address;
  final String areaId;
  final String categoryId;
  final String areaName;       // denormalized
  final String categoryName;   // denormalized
  final String? createdByUid;

  const CustomerInput({
    required this.name,
    required this.address,
    required this.areaId,
    required this.categoryId,
    required this.areaName,
    required this.categoryName,
    this.createdByUid,
  });

  Map<String, dynamic> toMap() => {
    'name': name.trim(),
    'address': address.trim(),
    'areaId': areaId,
    'categoryId': categoryId,
    'areaName': areaName,
    'categoryName': categoryName,
    'createdBy': createdByUid,
  };
}
