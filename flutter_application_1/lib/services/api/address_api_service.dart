import '../../data/models/models.dart';
import 'api_client.dart';
import '../../core/exceptions/api_exception.dart';

/// API Service for Addresses
class AddressApiService {
  final _apiClient = ApiClient();

  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await _apiClient.get('/addresses');
      final data = response['data'] as List<dynamic>? ?? response['addresses'] as List<dynamic>? ?? [];
      return data.map((json) => _addressFromJson(json)).toList();
    } catch (e) {
      throw ApiException('Failed to fetch addresses: ${e.toString()}');
    }
  }

  Future<AddressModel> createAddress(AddressModel address) async {
    try {
      final response = await _apiClient.post('/addresses', body: {
        'label': address.label,
        'fullAddress': address.fullAddress,
        'street': address.street,
        'city': address.city,
        'zipCode': address.zipCode,
        'latitude': address.latitude,
        'longitude': address.longitude,
        'isDefault': address.isDefault,
      });

      final data = response['data'] ?? response;
      return _addressFromJson(data);
    } catch (e) {
      throw ApiException('Failed to create address: ${e.toString()}');
    }
  }

  Future<AddressModel> updateAddress(AddressModel address) async {
    try {
      final response = await _apiClient.put('/addresses/${address.id}', body: {
        'label': address.label,
        'fullAddress': address.fullAddress,
        'street': address.street,
        'city': address.city,
        'zipCode': address.zipCode,
        'latitude': address.latitude,
        'longitude': address.longitude,
        'isDefault': address.isDefault,
      });

      final data = response['data'] ?? response;
      return _addressFromJson(data);
    } catch (e) {
      throw ApiException('Failed to update address: ${e.toString()}');
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      await _apiClient.delete('/addresses/$id');
    } catch (e) {
      throw ApiException('Failed to delete address: ${e.toString()}');
    }
  }

  AddressModel _addressFromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return AddressModel(
        id: json['id']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
        fullAddress: json['fullAddress']?.toString() ?? '',
        street: json['street']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
        zipCode: json['zipCode']?.toString() ?? '',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
        isDefault: json['isDefault'] as bool? ?? false,
      );
    }
    throw ApiException('Invalid address data format');
  }
}

