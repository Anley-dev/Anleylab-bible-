import 'package:flutter/material.dart';
import 'package:amharic_catholic_bible/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://www.anleylab.et');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Accent colors aligned with premium Catholic branding
    const primaryGold = AppColors.liturgicalGold;
    const deepBurgundy = Color(0xFF800020);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ስለ መተግበሪያው (About)'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // HERO BRANDING SECTION WITH IMAGE LOGO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFDFBF7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: primaryGold.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Adaptive Logo Wrapper (Light Card for Dark Theme, Clean Border for Light Theme)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black12,
                      ),
                    ),
                    child: Image.asset(
                      'assets/images/anleylab_logo.png',
                      height: 70,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ANLEYLAB Bible',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Complete 73-Book Canon',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primaryGold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Clickable Web Link
                  InkWell(
                    onTap: _launchURL,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.language, size: 16, color: deepBurgundy),
                          SizedBox(width: 6),
                          Text(
                            'www.anleylab.et',
                            style: TextStyle(
                              fontSize: 14,
                              color: deepBurgundy,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // DESCRIPTION STATEMENT
            Text(
              'የአንሌይላብ መጽሐፍ ቅዱስ በነጻ የሚሰራ፣ የኢንተርኔት ግንኙነት የማይፈልግ የካቶሊክ መጽሐፍ ቅዱስ በአማርኛ ቋንቋ ሲሆን፤ ቅዱሳት መጻሕፍትን ለሁሉም በቀላሉ ተደራሽ ለማድረግ የተዘጋጀ መተግበሪያ ነው።',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'መተግበሪያው ሁለተኛ የቀኖና መጻሕፍትን ጨምሮ ሙሉውን የ73ቱ መጻሕፍት የካቶሊክ ቀኖና ይዟል። ከመስመር ውጭ ማንበብ፣ ጥቅሶችን ማስታወስ፣ ማድመቅ፣ የግል ማስታወሻዎችን መጻፍ፣ መፈለግ እና ካቆሙበት ማንበብ መተግበሪያው ከሚሰጣቸው አገልግሎቶች መካከል ጥቂቶቹ ናቸው።',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'ለኢትዮጵያ ካቶሊካዊት ቤተክርስቲያን ማኅበረሰብ እና የአምላክን ቃል በአማርኛ ማንበብ ለሚፈልጉ ሁሉ በአንሌይላብ በፍቅር እና በጥንቃቄ የተዘጋጀ።',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
              ),
            ),

            const SizedBox(height: 28),

            // FEATURES LIST
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ባህሪያት (Features)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _FeatureChip(label: 'ሙሉ 73 መጻሕፍት (የካቶሊክ ቀኖና)'),
                _FeatureChip(label: 'የአማርኛ ቅዱሳት መጻሕፍት'),
                _FeatureChip(label: 'ከመስመር ውጭ (Offline) የሚሠራ'),
                _FeatureChip(label: 'ጥቅስ ማስታወሻ (Bookmarks)'),
                _FeatureChip(label: 'ጥቅስ ማድመቂያ (Highlights)'),
                _FeatureChip(label: 'የግል አስተያየት መጻፊያ (Personal notes)'),
                _FeatureChip(label: 'ጥቅስ መፈለጊያ (Bible search)'),
                _FeatureChip(label: 'የንባብ ታሪክ (Reading history)'),
                _FeatureChip(label: 'ካቆሙበት መቀጠያ (Continue Reading)'),
                _FeatureChip(label: 'ጨለማ ሁነታ (Dark mode)'),
                _FeatureChip(label: 'የፊደል መጠን ማስተካከያ'),
                _FeatureChip(label: 'ቀጣይ እና ቀዳሚ ምዕራፍ መሄጃ'),
              ],
            ),

            const SizedBox(height: 28),

            // PRIVACY & OFFLINE CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: primaryGold, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'የአንሌይላብ መጽሐፍ ቅዱስ ሙሉ በሙሉ በነፃ የሚሰራ ሲሆን የንባብ መረጃዎን ወይም ማንነትዎን በምንም መልኩ አይሰበስብም። መለያ መፍጠርም አያስፈልገውም።',
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // FOOTER / METADATA
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Made with ',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                Text(
                  '❤️',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  ' by ANLEYLAB',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              '© 2026 ANLEYLAB',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Custom Feature Tag Chip
class _FeatureChip extends StatelessWidget {
  final String label;

  const _FeatureChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '•  $label',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white70 : const Color(0xFF333333),
        ),
      ),
    );
  }
}
