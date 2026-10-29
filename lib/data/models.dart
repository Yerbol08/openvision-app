// Модели ответов API (MOBILE_API_HANDOFF.md §4–6). Неизвестные поля игнорируем,
// любое поле `X | null` может прийти пустым.

DateTime? _time(Object? v) => v is String ? DateTime.tryParse(v) : null;
double? _double(Object? v) => v is num ? v.toDouble() : null;

class Permissions {
  static const camerasRead = 'cameras.read';
  static const camerasControl = 'cameras.control';
  static const camerasWrite = 'cameras.write';
  static const eventsRead = 'events.read';
  static const usersRead = 'users.read';
  static const usersWrite = 'users.write';
}

class User {
  User({required this.id, required this.email, required this.fullName, required this.role, required this.isActive});

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id'] as String,
        email: j['email'] as String? ?? '',
        fullName: j['full_name'] as String? ?? '',
        role: j['role'] as String? ?? '',
        isActive: j['is_active'] as bool? ?? true,
      );

  final String id;
  final String email;
  final String fullName;
  final String role;
  final bool isActive;
}

class Tenant {
  Tenant({required this.id, required this.name, required this.plan, required this.maxCameras, required this.retentionDays});

  factory Tenant.fromJson(Map<String, dynamic> j) => Tenant(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        plan: j['plan'] as String? ?? '',
        maxCameras: (j['max_cameras'] as num?)?.toInt() ?? 0,
        retentionDays: (j['retention_days'] as num?)?.toInt() ?? 0,
      );

  final String id;
  final String name;
  final String plan;
  final int maxCameras;
  final int retentionDays;
}

class Me {
  Me({required this.user, required this.tenant, required this.permissions});

  factory Me.fromJson(Map<String, dynamic> j) => Me(
        user: User.fromJson(j['user'] as Map<String, dynamic>),
        tenant: Tenant.fromJson(j['tenant'] as Map<String, dynamic>),
        permissions: {for (final p in (j['permissions'] as List? ?? const [])) p as String},
      );

  final User user;
  final Tenant tenant;
  final Set<String> permissions;

  /// Интерфейс строится по правам, а не по роли.
  bool can(String permission) => permissions.contains(permission);
}

class StreamInfo {
  StreamInfo({this.codec, this.width, this.height, this.fps});

  factory StreamInfo.fromJson(Map<String, dynamic> j) => StreamInfo(
        codec: j['codec'] as String?,
        width: (j['width'] as num?)?.toInt(),
        height: (j['height'] as num?)?.toInt(),
        fps: _double(j['fps']),
      );

  final String? codec;
  final int? width;
  final int? height;
  final double? fps;
}

class Camera {
  Camera({
    required this.id,
    required this.name,
    this.location,
    required this.mode,
    this.sourceUrl,
    this.edgeAgentId,
    required this.enabled,
    required this.status,
    this.statusReason,
    this.streamInfo,
    this.lastSeenAt,
    this.lastEventAt,
  });

  factory Camera.fromJson(Map<String, dynamic> j) => Camera(
        id: (j['id'] as num).toInt(),
        name: j['name'] as String? ?? '',
        location: j['location'] as String?,
        mode: j['mode'] as String? ?? '',
        sourceUrl: j['source_url'] as String?,
        edgeAgentId: j['edge_agent_id'] as String?,
        enabled: j['enabled'] as bool? ?? true,
        status: j['status'] as String? ?? '',
        statusReason: j['status_reason'] as String?,
        streamInfo: j['stream_info'] is Map ? StreamInfo.fromJson(j['stream_info'] as Map<String, dynamic>) : null,
        lastSeenAt: _time(j['last_seen_at']),
        lastEventAt: _time(j['last_event_at']),
      );

  final int id;
  final String name;
  final String? location;
  final String mode;

  /// Адрес без пароля (`rtsp://***@host/...`); настоящий в приложение не приходит.
  final String? sourceUrl;
  final String? edgeAgentId;
  final bool enabled;
  final String status;
  final String? statusReason;
  final StreamInfo? streamInfo;
  final DateTime? lastSeenAt;
  final DateTime? lastEventAt;

  /// Статус для бейджа: выключенная клиентом камера всегда «Выключена».
  String get displayStatus => enabled ? status : 'disabled';

  bool get isOnline => displayStatus == 'online';

  /// Камера не работает и не выключена намеренно.
  bool get needsAttention => enabled && status != 'online' && status != 'disabled';

  /// Явный сбой — для счётчика на вкладке.
  bool get isBroken => enabled && (status == 'offline' || status == 'error');

  Camera copyWith({bool? enabled, DateTime? lastEventAt}) => Camera(
        id: id,
        name: name,
        location: location,
        mode: mode,
        sourceUrl: sourceUrl,
        edgeAgentId: edgeAgentId,
        enabled: enabled ?? this.enabled,
        status: status,
        statusReason: statusReason,
        streamInfo: streamInfo,
        lastSeenAt: lastSeenAt,
        lastEventAt: lastEventAt ?? this.lastEventAt,
      );
}

/// Адреса push-камеры. Приходят один раз — при создании и после `rotate-key`.
/// Это пароль от чужого видеонаблюдения: не логировать, не отправлять в аналитику.
class PushCredentials {
  PushCredentials({required this.srtUrl, required this.rtspUrl});

  factory PushCredentials.fromJson(Map<String, dynamic> j) =>
      PushCredentials(srtUrl: j['srt_url'] as String? ?? '', rtspUrl: j['rtsp_url'] as String? ?? '');

  final String srtUrl;
  final String rtspUrl;

  @override
  String toString() => 'PushCredentials(***)';
}

/// Ответ `POST /cameras`: камера и, для push, адреса.
class CreatedCamera {
  CreatedCamera(this.camera, this.push);

  factory CreatedCamera.fromJson(Map<String, dynamic> j) => CreatedCamera(
        Camera.fromJson(j),
        j['push'] is Map ? PushCredentials.fromJson(j['push'] as Map<String, dynamic>) : null,
      );

  final Camera camera;
  final PushCredentials? push;
}

/// Результат `POST /cameras/probe`. Всегда 200 — смотрим [ok].
class ProbeResult {
  ProbeResult({required this.ok, this.reason, this.stream, this.warnings = const []});

  factory ProbeResult.fromJson(Map<String, dynamic> j) => ProbeResult(
        ok: j['ok'] as bool? ?? false,
        reason: j['reason'] as String?,
        stream: j['stream'] is Map ? StreamInfo.fromJson(j['stream'] as Map<String, dynamic>) : null,
        warnings: [for (final w in j['warnings'] as List? ?? const []) w as String],
      );

  final bool ok;
  final String? reason;
  final StreamInfo? stream;
  final List<String> warnings;
}

/// Блок OpenVision (edge-агент) на объекте клиента.
class EdgeAgent {
  EdgeAgent({required this.id, required this.name, required this.online, this.lastSeenAt, this.installCommand});

  factory EdgeAgent.fromJson(Map<String, dynamic> j) => EdgeAgent(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        online: j['online'] as bool? ?? false,
        lastSeenAt: _time(j['last_seen_at']),
        installCommand: j['install_command'] as String?,
      );

  final String id;
  final String name;
  final bool online;
  final DateTime? lastSeenAt;

  /// Только в ответе на создание, один раз. Содержит токен агента.
  final String? installCommand;
}

class OvEvent {
  OvEvent({
    required this.id,
    required this.cameraId,
    required this.cameraName,
    required this.kind,
    required this.occurredAt,
    this.personId,
    required this.isKnown,
    this.confidence,
    this.bbox,
    this.cropUrl,
    this.frameUrl,
  });

  factory OvEvent.fromJson(Map<String, dynamic> j) => OvEvent(
        id: j['id'] as String,
        cameraId: (j['camera_id'] as num).toInt(),
        cameraName: j['camera_name'] as String? ?? '',
        kind: j['kind'] as String? ?? '',
        occurredAt: _time(j['occurred_at']) ?? DateTime.now().toUtc(),
        personId: j['person_id'] as String?,
        isKnown: j['is_known'] as bool? ?? false,
        confidence: _double(j['confidence']),
        bbox: j['bbox'] is List && (j['bbox'] as List).length == 4
            ? [for (final v in j['bbox'] as List) (v as num).toDouble()]
            : null,
        cropUrl: j['crop_url'] as String?,
        frameUrl: j['frame_url'] as String?,
      );

  final String id;
  final int cameraId;
  final String cameraName;
  final String kind;
  final DateTime occurredAt;
  final String? personId;
  final bool isKnown;
  final double? confidence;

  /// `[x, y, w, h]` в пикселях исходного кадра.
  final List<double>? bbox;

  /// Подписанные ссылки живут 10 минут. Кэшируем по id события, не по URL.
  final String? cropUrl;
  final String? frameUrl;

  String get cropCacheKey => '${id}_crop';
  String get frameCacheKey => '${id}_frame';
}

class EventsPage {
  EventsPage(this.items, this.nextCursor);

  factory EventsPage.fromJson(Map<String, dynamic> j) => EventsPage(
        [for (final e in j['items'] as List? ?? const []) OvEvent.fromJson(e as Map<String, dynamic>)],
        j['next_cursor'] as String?,
      );

  final List<OvEvent> items;
  final String? nextCursor;
}

class StatsSummary {
  StatsSummary({
    required this.totalEvents,
    required this.knownEvents,
    required this.uniquePeople,
    required this.camerasOnline,
    required this.camerasTotal,
    required this.byHour,
  });

  factory StatsSummary.fromJson(Map<String, dynamic> j) => StatsSummary(
        totalEvents: (j['total_events'] as num?)?.toInt() ?? 0,
        knownEvents: (j['known_events'] as num?)?.toInt() ?? 0,
        uniquePeople: (j['unique_people'] as num?)?.toInt() ?? 0,
        camerasOnline: (j['cameras_online'] as num?)?.toInt() ?? 0,
        camerasTotal: (j['cameras_total'] as num?)?.toInt() ?? 0,
        byHour: {
          for (final h in j['by_hour'] as List? ?? const [])
            if (h is Map) ?_time(h['start']): (h['events'] as num?)?.toInt() ?? 0,
        },
      );

  final int totalEvents;
  final int knownEvents;
  final int uniquePeople;
  final int camerasOnline;
  final int camerasTotal;

  /// Начало часа (UTC) → событий. Пустые часы сервер не присылает.
  final Map<DateTime, int> byHour;

  /// 24 значения по локальным часам суток, начиная с [dayStart]; пропуски — нули.
  List<int> hourlyFrom(DateTime dayStart) {
    final out = List<int>.filled(24, 0);
    byHour.forEach((start, count) {
      final i = start.difference(dayStart.toUtc()).inHours;
      if (i >= 0 && i < 24) out[i] += count;
    });
    return out;
  }
}

/// Фильтры ленты. Курсор при смене фильтров сбрасывается.
class EventQuery {
  const EventQuery({this.cameraIds = const {}, this.known, this.personId, this.since, this.until});

  final Set<int> cameraIds;
  final bool? known;
  final String? personId;
  final DateTime? since;
  final DateTime? until;

  Map<String, dynamic> toQuery() => {
        if (cameraIds.isNotEmpty) 'camera_id': [for (final id in cameraIds) '$id'],
        if (known != null) 'known': '$known',
        'person_id': ?personId,
        if (since != null) 'since': since!.toUtc().toIso8601String(),
        if (until != null) 'until': until!.toUtc().toIso8601String(),
      };

  /// Подходит ли live-событие под фильтры (сервер их к сокету не применяет).
  bool matches(OvEvent e) =>
      (cameraIds.isEmpty || cameraIds.contains(e.cameraId)) &&
      (known == null || e.isKnown == known) &&
      (personId == null || e.personId == personId) &&
      (since == null || !e.occurredAt.isBefore(since!)) &&
      (until == null || e.occurredAt.isBefore(until!));
}
