class CountryCurrency {
  final String countryName;
  final String countryCode;
  final String currencyCode;
  final String currencyName;
  final String flag;

  CountryCurrency({
    required this.countryName,
    required this.countryCode,
    required this.currencyCode,
    required this.currencyName,
    required this.flag,
  });

  Map<String, dynamic> toMap() {
    return {
      'countryName': countryName,
      'countryCode': countryCode,
      'currencyCode': currencyCode,
      'currencyName': currencyName,
      'flag': flag,
    };
  }

  factory CountryCurrency.fromMap(Map<String, dynamic> map) {
    return CountryCurrency(
      countryName: map['countryName'] ?? '',
      countryCode: map['countryCode'] ?? '',
      currencyCode: map['currencyCode'] ?? '',
      currencyName: map['currencyName'] ?? '',
      flag: map['flag'] ?? '',
    );
  }

  @override
  String toString() {
    return 'CountryCurrency(countryName: $countryName, countryCode: $countryCode, currencyCode: $currencyCode, currencyName: $currencyName, flag: $flag)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CountryCurrency &&
        other.countryName == countryName &&
        other.countryCode == countryCode &&
        other.currencyCode == currencyCode &&
        other.currencyName == currencyName &&
        other.flag == flag;
  }

  @override
  int get hashCode {
    return countryName.hashCode ^
        countryCode.hashCode ^
        currencyCode.hashCode ^
        currencyName.hashCode ^
        flag.hashCode;
  }
}
