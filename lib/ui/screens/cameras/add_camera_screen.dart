import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_exception.dart';
import '../../../data/models.dart';
import '../../../data/ov_api.dart';
import '../../../state/cameras_store.dart';
import '../../../theme/ov_theme.dart';
import '../../../theme/ov_tokens.dart';
import '../../strings.dart';
import '../../widgets/chrome.dart';
import '../../widgets/controls.dart';
import '../../widgets/ov_icon.dart';
import '../../widgets/status.dart';
import '../../widgets/wizard.dart';
import '../auth/auth_common.dart' show FormErrorText;
import 'push_addresses.dart';

enum _Mode { edge, push, pull }

enum _Step { mode, pull, pushName, pushAddresses, edgeInstall, edgeCamera }

/// Мастер «Новая камера» (§7): вопрос о подключении → шаг своего режима.
/// Пользователю не называем pull / push / edge — только ситуацию.
class AddCameraScreen extends StatefulWidget {
  const AddCameraScreen({super.key});

  @override
  State<AddCameraScreen> createState() => _AddCameraScreenState();
}

class _AddCameraScreenState extends State<AddCameraScreen> {
  _Step _step = _Step.mode;
  _Mode? _mode;
  bool _busy = false;
  String? _formError;
  Map<String, String> _fieldErrors = {};

  // Pull
  final _pullName = TextEditingController();
  final _pullLocation = TextEditingController();
  final _pullUrl = TextEditingController();
  ProbeResult? _probe;
  bool _probing = false;
  int _probeGen = 0;

  // Push
  final _pushName = TextEditingController();
  final _pushLocation = TextEditingController();
  Camera? _pushCamera;
  PushCredentials? _push;

  // Edge
  List<EdgeAgent>? _agents;
  String? _agentId;
  final _agentName = TextEditingController();
  EdgeAgent? _newAgent;
  bool _newAgentOnline = false;
  Timer? _poll;
  final _edgeName = TextEditingController();
  final _edgeUrl = TextEditingController();

  OvApi get _api => context.read<OvApi>();

  @override
  void dispose() {
    _poll?.cancel();
    for (final c in [_pullName, _pullLocation, _pullUrl, _pushName, _pushLocation, _agentName, _edgeName, _edgeUrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _go(_Step step) {
    FocusScope.of(context).unfocus();
    setState(() {
      _step = step;
      _formError = null;
      _fieldErrors = {};
    });
    if (step == _Step.edgeInstall && _newAgent != null && !_newAgentOnline) _startPolling();
    if (step != _Step.edgeInstall) _poll?.cancel();
  }

  /// Куда ведёт «Назад»; null — закрыть мастер.
  _Step? get _prev => switch (_step) {
        _Step.mode => null,
        _Step.pull || _Step.pushName || _Step.edgeCamera => _Step.mode,
        _Step.pushAddresses => null, // камера уже создана, назад к форме нельзя
        _Step.edgeInstall => (_agents?.isNotEmpty ?? false) || _newAgent != null ? _Step.edgeCamera : _Step.mode,
      };

  void _back() {
    if (_step == _Step.pull && (_probe?.ok ?? false)) {
      setState(() => _probe = null); // из результата проверки — обратно к адресу
      return;
    }
    final prev = _prev;
    if (prev == null) {
      context.pop();
    } else {
      if (prev == _Step.edgeCamera) _loadAgents();
      _go(prev);
    }
  }

  int get _stepIndex => switch (_step) {
        _Step.mode => 1,
        _Step.pull || _Step.pushName || _Step.edgeInstall => 2,
        _Step.pushAddresses || _Step.edgeCamera => 3,
      };

  void _handleError(ApiException e, Map<String, String> fieldText) {
    final l = context.l10n;
    setState(() {
      if (e.invalidFields.isNotEmpty && e.invalidFields.any(fieldText.containsKey)) {
        _fieldErrors = {for (final f in e.invalidFields) if (fieldText[f] != null) f: fieldText[f]!};
      } else {
        _formError = errorText(l, e);
      }
    });
  }

  // ---- Шаг 1: режим ----

  Future<void> _next() async {
    switch (_mode) {
      case _Mode.pull:
        _go(_Step.pull);
      case _Mode.push:
        _go(_Step.pushName);
      case _Mode.edge:
        setState(() => _busy = true);
        await _loadAgents();
        if (!mounted) return;
        setState(() => _busy = false);
        if (_agents == null) return; // ошибка уже показана
        _go(_agents!.isEmpty ? _Step.edgeInstall : _Step.edgeCamera);
      case null:
        break;
    }
  }

  Future<void> _loadAgents() async {
    try {
      final agents = await _api.edgeAgents();
      if (!mounted) return;
      setState(() {
        _agents = agents;
        // Выбранный блок мог исчезнуть — тогда первый на связи, иначе первый в списке.
        if (!agents.any((a) => a.id == _agentId)) {
          _agentId = agents.where((a) => a.online).firstOrNull?.id ?? agents.firstOrNull?.id;
        }
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _formError = errorText(context.l10n, e));
    }
  }

  // ---- Pull ----

  bool _validatePull() {
    final l = context.l10n;
    final url = _pullUrl.text.trim();
    setState(() {
      _fieldErrors = {
        if (_pullName.text.trim().isEmpty) 'name': l.errFieldRequired,
        if (!url.toLowerCase().startsWith('rtsp://')) 'source_url': l.errRtspInvalid,
      };
      _formError = null;
    });
    return _fieldErrors.isEmpty;
  }

  Future<void> _runProbe() async {
    final l = context.l10n;
    final url = _pullUrl.text.trim();
    if (!url.toLowerCase().startsWith('rtsp://')) {
      setState(() => _fieldErrors = {'source_url': l.errRtspInvalid});
      return;
    }
    FocusScope.of(context).unfocus();
    // Локальный адрес сервер всё равно откажет — сразу предлагаем блок.
    if (isPrivateStreamUrl(url)) {
      setState(() => _probe = ProbeResult(ok: false, reason: 'private_address_refused'));
      return;
    }
    final gen = ++_probeGen;
    setState(() {
      _probing = true;
      _probe = null;
      _fieldErrors = {};
      _formError = null;
    });
    try {
      final r = await _api.probe(url);
      if (mounted && gen == _probeGen) setState(() => _probe = r);
    } on ApiException catch (e) {
      if (mounted && gen == _probeGen) setState(() => _formError = errorText(l, e));
    } finally {
      if (mounted && gen == _probeGen) setState(() => _probing = false);
    }
  }

  Future<void> _savePull() async {
    if (!_validatePull()) {
      setState(() => _probe = null);
      return;
    }
    final l = context.l10n;
    setState(() => _busy = true);
    try {
      final created = await _api.createCamera(
        name: _pullName.text.trim(),
        mode: 'pull',
        location: _pullLocation.text.trim().isEmpty ? null : _pullLocation.text.trim(),
        sourceUrl: _pullUrl.text.trim(),
      );
      _finishWith(created.camera);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.code == 'probe_failed') {
        final reason = (e.details is Map ? (e.details as Map)['reason'] : null) as String?;
        setState(() => _probe = ProbeResult(ok: false, reason: reason ?? 'source_unreachable'));
      } else {
        _handleError(e, {'name': l.errFieldRequired, 'source_url': l.errRtspInvalid});
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _switchToEdge() {
    // Адрес локальной сети переносим в форму блока — заново не вводить.
    _edgeUrl.text = _pullUrl.text;
    _edgeName.text = _pullName.text;
    _mode = _Mode.edge;
    _probe = null;
    _next();
  }

  // ---- Push ----

  Future<void> _createPush() async {
    final l = context.l10n;
    if (_pushName.text.trim().isEmpty) {
      setState(() => _fieldErrors = {'name': l.errFieldRequired});
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      final created = await _api.createCamera(
        name: _pushName.text.trim(),
        mode: 'push',
        location: _pushLocation.text.trim().isEmpty ? null : _pushLocation.text.trim(),
      );
      if (!mounted) return;
      context.read<CamerasStore>().put(created.camera);
      _pushCamera = created.camera;
      _push = created.push;
      _go(_Step.pushAddresses);
    } on ApiException catch (e) {
      if (mounted) _handleError(e, {'name': l.errFieldRequired});
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ---- Edge ----

  Future<void> _createAgent() async {
    final l = context.l10n;
    if (_agentName.text.trim().isEmpty) {
      setState(() => _fieldErrors = {'name': l.errFieldRequired});
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      final agent = await _api.createEdgeAgent(_agentName.text.trim());
      if (!mounted) return;
      setState(() {
        _newAgent = agent;
        _newAgentOnline = agent.online;
        _agentId = agent.id;
        _fieldErrors = {};
      });
      if (!agent.online) _startPolling();
    } on ApiException catch (e) {
      if (mounted) _handleError(e, {'name': l.errFieldRequired});
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// `online` становится true примерно через 30 с после запуска блока.
  void _startPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 5), (_) async {
      final id = _newAgent?.id;
      if (id == null) return;
      try {
        final agents = await _api.edgeAgents();
        if (!mounted) return;
        final online = agents.any((a) => a.id == id && a.online);
        setState(() {
          _agents = agents;
          _newAgentOnline = online;
        });
        if (online) _poll?.cancel();
      } on ApiException catch (_) {}
    });
  }

  void _installNewAgent() {
    _agentName.clear();
    _newAgent = null;
    _newAgentOnline = false;
    _go(_Step.edgeInstall);
  }

  Future<void> _saveEdge() async {
    final l = context.l10n;
    final url = _edgeUrl.text.trim();
    setState(() {
      _fieldErrors = {
        if (_edgeName.text.trim().isEmpty) 'name': l.errFieldRequired,
        if (!url.toLowerCase().startsWith('rtsp://')) 'source_url': l.errRtspInvalid,
      };
      _formError = _agentId == null ? l.edgePickTitle : null;
    });
    if (_fieldErrors.isNotEmpty || _agentId == null) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      final created = await _api.createCamera(name: _edgeName.text.trim(), mode: 'edge', edgeAgentId: _agentId, sourceUrl: url);
      _finishWith(created.camera);
    } on ApiException catch (e) {
      if (mounted) _handleError(e, {'name': l.errFieldRequired, 'source_url': l.errRtspInvalid});
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Камера сохранена — открываем её экран: статус дальше обновится по сокету.
  void _finishWith(Camera camera) {
    if (!mounted) return;
    context.read<CamerasStore>().put(camera);
    context.pushReplacement('/cameras/${camera.id}');
  }

  // ---- Построение ----

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final title = _step == _Step.pushAddresses ? (_pushCamera?.name ?? l.addCameraTitle) : l.addCameraTitle;

    return PopScope(
      canPop: _prev == null && !(_step == _Step.pull && (_probe?.ok ?? false)),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              OvAppBar(title: title, back: true),
              OvSteps(current: _stepIndex),
              Expanded(child: _body()),
              _bottom(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scroll(List<Widget> children) => ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(OvSpace.space4, OvSpace.space5, OvSpace.space4, OvSpace.space6),
        children: [
          for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(height: 14), children[i]],
          if (_formError != null) ...[const SizedBox(height: 14), FormErrorText(_formError!)],
        ],
      );

  Widget _body() {
    final l = context.l10n;
    switch (_step) {
      case _Step.mode:
        return _scroll([
          OvStepHeading(title: l.modeQuestion, text: l.modeHint),
          Semantics(
            explicitChildNodes: true,
            child: Column(
              children: [
                ModeOption(
                  icon: OvIcons.box,
                  title: l.modeEdgeTitle,
                  description: l.modeEdgeText,
                  tag: l.modeEdgeTag,
                  selected: _mode == _Mode.edge,
                  onTap: () => setState(() => _mode = _Mode.edge),
                ),
                const SizedBox(height: OvSpace.space3),
                ModeOption(
                  icon: OvIcons.send,
                  title: l.modePushTitle,
                  description: l.modePushText,
                  selected: _mode == _Mode.push,
                  onTap: () => setState(() => _mode = _Mode.push),
                ),
                const SizedBox(height: OvSpace.space3),
                ModeOption(
                  icon: OvIcons.link,
                  title: l.modePullTitle,
                  description: l.modePullText,
                  selected: _mode == _Mode.pull,
                  onTap: () => setState(() => _mode = _Mode.pull),
                ),
              ],
            ),
          ),
        ]);

      case _Step.pull:
        final probe = _probe;
        if (probe != null && probe.ok) {
          return _scroll([
            OvStepHeading(title: l.probeOkTitle),
            SuccessBox(title: l.probeOkHeading, text: streamText(l, probe.stream)),
            for (final w in probe.warnings)
              if (w == 'low_fps') WarnNote(l.warnLowFps) else if (w == 'low_resolution') WarnNote(l.warnLowResolution),
          ]);
        }
        return _scroll([
          OvStepHeading(title: l.pullTitle, text: l.pullText),
          OvTextField(
            label: l.fieldName,
            controller: _pullName,
            error: _fieldErrors['name'],
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
          ),
          OvTextField(
            label: l.fieldLocationOptional,
            controller: _pullLocation,
            placeholder: l.locationPlaceholder,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
          ),
          OvTextField(
            label: l.fieldRtsp,
            controller: _pullUrl,
            mono: true,
            placeholder: 'rtsp://',
            error: _fieldErrors['source_url'],
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            onChanged: (_) {
              if (_probe != null) setState(() => _probe = null);
            },
            onSubmitted: (_) => _runProbe(),
          ),
          if (_probing) WaitingBox(title: l.probeConnecting),
          if (probe != null && !probe.ok)
            StatusReason(
              probe.reason ?? 'source_unreachable',
              action: probe.reason == 'private_address_refused'
                  ? OvButton(
                      label: l.probeUseEdge,
                      icon: OvIcons.box,
                      small: true,
                      variant: OvButtonVariant.secondary,
                      onPressed: _switchToEdge,
                    )
                  : null,
            ),
        ]);

      case _Step.pushName:
        return _scroll([
          OvStepHeading(title: l.pushNameTitle, text: l.pushNameText),
          OvTextField(
            label: l.fieldCameraName,
            controller: _pushName,
            error: _fieldErrors['name'],
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
          ),
          OvTextField(
            label: l.fieldLocationOptional,
            controller: _pushLocation,
            placeholder: l.locationPlaceholder,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => _createPush(),
          ),
        ]);

      case _Step.pushAddresses:
        return PushAddressesBody(cameraId: _pushCamera!.id, push: _push!);

      case _Step.edgeInstall:
        final agent = _newAgent;
        return _scroll([
          OvStepHeading(title: l.edgeInstallTitle, text: l.edgeInstallText),
          OvTextField(
            label: l.fieldAgentName,
            controller: _agentName,
            placeholder: l.agentNamePlaceholder,
            error: _fieldErrors['name'],
            enabled: agent == null,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _createAgent(),
          ),
          if (agent?.installCommand != null)
            CopyField(label: l.edgeCommandLabel, value: agent!.installCommand!, hint: l.edgeTokenOnce),
          if (agent != null)
            _newAgentOnline
                ? SuccessBox(title: l.edgeOnlineTitle, text: l.edgeOnlineText)
                : WaitingBox(title: l.edgeWaitingTitle, text: l.edgeWaitingText),
        ]);

      case _Step.edgeCamera:
        return _EdgeCameraForm(
          agents: _agents ?? const [],
          selectedId: _agentId,
          onSelect: (id) => setState(() => _agentId = id),
          onInstallNew: _installNewAgent,
          name: _edgeName,
          url: _edgeUrl,
          errors: _fieldErrors,
          formError: _formError,
        );
    }
  }

  Widget _bottom() {
    final l = context.l10n;
    switch (_step) {
      case _Step.mode:
        return OvBottomBar(children: [
          Expanded(child: OvButton(label: l.next, block: true, loading: _busy, onPressed: _mode == null ? null : _next)),
        ]);
      case _Step.pull:
        if (_probe?.ok ?? false) {
          return OvBottomBar(children: [
            Expanded(child: OvButton(label: l.saveCamera, block: true, loading: _busy, onPressed: _savePull)),
          ]);
        }
        return OvBottomBar(children: [
          Expanded(
            child: OvButton(
              label: _probing ? l.probing : l.probeButton,
              variant: OvButtonVariant.secondary,
              block: true,
              loading: _probing,
              onPressed: _busy ? null : _runProbe,
            ),
          ),
          Expanded(
            // Проверка рекомендуется, но не обязательна: сервер проверит адрес при сохранении.
            child: OvButton(label: l.save, block: true, loading: _busy, onPressed: _probing ? null : _savePull),
          ),
        ]);
      case _Step.pushName:
        return OvBottomBar(children: [
          Expanded(child: OvButton(label: l.pushGetAddress, block: true, loading: _busy, onPressed: _createPush)),
        ]);
      case _Step.pushAddresses:
        return PushAddressesBar(cameraName: _pushCamera!.name, push: _push!, onDone: () => context.pop());
      case _Step.edgeInstall:
        final agent = _newAgent;
        if (agent == null) {
          return OvBottomBar(children: [
            Expanded(child: OvButton(label: l.edgeGetCommand, block: true, loading: _busy, onPressed: _createAgent)),
          ]);
        }
        return OvBottomBar(children: [
          if (agent.installCommand != null)
            Builder(
              builder: (context) => OvButton(
                label: l.edgeShareIt,
                icon: OvIcons.share,
                variant: OvButtonVariant.secondary,
                onPressed: () => shareText(context, text: agent.installCommand!, subject: l.edgeShareSubject(agent.name)),
              ),
            ),
          Expanded(
            child: OvButton(
              label: l.next,
              block: true,
              onPressed: _newAgentOnline
                  ? () {
                      _loadAgents();
                      _go(_Step.edgeCamera);
                    }
                  : null,
            ),
          ),
        ]);
      case _Step.edgeCamera:
        return OvBottomBar(children: [
          Expanded(child: OvButton(label: l.saveCamera, block: true, loading: _busy, onPressed: _saveEdge)),
        ]);
    }
  }
}

/// Экран 14 · Какой блок читает камеру + название и локальный адрес.
class _EdgeCameraForm extends StatelessWidget {
  const _EdgeCameraForm({
    required this.agents,
    required this.selectedId,
    required this.onSelect,
    required this.onInstallNew,
    required this.name,
    required this.url,
    required this.errors,
    required this.formError,
  });

  final List<EdgeAgent> agents;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onInstallNew;
  final TextEditingController name;
  final TextEditingController url;
  final Map<String, String> errors;
  final String? formError;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ov = context.ov;
    final fmt = OvFormat(context);
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: OvSpace.space6),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(OvSpace.space4, OvSpace.space5, OvSpace.space4, OvSpace.space2),
          child: OvStepHeading(title: l.edgePickTitle),
        ),
        OvList(children: [
          for (final a in agents)
            Semantics(
              inMutuallyExclusiveGroup: true,
              checked: a.id == selectedId,
              child: InkWell(
                onTap: () => onSelect(a.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: OvSpace.space4, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: ov.surfaceSunken, borderRadius: BorderRadius.circular(OvRadius.radiusSm)),
                        child: OvIcon(OvIcons.box, color: ov.ink),
                      ),
                      const SizedBox(width: OvSpace.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.name, style: OvText.bodyStrong.copyWith(color: ov.ink)),
                            const SizedBox(height: 4),
                            a.online
                                ? const StatusBadge('online')
                                : StatusBadge(
                                    'offline',
                                    text: a.lastSeenAt != null ? l.agentOfflineSince(fmt.ago(a.lastSeenAt!)) : null,
                                  ),
                          ],
                        ),
                      ),
                      OvRadio(selected: a.id == selectedId),
                    ],
                  ),
                ),
              ),
            ),
          OvActionRow(icon: OvIcons.plus, label: l.edgeInstallNew, brand: true, onTap: onInstallNew),
        ]),
        Padding(
          padding: const EdgeInsets.fromLTRB(OvSpace.space4, OvSpace.space4, OvSpace.space4, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OvTextField(
                label: l.fieldCameraName,
                controller: name,
                error: errors['name'],
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 14),
              OvTextField(
                label: l.fieldLocalUrl,
                controller: url,
                mono: true,
                placeholder: 'rtsp://',
                error: errors['source_url'],
                hint: l.localUrlHint,
                keyboardType: TextInputType.url,
              ),
              if (formError != null) ...[const SizedBox(height: 14), FormErrorText(formError!)],
            ],
          ),
        ),
      ],
    );
  }
}
