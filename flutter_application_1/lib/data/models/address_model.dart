/// Address model for delivery addresses
class AddressModel {
  final String id;
  final String label; // Home, Work, etc.
  final String fullAddress;
  final String street;
  final String city;
  final String zipCode;
  final double latitude;
  final double longitude;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.street,
    required this.city,
    required this.zipCode,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });
}

