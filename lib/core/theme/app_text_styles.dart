import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get brand => GoogleFonts.inter(
    fontSize: 32.sp,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    letterSpacing: -0.8,
  );

  static TextStyle get title => GoogleFonts.inter(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get subtitle => GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.6,
  );

  static TextStyle get body => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static TextStyle get button => GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}
