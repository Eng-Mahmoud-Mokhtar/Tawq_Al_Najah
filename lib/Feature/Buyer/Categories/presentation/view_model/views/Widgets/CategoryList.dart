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
            'other',
            'electronics',
            'fashion',
            'furniture',
            'toys',
            'kitchen',
            'health',
            'books',
          ];

          final apiName = index < apiNames.length ? apiNames[index] : (index + 1).toString();
          final displayLabelLocal = index < labels.length ? labels[index] : apiName;
          final icon = index < icons.length ? icons[index] : Icons.category;

          // الفئة الأصلية (لو موجودة)
          final originalCategory = (index < categories.length)
              ? categories[index]
              : CategoryModel(
            id: index + 1,
            name: apiName,
            description: apiName,
            icon: null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          // كائن للاستخدام في الـ API: name = slug الثابت (apiName)
          final categoryForApi = CategoryModel(
            id: originalCategory.id,
            name: apiName, // هذا ما سيتم إرساله للـ API
            description: originalCategory.description,
            icon: originalCategory.icon,
            createdAt: originalCategory.createdAt,
            updatedAt: originalCategory.updatedAt,
          );

          return CategoryItem(
            category: originalCategory, // للعرض فقط
            icon: icon,
            displayLabel: displayLabelLocal,
            width: width,
            onTap: () => onCategoryTap(categoryForApi, displayLabelLocal), // نمرر الـ slug للـ API
          );
        },
        separatorBuilder: (_, __) => SizedBox(width: width * 0.02),
      ),
    );
  }
}
