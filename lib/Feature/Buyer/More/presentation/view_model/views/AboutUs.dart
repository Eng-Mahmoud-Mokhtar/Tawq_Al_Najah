import 'package:flutter/material.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: S.of(context).AboutUs),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildParagraph(
              context,
              boldText: 'مرحباً بكم في طوق النجاة،',
              normalText:
              ' المنصّة التي وُجدت لتكون الجسر بين النجاح والطموح، وبيتًا يجمع بين التجارة، التسويق، والإعلان في منظومة رقمية واحدة متكاملة.',
              screenWidth: screenWidth,
            ),
            _buildParagraph(
              context,
              boldText: 'في عالمٍ يتسارع فيه التغيير،',
              normalText:
              ' يقدّم طوق النجاة فرصة حقيقية لكل من يسعى للنمو والتميّز، سواء كنت تاجرًا أو مسوقًا أو معلنًا.',
              screenWidth: screenWidth,
            ),
            _buildBulletParagraph(
              context,
              screenWidth,
              [
                'للتاجر: مساحة احترافية لعرض المنتجات والخدمات والوصول إلى عملاء جدد.',
                'للمسوق: نظام متطور للتسويق بالعمولة يضمن له عائداً مجزياً وفرصاً مستمرة للتطور.',
                'للمعلن: منصة موثوقة لعرض الإعلانات بطرق مبتكرة تحقق الانتشار والتأثير المطلوب.',
              ],
            ),
            _buildParagraph(
              context,
              boldText: 'نؤمن في طوق النجاة أن النجاح لا يتحقق بالمصادفة،',
              normalText:
              ' بل بصناعة الفرص والتعاون البنّاء. ولهذا صُمم الموقع ليكون أكثر من مجرد منصة، بل شريك نجاح لكل من يسعى لبناء اسم أو توسيع نشاط أو الوصول إلى جمهور أكبر.',
              screenWidth: screenWidth,
            ),
            _buildParagraph(
              context,
              boldText: 'رؤيتنا:',
              normalText:
              ' أن يكون طوق النجاة المنصة التسويقية والإعلانية الأولى عربيًا في الربط بين التاجر والمسوق والمجتمع، لتكوين بيئة رقمية متكاملة تمكّن الجميع من النمو وتدعم التنمية الاقتصادية والمجتمعية معًا.',
              screenWidth: screenWidth,
            ),
            _buildParagraph(
              context,
              boldText: 'رسالتنا:',
              normalText:
              ' تمكين الأفراد والشركات من النجاح عبر توفير منصة تسويقية شاملة تجمع بين التجارة، التسويق، والإعلان في منظومة رقمية واحدة، مع دعم المبادرات المجتمعية وتقديم حلول إلكترونية مبتكرة وسهلة الاستخدام.',
              screenWidth: screenWidth,
            ),
            _buildParagraph(
              context,
              boldText: 'قيمنا:',
              normalText:
              ' الشفافية، الابتكار، المسؤولية المجتمعية، التعاون، الاحترافية، والتمكين.',
              screenWidth: screenWidth,
            ),
            _buildParagraph(
              context,
              boldText: 'فكرة وإعداد:',
              normalText: ' الأستاذ / حسن معدي القرني – المملكة العربية السعودية – مدينة أبها.',
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
              text: boldText,
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

  Widget _buildBulletParagraph(BuildContext context, double screenWidth, List<String> bullets) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: bullets
            .map(
              (text) => Padding(
            padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.bold,
                    color: KprimaryColor,
                    height: 1.6,
                      fontFamily: 'Tajawal'
                  ),
                ),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: Colors.black87,
                      height: 1.6,
                        fontFamily: 'Tajawal'
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}
