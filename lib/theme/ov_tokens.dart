// Сгенерировано из дизайн-системы OpenVision (tokens.json). Не править вручную.
import 'package:flutter/material.dart';

@immutable
class OvColors extends ThemeExtension<OvColors> {
  final Color bg;
  final Color surface;
  final Color surfaceSunken;
  final Color line;
  final Color lineStrong;
  final Color ink;
  final Color inkMuted;
  final Color brand;
  final Color brandSoft;
  final Color onBrand;
  final Color scan;
  final Color onScan;
  final Color online;
  final Color onlineSoft;
  final Color warn;
  final Color warnSoft;
  final Color danger;
  final Color dangerSoft;
  final Color onDanger;
  final Color neutralSoft;
  final Color media;
  final Color mediaLine;
  final Color scrim;
  final Color onMedia;
  final Color link;
  const OvColors({required this.bg, required this.surface, required this.surfaceSunken, required this.line, required this.lineStrong, required this.ink, required this.inkMuted, required this.brand, required this.brandSoft, required this.onBrand, required this.scan, required this.onScan, required this.online, required this.onlineSoft, required this.warn, required this.warnSoft, required this.danger, required this.dangerSoft, required this.onDanger, required this.neutralSoft, required this.media, required this.mediaLine, required this.scrim, required this.onMedia, required this.link});
  static const light = OvColors(bg: Color(0xFFF3F4F1), surface: Color(0xFFFFFFFF), surfaceSunken: Color(0xFFE9EBE6), line: Color(0xFFDCDFD8), lineStrong: Color(0xFF848B84), ink: Color(0xFF13171C), inkMuted: Color(0xFF59616C), brand: Color(0xFF2443B8), brandSoft: Color(0xFFE7EBFA), onBrand: Color(0xFFFFFFFF), scan: Color(0xFFD4F53C), onScan: Color(0xFF13171C), online: Color(0xFF1B7A3A), onlineSoft: Color(0xFFE2F3E6), warn: Color(0xFF8F5400), warnSoft: Color(0xFFFBEFD8), danger: Color(0xFFC0261A), dangerSoft: Color(0xFFFBE5E2), onDanger: Color(0xFFFFFFFF), neutralSoft: Color(0xFFE9EBE6), media: Color(0xFF1A2129), mediaLine: Color(0xFF2E3844), scrim: Color(0xB30C1015), onMedia: Color(0xFFEEF1F4), link: Color(0xFF2443B8));
  static const dark = OvColors(bg: Color(0xFF0C1015), surface: Color(0xFF151A21), surfaceSunken: Color(0xFF0A0D11), line: Color(0xFF262D36), lineStrong: Color(0xFF5F6A78), ink: Color(0xFFEEF1F4), inkMuted: Color(0xFF9BA5B3), brand: Color(0xFF93A8FF), brandSoft: Color(0xFF1A2452), onBrand: Color(0xFF0C1015), scan: Color(0xFFD4F53C), onScan: Color(0xFF13171C), online: Color(0xFF4FD782), onlineSoft: Color(0xFF11301C), warn: Color(0xFFF2B546), warnSoft: Color(0xFF36280D), danger: Color(0xFFFF8C80), dangerSoft: Color(0xFF3C1613), onDanger: Color(0xFF0C1015), neutralSoft: Color(0xFF222932), media: Color(0xFF1A2129), mediaLine: Color(0xFF2E3844), scrim: Color(0xB3000000), onMedia: Color(0xFFEEF1F4), link: Color(0xFF93A8FF));
  @override
  OvColors copyWith() => this;
  @override
  OvColors lerp(ThemeExtension<OvColors>? other, double t) => t < .5 ? this : (other as OvColors? ?? this);
}

class OvSpace {
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space8 = 32;
}

class OvRadius {
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 20;
  static const double radiusFull = 9999;
}

class OvSize {
  static const double tapMin = 48;
  static const double controlH = 48;
  static const double controlHSm = 36;
  static const double tabbarH = 64;
  static const double thumbCamera = 88;
  static const double thumbFace = 56;
}

class OvText {
  static const sansFamily = 'Golos Text';
  static const monoFamily = 'JetBrains Mono';
  static const display = TextStyle(fontFamily: sansFamily, fontSize: 28, height: 1.214, fontWeight: FontWeight.w600, letterSpacing: -0.28);
  static const metric = TextStyle(fontFamily: sansFamily, fontSize: 32, height: 1.125, fontWeight: FontWeight.w600, letterSpacing: -0.64);
  static const title = TextStyle(fontFamily: sansFamily, fontSize: 20, height: 1.3, fontWeight: FontWeight.w600);
  static const headline = TextStyle(fontFamily: sansFamily, fontSize: 16, height: 1.375, fontWeight: FontWeight.w600);
  static const body = TextStyle(fontFamily: sansFamily, fontSize: 15, height: 1.467, fontWeight: FontWeight.w400);
  static const bodyStrong = TextStyle(fontFamily: sansFamily, fontSize: 15, height: 1.467, fontWeight: FontWeight.w500);
  static const caption = TextStyle(fontFamily: sansFamily, fontSize: 13, height: 1.385, fontWeight: FontWeight.w400);
  static const label = TextStyle(fontFamily: sansFamily, fontSize: 12, height: 1.333, fontWeight: FontWeight.w600, letterSpacing: 0.12);
  static const mono = TextStyle(fontFamily: monoFamily, fontSize: 13, height: 1.538, fontWeight: FontWeight.w400);
  static const timecode = TextStyle(fontFamily: monoFamily, fontSize: 12, height: 1.333, fontWeight: FontWeight.w500);
}
