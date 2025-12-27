import 'package:flutter/material.dart';
import 'package:tawqalnajah/Feature/Buyer/Home/Data/Model/CategoryModel.dart';
import 'CategoryItem.dart';

class CategoryList extends StatelessWidget {
  final List<CategoryModel> categories;
  final List<IconData> icons;
  final List<String> labels;
  final double width;
  final Function(CategoryModel, String) onCategoryTap;

  const CategoryList({
    Key? key,
    required this.categories,
    required this.icons,
    required this.labels,
    required this.width,
    required this.onCategoryTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: width * 0.2,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: icons.length,
        itemBuilder: (_, index) {
          const apiNames = [
            'السوق',
            'الكترونيات',
            'ملابس',
            'اثاث',
            'العاب',
            'مطبخ',
            'صحة',
          ];

          final apiName = index < apiNames.length ? apiNames[index] : (index + 1).toString();
          final displayLabelLocal = index < labels.length ? labels[index] : apiName;
          final icon = index < icons.length ? icons[index] : Icons.category;

          final category = (index < categories.length)
              ? categories[index]
              : CategoryModel(
                  id: index + 1,
                  name: apiName,
                  description: apiName,
                  icon: null,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

          return CategoryItem(
            category: category,
            icon: icon,
            displayLabel: displayLabelLocal,
            width: width,
            onTap: () => onCategoryTap(category, displayLabelLocal),
          );
        },
        separatorBuilder: (_, __) => SizedBox(width: width * 0.02),
      ),
    );
  }
}

