import 'package:flutter/material.dart';
import '../../widgets/common/apollon_animated_background.dart';
import '../../widgets/common/apollon_page_container.dart';
import '../../widgets/content/apollon_weather_detail_content.dart';

class ApollonWeatherDetailPage extends StatelessWidget {
  const ApollonWeatherDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ApollonPageContainer(
        child: Stack(
          children: [
            // Ebene 0: Der dynamische Wetterhintergrund
            const ApollonAnimatedBackground(),

            // Ebene 1: Wetter-Detailinhalt
            const Padding(
              padding: EdgeInsets.all(32),
              child: ApollonWeatherDetailContent(),
            ),

            // Ebene 2: Zurück-Button oben links
            Positioned(
              top: 24,
              left: 24,
              child: ClipOval(
                child: Material(
                  color: Colors.white.withValues(alpha: 0.12),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
