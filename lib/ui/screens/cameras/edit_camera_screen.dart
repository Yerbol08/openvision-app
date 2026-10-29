import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/api/api_exception.dart';
import '../../../data/ov_api.dart';
import '../../../state/cameras_store.dart';
import '../../../theme/ov_tokens.dart';
import '../../strings.dart';
import '../../widgets/chrome.dart';
import '../../widgets/controls.dart';
import '../../widgets/status.dart';
import '../../widgets/wizard.dart';
import '../auth/auth_common.dart' show FormErrorText;

/// «Название и адрес» (`PATCH /cameras/{id}`). Новый адрес сервер проверяет
/// так же, как при добавлении (до ~12 с), и может отказать с `probe_failed`.
class EditCameraScreen extends StatefulWidget {
  const EditCameraScreen({super.key, required this.cameraId});
  final int cameraId;

  @override
  State<EditCameraScreen> createState() => _EditCameraScreenState();
}

class _EditCameraScreenState extends State<EditCameraScreen> {
  final _name = TextEditingController();
  final _location = TextEditingController();
  final _url = TextEditingController();
  bool _saving = false;
  Map<String, String> _errors = {};
  String? _formError;
  String? _probeReason;

  @override
  void initState() {
    super.initState();
    final c = context.read<CamerasStore>().byId(widget.cameraId);
    _name.text = c?.name ?? '';
    _location.text = c?.location ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _url.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = context.l10n;
    final store = context.read<CamerasStore>();
    final camera = store.byId(widget.cameraId);
    if (camera == null) return;
    final name = _name.text.trim(), location = _location.text.trim(), url = _url.text.trim();
    setState(() {
      _errors = {
        if (name.isEmpty) 'name': l.errFieldRequired,
        if (url.isNotEmpty && !url.toLowerCase().startsWith('rtsp://')) 'source_url': l.errRtspInvalid,
      };
      _formError = null;
      _probeReason = null;
    });
    if (_errors.isNotEmpty) return;
    if (url.isNotEmpty && camera.mode == 'pull' && isPrivateStreamUrl(url)) {
      setState(() => _probeReason = 'private_address_refused');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      final updated = await context.read<OvApi>().updateCamera(
            camera.id,
            name: name != camera.name ? name : null,
            location: location != (camera.location ?? '') ? location : null,
            sourceUrl: url.isNotEmpty ? url : null,
          );
      store.put(updated);
      if (!mounted) return;
      showOvSnack(context, l.saved);
      context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.code == 'probe_failed') {
          final reason = e.details is Map ? (e.details as Map)['reason'] : null;
          _probeReason = reason is String ? reason : 'source_unreachable';
        } else if (e.invalidFields.contains('source_url')) {
          _errors = {'source_url': l.errRtspInvalid};
        } else if (e.invalidFields.contains('name')) {
          _errors = {'name': l.errFieldRequired};
        } else {
          _formError = errorText(l, e);
        }
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final camera = context.watch<CamerasStore>().byId(widget.cameraId);
    // У push-камеры адреса нет: видео отправляет регистратор.
    final hasUrl = camera != null && camera.mode != 'push';
    final checkingUrl = _saving && _url.text.trim().isNotEmpty && camera?.mode == 'pull';

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            OvAppBar(title: l.cameraEdit, back: true),
            Expanded(
              child: ListView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(OvSpace.space4, OvSpace.space2, OvSpace.space4, OvSpace.space6),
                children: [
                  OvTextField(
                    label: l.fieldName,
                    controller: _name,
                    error: _errors['name'],
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 14),
                  OvTextField(
                    label: l.fieldLocationOptional,
                    controller: _location,
                    placeholder: l.locationPlaceholder,
                    textInputAction: hasUrl ? TextInputAction.next : TextInputAction.done,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  if (hasUrl) ...[
                    const SizedBox(height: 14),
                    OvTextField(
                      label: l.fieldNewUrl,
                      controller: _url,
                      mono: true,
                      placeholder: 'rtsp://',
                      error: _errors['source_url'],
                      hint: camera.sourceUrl != null ? l.newUrlHint(camera.sourceUrl!) : null,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _save(),
                    ),
                  ],
                  if (checkingUrl) ...[const SizedBox(height: 14), WaitingBox(title: l.probeConnecting)],
                  if (_probeReason != null) ...[const SizedBox(height: 14), StatusReason(_probeReason!)],
                  if (_formError != null) ...[const SizedBox(height: 14), FormErrorText(_formError!)],
                ],
              ),
            ),
            OvBottomBar(children: [
              Expanded(child: OvButton(label: l.save, block: true, loading: _saving, onPressed: camera == null ? null : _save)),
            ]),
          ],
        ),
      ),
    );
  }
}
