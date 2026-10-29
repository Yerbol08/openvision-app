import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../core/api/api_exception.dart';
import '../data/models.dart';
import '../l10n/gen/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String get localeTag => Localizations.localeOf(this).toLanguageTag();
}

/// Время: сервер отдаёт UTC, показываем локальное.
class OvFormat {
  OvFormat(this.context);
  final BuildContext context;

  AppLocalizations get _l => context.l10n;
  String get _loc => context.localeTag;

  /// «15:42»
  String time(DateTime t) => DateFormat.Hm(_loc).format(t.toLocal());

  /// «29 октября»
  String dayMonth(DateTime t) => DateFormat.MMMMd(_loc).format(t.toLocal());

  /// «29 октября, 15:42:08» — абсолютное время для деталей.
  String full(DateTime t) => '${dayMonth(t)}, ${DateFormat.Hms(_loc).format(t.toLocal())}';

  /// «29.10 15:42:08» — тайм-код на кадре.
  String timecode(DateTime t) => DateFormat('dd.MM HH:mm:ss', _loc).format(t.toLocal());

  /// «2 мин назад» — относительное время для свежего.
  String ago(DateTime t) {
    final d = DateTime.now().difference(t.toLocal());
    if (d.inMinutes < 1) return _l.timeJustNow;
    if (d.inHours < 1) return _l.timeMinutesAgo(d.inMinutes);
    if (d.inDays < 1) return _l.timeHoursAgo(d.inHours);
    return _l.timeDaysAgo(d.inDays);
  }

  /// Заголовок группы ленты: «Сегодня», «Вчера», «27 октября».
  String dayHeader(DateTime t) {
    final local = t.toLocal();
    final now = DateTime.now();
    final day = DateTime(local.year, local.month, local.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return _l.dayToday;
    if (diff == 1) return _l.dayYesterday;
    return dayMonth(local);
  }
}

/// Текст для пользователя по `code` ошибки (§11). `message` сервера не показываем.
String errorText(AppLocalizations l, Object error) {
  if (error is! ApiException) return l.errGeneric;
  switch (error.code) {
    case ApiException.network:
      return l.errNetwork;
    case 'invalid_credentials':
      return l.errInvalidCredentials;
    case 'rate_limited':
      return l.errRateLimited(error.retryAfter ?? 60);
    case 'account_suspended':
      return l.errAccountSuspended;
    case 'email_taken':
      return l.errEmailTaken;
    case 'forbidden':
      return l.errForbidden;
    case 'not_found':
      return l.errNotFound;
    case 'owner_protected':
      return l.errOwnerProtected;
    case 'self_protected':
      return l.errSelfProtected;
    case 'wrong_password':
      return l.errWrongPassword;
    case 'camera_limit_reached':
      return l.errCameraLimit(error.limit ?? 0);
    case 'invalid_refresh_token':
    case 'unauthorized':
      return l.sessionExpired;
    default:
      debugPrint('Unhandled API error: ${error.code} (HTTP ${error.status})');
      return l.errGeneric;
  }
}

enum ReasonTone { warn, danger, info }

class ReasonText {
  const ReasonText(this.tone, this.title, this.text);
  final ReasonTone tone;
  final String title;
  final String text;
}

/// Объяснение `status_reason` (§5). Неизвестная причина — общий текст и код в лог.
ReasonText reasonText(AppLocalizations l, String reason) {
  switch (reason) {
    case 'waiting_for_video':
      return ReasonText(ReasonTone.warn, l.reasonWaitingForVideoTitle, l.reasonWaitingForVideoText);
    case 'edge_agent_offline':
      return ReasonText(ReasonTone.warn, l.reasonEdgeAgentOfflineTitle, l.reasonEdgeAgentOfflineText);
    case 'no_video':
      return ReasonText(ReasonTone.danger, l.reasonNoVideoTitle, l.reasonNoVideoText);
    case 'waiting_for_gpu':
      return ReasonText(ReasonTone.info, l.reasonWaitingForGpuTitle, l.reasonWaitingForGpuText);
    case 'source_unreachable':
      return ReasonText(ReasonTone.danger, l.reasonSourceUnreachableTitle, l.reasonSourceUnreachableText);
    case 'source_auth_failed':
      return ReasonText(ReasonTone.danger, l.reasonSourceAuthFailedTitle, l.reasonSourceAuthFailedText);
    case 'source_not_found':
      return ReasonText(ReasonTone.danger, l.reasonSourceNotFoundTitle, l.reasonSourceNotFoundText);
    case 'unsupported_codec':
      return ReasonText(ReasonTone.danger, l.reasonUnsupportedCodecTitle, l.reasonUnsupportedCodecText);
    case 'no_video_track':
      return ReasonText(ReasonTone.danger, l.reasonNoVideoTrackTitle, l.reasonNoVideoTrackText);
    case 'private_address_refused':
      return ReasonText(ReasonTone.danger, l.reasonPrivateAddressTitle, l.reasonPrivateAddressText);
    case 'ingest_error':
      return ReasonText(ReasonTone.info, l.reasonIngestErrorTitle, l.reasonIngestErrorText);
    default:
      debugPrint('Unknown camera status_reason: $reason');
      return ReasonText(ReasonTone.danger, l.reasonUnknownTitle, l.reasonUnknownText);
  }
}

String roleLabel(AppLocalizations l, String role) => switch (role) {
      'owner' => l.roleOwner,
      'admin' => l.roleAdmin,
      'operator' => l.roleOperator,
      'viewer' => l.roleViewer,
      _ => role,
    };

/// «1920×1080 · 25 fps · H.264»; null, если сервер не знает размер кадра.
String? streamText(AppLocalizations l, StreamInfo? info) {
  final w = info?.width, h = info?.height;
  if (info == null || w == null || h == null) return null;
  final raw = (info.codec ?? '').toLowerCase();
  final codec = switch (raw) {
    'h264' => 'H.264',
    'h265' || 'hevc' => 'H.265',
    _ => raw.toUpperCase(),
  };
  return l.cameraVideoValue(w, h, (info.fps ?? 0).round(), codec);
}

/// Адрес из локальной сети: из облака не виден, сервер его откажет (§7.1).
bool isPrivateStreamUrl(String url) {
  final host = Uri.tryParse(url.trim())?.host.toLowerCase() ?? '';
  if (host.isEmpty) return false;
  if (host == 'localhost' || host.endsWith('.local')) return true;
  final p = host.split('.').map(int.tryParse).toList();
  if (p.length != 4 || p.any((x) => x == null)) return false;
  final a = p[0]!, b = p[1]!;
  return a == 10 || a == 127 || (a == 192 && b == 168) || (a == 172 && b >= 16 && b <= 31) || (a == 169 && b == 254);
}
