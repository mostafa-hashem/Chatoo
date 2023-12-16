class Address {
  String? city;
  String? region;
  String? addressDetails;

  Address({
    required this.city,
    required this.region,
    required this.addressDetails,
  });

  Address.fromJson(Map<String, dynamic> json) {
    city = json['city'] as String?;
    region = json['region'] as String?;
    addressDetails = json['addressDetails'] as String?;
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'region': region,
      'addressDetails': addressDetails,
    };
  }
}
