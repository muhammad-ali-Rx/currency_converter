import 'package:currency_converter/model/country_currency.dart';



class CountriesData {
  static List<CountryCurrency> getAllCountries() {
    return [
      CountryCurrency(
        countryName: 'United States',
        countryCode: 'US',
        currencyCode: 'USD',
        currencyName: 'US Dollar',
        flag: '🇺🇸',
      ),
      CountryCurrency(
        countryName: 'Pakistan',
        countryCode: 'PK',
        currencyCode: 'PKR',
        currencyName: 'Pakistani Rupee',
        flag: '🇵🇰',
      ),
      CountryCurrency(
        countryName: 'India',
        countryCode: 'IN',
        currencyCode: 'INR',
        currencyName: 'Indian Rupee',
        flag: '🇮🇳',
      ),
      CountryCurrency(
        countryName: 'United Kingdom',
        countryCode: 'GB',
        currencyCode: 'GBP',
        currencyName: 'British Pound',
        flag: '🇬🇧',
      ),
      CountryCurrency(
        countryName: 'European Union',
        countryCode: 'EU',
        currencyCode: 'EUR',
        currencyName: 'Euro',
        flag: '🇪🇺',
      ),
      CountryCurrency(
        countryName: 'Japan',
        countryCode: 'JP',
        currencyCode: 'JPY',
        currencyName: 'Japanese Yen',
        flag: '🇯🇵',
      ),
      CountryCurrency(
        countryName: 'Canada',
        countryCode: 'CA',
        currencyCode: 'CAD',
        currencyName: 'Canadian Dollar',
        flag: '🇨🇦',
      ),
      CountryCurrency(
        countryName: 'Australia',
        countryCode: 'AU',
        currencyCode: 'AUD',
        currencyName: 'Australian Dollar',
        flag: '🇦🇺',
      ),
      CountryCurrency(
        countryName: 'Switzerland',
        countryCode: 'CH',
        currencyCode: 'CHF',
        currencyName: 'Swiss Franc',
        flag: '🇨🇭',
      ),
      CountryCurrency(
        countryName: 'China',
        countryCode: 'CN',
        currencyCode: 'CNY',
        currencyName: 'Chinese Yuan',
        flag: '🇨🇳',
      ),
    ];
  }

  static CountryCurrency? getCountryByCurrencyCode(String currencyCode) {
    try {
      return getAllCountries().firstWhere(
        (country) => country.currencyCode == currencyCode,
      );
    } catch (e) {
      return null;
    }
  }

  static CountryCurrency getDefaultCountry() {
    return CountryCurrency(
      countryName: 'United States',
      countryCode: 'US',
      currencyCode: 'USD',
      currencyName: 'US Dollar',
      flag: '🇺🇸',
    );
  }
}
