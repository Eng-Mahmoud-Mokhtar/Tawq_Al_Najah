import 'package:flutter/material.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';

class TermsConditions extends StatelessWidget {
  const TermsConditions({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: S.of(context).TermsandConditions),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, 'الشروط والأحكام لموقع وتطبيق طوق النجاة'),
            _paragraph(
              context,
              'مرحبًا بك في موقع وتطبيق طوق النجاة، المنصة المتخصصة في التسويق الإلكتروني والإعلانات التجارية ودعم الشراكات المجتمعية. '
                  'باستخدامك لخدماتنا، فإنك توافق على الالتزام بهذه الشروط والأحكام. يُرجى قراءتها بعناية قبل الاستخدام.',
            ),

            _sectionTitle(context, 'أولاً: التعريف'),
            _paragraph(
              context,
              'يُقصد بـ "المنصة" كل من موقع طوق النجاة الإلكتروني والتطبيق الخاص به. '
                  'أما "المستخدم" فهو أي شخص يقوم بتصفح أو استخدام خدمات المنصة بأي شكل من الأشكال.',
            ),

            _sectionTitle(context, 'ثانياً: قبول الشروط'),
            _paragraph(
              context,
              'يُعد استخدامك للمنصة موافقة صريحة منك على هذه الشروط والأحكام. '
                  'إذا كنت لا توافق على أي من بنودها، يُرجى الامتناع عن استخدام خدماتنا.',
            ),

            _sectionTitle(context, 'ثالثاً: الخدمات المقدمة'),
            _paragraph(
              context,
              '1. تقديم خدمات تسويق إلكتروني وإعلانات مدفوعة.\n'
                  '2. الربط بين التجار والمسوقين بنظام العمولة.\n'
                  '3. نشر العروض والخصومات بشكل منظم وآمن.\n'
                  '4. دعم الشراكات المجتمعية وتشجيع الأنشطة التطوعية والخيرية.',
            ),

            _sectionTitle(context, 'رابعاً: التزامات المستخدم'),
            _paragraph(
              context,
              'يتوجب على المستخدم تقديم بيانات صحيحة ومحدثة أثناء التسجيل، '
                  'والامتناع عن نشر أي محتوى مخالف للأنظمة أو القيم الدينية والمجتمعية، '
                  'كما يُمنع استخدام المنصة في أي أنشطة غير مشروعة أو مسيئة لسمعة طوق النجاة.',
            ),

            _sectionTitle(context, 'خامساً: حقوق الملكية الفكرية'),
            _paragraph(
              context,
              'جميع النصوص، الصور، التصاميم، والشعارات المعروضة في المنصة مملوكة لموقع طوق النجاة، '
                  'ويُمنع إعادة استخدامها أو نسخها أو تعديلها دون إذن كتابي مسبق من إدارة المنصة.',
            ),

            _sectionTitle(context, 'سادساً: الإعلانات والمسؤولية'),
            _paragraph(
              context,
              'يتحمل المُعلن كامل المسؤولية عن دقة وصحة بيانات إعلانه. '
                  'ويحتفظ الموقع بحق رفض أو حذف أي إعلان يخالف القوانين أو سياسة الاستخدام دون إشعار مسبق. '
                  'كما يتم تحديد نسبة العمولة أو التسويق بناءً على اتفاق مُسبق مع إدارة المنصة.',
            ),

            _sectionTitle(context, 'سابعاً: حدود المسؤولية'),
            _paragraph(
              context,
              'لا يتحمل موقع أو تطبيق طوق النجاة أي مسؤولية عن الأضرار الناتجة عن سوء استخدام الخدمة، '
                  'أو عن الأعطال التقنية الخارجة عن الإرادة، أو عن محتوى نُشر من قبل أطراف خارجية.',
            ),

            _sectionTitle(context, 'ثامناً: الخصوصية واستخدام الكوكيز'),
            _paragraph(
              context,
              'تلتزم المنصة بحماية خصوصية المستخدمين وفقًا لسياسة الخصوصية الخاصة بنا. '
                  'نستخدم ملفات تعريف الارتباط (Cookies) لتحسين تجربة المستخدم وتقديم خدمات مخصصة بشكل أفضل.',
            ),

            _sectionTitle(context, 'تاسعاً: التعديلات على الشروط'),
            _paragraph(
              context,
              'تحتفظ إدارة المنصة بحق تعديل أو تحديث هذه الشروط في أي وقت. '
                  'سيتم إخطار المستخدمين بأي تغييرات جوهرية من خلال المنصة أو عبر البريد الإلكتروني المسجل.',
            ),

            _sectionTitle(context, 'عاشراً: القانون المطبق'),
            _paragraph(
              context,
              'تخضع هذه الشروط والأحكام لأنظمة المملكة العربية السعودية، '
                  'وأي نزاع ينشأ عنها يُحال إلى الجهات القضائية المختصة داخل المملكة.',
            ),

            SizedBox(height: screenWidth * 0.06),
            Center(
              child: Text(
                'حقوق النشر © 2025 موقع وتطبيق طوق النجاة - جميع الحقوق محفوظة',
                style: TextStyle(
                  fontSize: screenWidth * 0.03,
                  color: Colors.black54,
                  fontFamily: 'Tajawal',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Text(
      title,
      style: TextStyle(
        color: KprimaryColor,
        fontSize: screenWidth * 0.03,
        fontWeight: FontWeight.bold,
        fontFamily: 'Tajawal',
      ),
    );
  }

  Widget _paragraph(BuildContext context, String text) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Text(
      text,
      style: TextStyle(
        color: Colors.black87,
        fontSize: screenWidth * 0.03,
        height: 1.6,
        fontFamily: 'Tajawal',
      ),
      textAlign: TextAlign.justify,
    );
  }
}
