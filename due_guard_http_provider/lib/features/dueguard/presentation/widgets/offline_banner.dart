import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:due_guard/core/constants/app_colors.dart';

class OfflineBanner extends StatelessWidget {
  final String message;
  const OfflineBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.soonBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.soon.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.wifi_off_rounded, size: 13, color: AppColors.soonText),
        const SizedBox(width: 8),
        Expanded(
            child: Text(message,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.soonText))),
      ]),
    );
  }
}
