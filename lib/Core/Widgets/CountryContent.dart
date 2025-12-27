import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../generated/l10n.dart';
import 'CountryCubit.dart';

class CountryContent extends StatelessWidget {
  final double screenWidth;
  const CountryContent({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CountryCubit>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).ChooseCountryCode,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                size: screenWidth * 0.05,
                color: Colors.grey,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),

        SizedBox(height: screenWidth * 0.02),

        // Search bar
        Container(
          height: screenWidth * 0.12,
          decoration: BoxDecoration(
            color: const Color(0xffFAFAFA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xffE9E9E9)),
          ),
          child: TextField(
            style: TextStyle(
              color: Colors.black,
              fontSize: screenWidth * 0.03,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: S.of(context).Country,
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.bold,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: screenWidth * 0.035,
              ),
              prefixIcon: Icon(
                Icons.search_outlined,
                color: Colors.grey,
                size: screenWidth * 0.05,
              ),
            ),
            onChanged: (query) =>
                context.read<CountryCubit>().filterCountries(query),
          ),
        ),

        SizedBox(height: screenWidth * 0.02),

        // Country list
        Expanded(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: state.filteredCountries.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'Assets/magnifying-glass.png',
                    width: screenWidth * 0.3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    S.of(context).NoResultstoShow,
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.3),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: state.filteredCountries.length,
              itemBuilder: (context, index) {
                var country = state.filteredCountries[index];
                return ListTile(
                  title: Row(
                    children: [
                      Text(
                        country['flag']!,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: screenWidth * 0.12,
                        child: Text(
                          country['code']!,
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          country['name']!,
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    context.read<CountryCubit>().selectCountry(country);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
