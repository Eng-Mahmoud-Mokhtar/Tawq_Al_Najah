
import '../../../../Core/Widgets/countryList.dart';

class CountryState {
  final String selectedCountryCode;
  final String selectedCountryFlag;
  final String selectedCountryShort;
  final List<Map<String, String>> filteredCountries;

  CountryState({
    required this.selectedCountryCode,
    required this.selectedCountryFlag,
    required this.selectedCountryShort,
    required this.filteredCountries,
  });

  CountryState copyWith({
    String? selectedCountryCode,
    String? selectedCountryFlag,
    String? selectedCountryShort,
    List<Map<String, String>>? filteredCountries,
  }) {
    return CountryState(
      selectedCountryCode: selectedCountryCode ?? this.selectedCountryCode,
      selectedCountryFlag: selectedCountryFlag ?? this.selectedCountryFlag,
      selectedCountryShort: selectedCountryShort ?? this.selectedCountryShort,
      filteredCountries: filteredCountries ?? this.filteredCountries,
    );
  }

  static CountryState initial() {
    return CountryState(
      selectedCountryCode: '+1',
      selectedCountryFlag: '🇺🇸',
      selectedCountryShort: 'US',
      filteredCountries: List.from(countryList),
    );
  }
}