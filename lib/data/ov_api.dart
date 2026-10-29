import '../core/api/api_client.dart';
import '../core/api/token_store.dart';
import 'models.dart';

/// Типизированные вызовы `/api/v1`. Ошибки — [ApiException].
class OvApi {
  OvApi(this.client);

  final ApiClient client;

  // ---- Авторизация (§4) ----

  Future<TokenPair> login({required String email, required String password, String? deviceName}) =>
      client.postPublic('/auth/login', {'email': email, 'password': password, 'device_name': ?deviceName},
          (d) => TokenPair.fromJson(d as Map<String, dynamic>));

  Future<TokenPair> register({
    required String companyName,
    required String fullName,
    required String email,
    required String password,
    String? deviceName,
  }) =>
      client.postPublic(
          '/auth/register',
          {
            'company_name': companyName,
            'full_name': fullName,
            'email': email,
            'password': password,
            'device_name': ?deviceName,
          },
          (d) => TokenPair.fromJson(d as Map<String, dynamic>));

  Future<void> logout(String refreshToken) =>
      client.postPublic('/auth/logout', {'refresh_token': refreshToken}, (_) {});

  Future<Me> me() => client.get('/auth/me', (d) => Me.fromJson(d as Map<String, dynamic>));

  /// Завершает все остальные сессии; сохранённый refresh-токен после этого не работает.
  Future<void> changePassword({required String current, required String next}) =>
      client.put('/auth/me/password', {'current_password': current, 'new_password': next});

  // ---- Камеры (§5) ----

  Future<List<Camera>> cameras() =>
      client.get('/cameras', (d) => [for (final c in d as List) Camera.fromJson(c as Map<String, dynamic>)]);

  Future<Camera> camera(int id) => client.get('/cameras/$id', (d) => Camera.fromJson(d as Map<String, dynamic>));

  Future<Camera> setCameraEnabled(int id, bool enabled) =>
      client.patch('/cameras/$id', {'enabled': enabled}, (d) => Camera.fromJson(d as Map<String, dynamic>));

  Future<void> deleteCamera(int id) => client.delete('/cameras/$id');

  /// До ~12 с. Ничего не сохраняет.
  Future<ProbeResult> probe(String url) =>
      client.post('/cameras/probe', {'url': url}, (d) => ProbeResult.fromJson(d as Map<String, dynamic>));

  Future<CreatedCamera> createCamera({
    required String name,
    required String mode,
    String? location,
    String? sourceUrl,
    String? edgeAgentId,
  }) =>
      client.post(
          '/cameras',
          {
            'name': name,
            'mode': mode,
            'location': ?location,
            'source_url': ?sourceUrl,
            'edge_agent_id': ?edgeAgentId,
          },
          (d) => CreatedCamera.fromJson(d as Map<String, dynamic>));

  /// Любое подмножество name / location / source_url; смена адреса заново проверяет поток.
  Future<Camera> updateCamera(int id, {String? name, String? location, String? sourceUrl}) => client.patch(
      '/cameras/$id',
      {'name': ?name, 'location': ?location, 'source_url': ?sourceUrl},
      (d) => Camera.fromJson(d as Map<String, dynamic>));

  Future<PushCredentials> rotateKey(int id) =>
      client.post('/cameras/$id/rotate-key', null, (d) => PushCredentials.fromJson(d as Map<String, dynamic>));

  // ---- Блоки OpenVision (§7.3) ----

  Future<List<EdgeAgent>> edgeAgents() =>
      client.get('/edge-agents', (d) => [for (final a in d as List) EdgeAgent.fromJson(a as Map<String, dynamic>)]);

  Future<EdgeAgent> createEdgeAgent(String name) =>
      client.post('/edge-agents', {'name': name}, (d) => EdgeAgent.fromJson(d as Map<String, dynamic>));

  // ---- События (§6) ----

  Future<EventsPage> events(EventQuery query, {String? cursor, int limit = 50}) => client.get(
        '/events',
        (d) => EventsPage.fromJson(d as Map<String, dynamic>),
        query: {...query.toQuery(), 'limit': '$limit', 'cursor': ?cursor},
      );

  Future<OvEvent> event(String id) => client.get('/events/$id', (d) => OvEvent.fromJson(d as Map<String, dynamic>));

  Future<StatsSummary> statsSummary({required DateTime since, required DateTime until}) => client.get(
        '/stats/summary',
        (d) => StatsSummary.fromJson(d as Map<String, dynamic>),
        query: {'since': since.toUtc().toIso8601String(), 'until': until.toUtc().toIso8601String()},
      );

  // ---- Команда (§12) ----

  Future<List<User>> users() =>
      client.get('/users', (d) => [for (final u in d as List) User.fromJson(u as Map<String, dynamic>)]);

  Future<User> createUser({required String email, required String fullName, required String role, required String password}) =>
      client.post('/users', {'email': email, 'full_name': fullName, 'role': role, 'password': password},
          (d) => User.fromJson(d as Map<String, dynamic>));

  Future<User> updateUser(String id, {String? role, bool? isActive}) =>
      client.patch('/users/$id', {'role': ?role, 'is_active': ?isActive}, (d) => User.fromJson(d as Map<String, dynamic>));

  Future<void> deleteUser(String id) => client.delete('/users/$id');
}
