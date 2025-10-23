import 'package:bloc/bloc.dart';

import '../../../../Core/Widgets/countryList.dart';
import 'CountryState.dart';

class CountryCubit extends Cubit<CountryState> {
  CountryCubit() : super(CountryState.initial());

  void filterCountries(String query) {
    emit(state.copyWith(
      filteredCountries: countryList
          .where((country) =>
      country['name']!.toLowerCase().contains(query.toLowerCase()) ||
          country['code']!.contains(query))
          .toList(),
    ));
  }

  void resetFilter() {
    emit(state.copyWith(filteredCountries: List.from(countryList)));
  }

  void selectCountry(Map<String, String> country) {
    emit(state.copyWith(
      selectedCountryCode: country['code']!,
      selectedCountryFlag: country['flag']!,
      selectedCountryShort: country['short']!,
    ));
  }
}

