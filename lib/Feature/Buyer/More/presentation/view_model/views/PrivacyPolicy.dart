import 'package:flutter/material.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: S.of(context).PrivacyPolicy),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildParagraph(
              context,
              boldText: 'سياسة الخصوصية لتطبيق طوق النجاة',
              normalText:
              ' نلتزم في طوق النجاة بحماية خصوصية مستخدمينا وضمان سرية بياناتهم الشخصية. تهدف هذه السياسة إلى توضيح كيفية جمع واستخدام وحماية المعلومات الخاصة بك أثناء استخدامك لتطبيقنا أو موقعنا الإلكتروني.',
              screenWidth: screenWidth,
            ),
            _buildParagraph(
              context,
              boldText: 'جمع المعلومات:',
              normalText:
              ' نقوم بجمع بعض المعلومات الضرورية لتحسين تجربة الاستخدام، مثل الاسم، رقم الجوال، البريد الإلكتروني، وموقعك الجغرافي عند الحاجة. يتم جمع هذه البيانات بموافقتك فقط، ولا نشاركها مع أي طرف ثالث دون إذنك المسبق.',
              screenWidth: screenWidth,
            ),
            _buildParagraph(
              context,
              boldText: 'استخدام المعلومات:',
              normalText:
              ' تُستخدم المعلومات التي يتم جمعها لتحسين الخدمات، تخصيص المحتوى، إرسال إشعارات، وإتمام العمليات داخل المنصة. كما نستخدمها لتطوير أداء النظام ودعم التواصل بين المستخدمين والتجار والمسوقين.',
              screenWidth: screenWidth,
            ),
            _buildParagraph(
              context,
              boldText: 'حماية المعلومات:',
              normalText:
              ' نستخدم أحدث التقنيات والإجراءات الأمنية لضمان حماية بياناتك من الوصول غير المصرح به أو التعديل أو الإفصاح. يتم تخزين البيانات في بيئة آمنة وتُراجع أنظمة الحماية بشكل دوري.',
              screenWidth: screenWidth,
            ),
            _buildParagraph(
              context,
              boldText: 'الكوكيز وملفات التتبع:',
              normalText:
              ' قد نستخدم ملفات تعريف الارتباط (Cookies) لتحسين تجربة المستخدم وتخصيص المحتوى. يمكنك اختيار تعطيل هذه الملفات من إعدادات متصفحك، لكن قد يؤثر ذلك على بعض خصائص التطبيق.',
              screenWidth: screenWidth,
            ),
            _buildParagraph(
              context,
              boldText: 'حقوق المستخدم:',
              normalText:
              ' لديك الحق في الوصول إلى بياناتك الشخصية أو تعديلها أو حذفها متى شئت، وذلك عبر إعدادات الحساب أو التواصل مع فريق الدعم.',
              screenWidth: screenWidth,
            ),
            _buildParagraph(
              context,
              boldText: 'تحديثات سياسة الخصوصية:',
              normalText:
              ' نحتفظ بحق تعديل أو تحديث هذه السياسة من وقت لآخر بما يتناسب مع التطورات التقنية والقانونية. سيتم إشعار المستخدمين بأي تغييرات مهمة عبر التطبيق أو البريد الإلكتروني.',
              screenWidth: screenWidth,
            ),
            _buildParagraph(
              context,
              boldText: 'التواصل معنا:',
              normalText:
              ' في حال وجود أي استفسارات أو ملاحظات حول سياسة الخصوصية، يمكنكم التواصل معنا عبر البريد الإلكتروني الرسمي أو صفحة "اتصل بنا" داخل التطبيق.',
              screenWidth: screenWidth,
            ),
            _buildParagraph(
              context,
              boldText: 'نشكركم على ثقتكم بطوق النجاة،',
              normalText:
              ' ونسعى دائماً لتوفير بيئة رقمية آمنة وموثوقة تحافظ على خصوصيتكم وتحقق لكم أفضل تجربة استخدام.',
              screenWidth: screenWidth,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParagraph(BuildContext context,
      {required String boldText, required String normalText, required double screenWidth}) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.03),
      child: RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          children: [
            TextSpan(
              text: '$boldText ',
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.bold,
                color: KprimaryColor,
                height: 1.6,
                  fontFamily: 'Tajawal'
              ),
            ),
            TextSpan(
              text: normalText,
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                color: Colors.black87,
                height: 1.6,
                  fontFamily: 'Tajawal'

              ),
            ),
          ],
        ),
      ),
    );
  }
}
