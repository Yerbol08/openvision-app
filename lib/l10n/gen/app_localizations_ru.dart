// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'OpenVision';

  @override
  String get retry => 'Повторить';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get back => 'Назад';

  @override
  String get close => 'Закрыть';

  @override
  String get errGeneric => 'Что-то пошло не так. Повторите попытку.';

  @override
  String get errNetwork => 'Нет связи с сервером. Проверьте интернет.';

  @override
  String get errForbidden => 'Для этого действия нет прав.';

  @override
  String get errNotFound => 'Не найдено. Возможно, это уже удалили.';

  @override
  String get errInvalidCredentials => 'Неверная почта или пароль';

  @override
  String errRateLimited(int seconds) {
    return 'Слишком много попыток. Повторите через $seconds с.';
  }

  @override
  String get errAccountSuspended =>
      'Аккаунт заблокирован. Обратитесь в поддержку.';

  @override
  String get errEmailTaken => 'Аккаунт с этой почтой уже есть';

  @override
  String get errFieldRequired => 'Заполните поле';

  @override
  String get errEmailInvalid => 'Проверьте адрес почты';

  @override
  String get errPasswordShort => 'Не меньше 10 символов';

  @override
  String get errPasswordLong => 'Не больше 128 символов';

  @override
  String get errFieldInvalid => 'Проверьте значение';

  @override
  String get sessionExpired => 'Сессия завершена. Войдите снова.';

  @override
  String get splashOffline => 'Не удалось связаться с сервером.';

  @override
  String get loginTitle => 'Вход';

  @override
  String get loginSubtitle => 'Камеры и события вашей компании';

  @override
  String get fieldEmail => 'Эл. почта';

  @override
  String get fieldPassword => 'Пароль';

  @override
  String get showPassword => 'Показать пароль';

  @override
  String get hidePassword => 'Скрыть пароль';

  @override
  String get loginButton => 'Войти';

  @override
  String get loginNoAccount => 'Нет аккаунта?';

  @override
  String get loginRegisterLink => 'Зарегистрировать компанию';

  @override
  String get registerTitle => 'Новая компания';

  @override
  String get registerSubtitle =>
      'Вы станете владельцем аккаунта и сможете пригласить коллег.';

  @override
  String get fieldCompany => 'Название компании';

  @override
  String get fieldFullName => 'Ваше имя';

  @override
  String get passwordHint => 'Не меньше 10 символов';

  @override
  String get registerButton => 'Создать аккаунт';

  @override
  String get registerHaveAccount => 'Уже есть аккаунт?';

  @override
  String get registerLoginLink => 'Войти';

  @override
  String get tabOverview => 'Обзор';

  @override
  String get tabCameras => 'Камеры';

  @override
  String get tabEvents => 'События';

  @override
  String get tabTeam => 'Команда';

  @override
  String tabBadgeA11y(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count камер не работают',
      few: '$count камеры не работают',
      one: '$count камера не работает',
    );
    return '$_temp0';
  }

  @override
  String overviewSubtitle(String date, String company) {
    return 'Сегодня, $date · $company';
  }

  @override
  String get statEvents => 'События';

  @override
  String get statCamerasOnline => 'Камеры в сети';

  @override
  String statCamerasOffline(int count) {
    return '$count не в сети';
  }

  @override
  String get statUniquePeople => 'Уникальных людей';

  @override
  String get statKnown => 'Известные';

  @override
  String statKnownShare(int percent) {
    return '$percent% событий';
  }

  @override
  String get chartTitle => 'События по часам';

  @override
  String chartPeak(String hour, int count) {
    return 'пик $hour — $count';
  }

  @override
  String chartA11y(int count, String hour) {
    return 'Событий по часам, максимум $count в $hour';
  }

  @override
  String get attentionTitle => 'Требуют внимания';

  @override
  String get attentionNone => 'Все камеры работают';

  @override
  String get accountA11y => 'Аккаунт';

  @override
  String camerasPlanUsage(int count, int max) {
    return '$count из $max по тарифу';
  }

  @override
  String get camerasEmpty =>
      'Пока нет камер. Здесь будут ваши камеры и их состояние.';

  @override
  String cameraLastEvent(String time) {
    return 'событие $time';
  }

  @override
  String get cameraEnabledA11y => 'Камера включена';

  @override
  String get cameraToggleFailed =>
      'Не удалось переключить камеру. Попробуйте ещё раз.';

  @override
  String get statusPending => 'Настройка';

  @override
  String get statusConnecting => 'Подключение';

  @override
  String get statusOnline => 'В сети';

  @override
  String get statusOffline => 'Не в сети';

  @override
  String get statusError => 'Ошибка';

  @override
  String get statusDisabled => 'Выключена';

  @override
  String get statusUnknown => 'Неизвестно';

  @override
  String get reasonWaitingForVideoTitle => 'Ждём видео';

  @override
  String get reasonWaitingForVideoText =>
      'Проверьте, что регистратор отправляет поток на адрес, который мы выдали.';

  @override
  String get reasonEdgeAgentOfflineTitle => 'Блок OpenVision не в сети';

  @override
  String get reasonEdgeAgentOfflineText =>
      'Проверьте, что блок на объекте включён и подключён к интернету.';

  @override
  String get reasonNoVideoTitle => 'Видео не поступает';

  @override
  String get reasonNoVideoText => 'Проверьте питание и сеть камеры.';

  @override
  String get reasonWaitingForGpuTitle => 'Ожидание мощностей анализа';

  @override
  String get reasonWaitingForGpuText =>
      'Видео в порядке, анализ скоро начнётся. Ничего делать не нужно.';

  @override
  String get reasonSourceUnreachableTitle => 'Камера недоступна';

  @override
  String get reasonSourceUnreachableText =>
      'Проверьте адрес и что камера доступна из интернета.';

  @override
  String get reasonSourceAuthFailedTitle => 'Неверный логин или пароль';

  @override
  String get reasonSourceAuthFailedText =>
      'Камера отклонила имя пользователя или пароль.';

  @override
  String get reasonSourceNotFoundTitle => 'Поток не найден';

  @override
  String get reasonSourceNotFoundText =>
      'По этому пути у камеры нет потока. Проверьте URL.';

  @override
  String get reasonUnsupportedCodecTitle => 'Неподдерживаемый формат';

  @override
  String get reasonUnsupportedCodecText =>
      'Нужен H.264 или H.265. Смените кодек в настройках камеры.';

  @override
  String get reasonNoVideoTrackTitle => 'В потоке нет видео';

  @override
  String get reasonNoVideoTrackText =>
      'Поток подключился, но видеодорожки в нём нет.';

  @override
  String get reasonPrivateAddressTitle => 'Это адрес локальной сети';

  @override
  String get reasonPrivateAddressText =>
      'Из облака его не видно. Подключите камеру через блок OpenVision.';

  @override
  String get reasonIngestErrorTitle => 'Сбой на нашей стороне';

  @override
  String get reasonIngestErrorText =>
      'Мы уже получили уведомление и разбираемся.';

  @override
  String get reasonUnknownTitle => 'Камера не работает';

  @override
  String get reasonUnknownText => 'Обратитесь в поддержку.';

  @override
  String reasonLastSeen(String time) {
    return 'Последний сигнал $time';
  }

  @override
  String get timeJustNow => 'только что';

  @override
  String timeMinutesAgo(int n) {
    return '$n мин назад';
  }

  @override
  String timeHoursAgo(int n) {
    return '$n ч назад';
  }

  @override
  String timeDaysAgo(int n) {
    return '$n дн. назад';
  }

  @override
  String cameraLastFrame(String time) {
    return 'последний кадр · $time';
  }

  @override
  String get cameraEnabled => 'Включена';

  @override
  String get cameraLocation => 'Место';

  @override
  String get cameraConnection => 'Подключение';

  @override
  String get connectionPull => 'Адрес в интернете';

  @override
  String get connectionPush => 'Регистратор отправляет поток';

  @override
  String get connectionEdge => 'Через блок OpenVision';

  @override
  String get cameraVideo => 'Видео';

  @override
  String cameraVideoValue(int width, int height, int fps, String codec) {
    return '$width×$height · $fps fps · $codec';
  }

  @override
  String get cameraEvents => 'События этой камеры';

  @override
  String get cameraDelete => 'Удалить камеру';

  @override
  String cameraDeleteTitle(String name) {
    return 'Удалить камеру «$name»?';
  }

  @override
  String get cameraDeleteText =>
      'Камера и её события будут удалены. Это нельзя отменить.';

  @override
  String get cameraDeleted => 'Камера удалена';

  @override
  String get eventsTitle => 'События';

  @override
  String get filtersA11y => 'Фильтры';

  @override
  String get connLive => 'Онлайн — события приходят сразу';

  @override
  String get connReconnecting => 'Переподключаемся…';

  @override
  String get connOffline => 'Нет интернета. Показаны сохранённые данные';

  @override
  String get filterTitle => 'Фильтры';

  @override
  String get filterReset => 'Сбросить';

  @override
  String get filterPeriod => 'Период';

  @override
  String get periodAny => 'Всё время';

  @override
  String get periodToday => 'Сегодня';

  @override
  String get periodYesterday => 'Вчера';

  @override
  String get period7d => '7 дней';

  @override
  String get periodDates => 'Даты';

  @override
  String get filterPeople => 'Люди';

  @override
  String get peopleAll => 'Все';

  @override
  String get peopleKnown => 'Известные';

  @override
  String get peopleUnknown => 'Неизвестные';

  @override
  String get filterCameras => 'Камеры';

  @override
  String get camerasAll => 'Все камеры';

  @override
  String camerasSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count камер',
      few: '$count камеры',
      one: '$count камера',
    );
    return '$_temp0';
  }

  @override
  String get filterShow => 'Показать события';

  @override
  String get filterPerson => 'Этот человек';

  @override
  String get filterPersonClear => 'Убрать фильтр по человеку';

  @override
  String get eventKnown => 'Известный человек';

  @override
  String get eventUnknown => 'Неизвестный';

  @override
  String get eventTagNew => 'Новый';

  @override
  String get eventTagKnown => 'Известный';

  @override
  String get eventNewA11y => 'Новое';

  @override
  String get dayToday => 'Сегодня';

  @override
  String get dayYesterday => 'Вчера';

  @override
  String get eventsEmpty =>
      'Событий пока нет. Здесь появятся люди, которых увидят камеры.';

  @override
  String get eventsEmptyFiltered => 'Нет событий по этим фильтрам.';

  @override
  String eventsNewPill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count новых событий',
      few: '$count новых события',
      one: '$count новое событие',
    );
    return '$_temp0';
  }

  @override
  String get eventsLoadMoreFailed => 'Не удалось загрузить.';

  @override
  String get eventTitleKnown => 'Известный';

  @override
  String get eventTitleUnknown => 'Неизвестный';

  @override
  String get eventPersonUnknown => 'Неизвестный человек';

  @override
  String eventSeenToday(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count раз',
      few: '$count раза',
      one: '$count раз',
    );
    return 'Сегодня $_temp0 · первый раз в $time';
  }

  @override
  String get eventCamera => 'Камера';

  @override
  String get eventTime => 'Время';

  @override
  String get eventKind => 'Тип';

  @override
  String get kindFace => 'Лицо';

  @override
  String get kindOther => 'Событие';

  @override
  String get eventAllAppearances => 'Все появления этого человека';

  @override
  String get frameA11y => 'Кадр события';

  @override
  String get cropA11y => 'Лицо';

  @override
  String get teamTitle => 'Команда';

  @override
  String teamMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count участников',
      few: '$count участника',
      one: '$count участник',
    );
    return '$_temp0';
  }

  @override
  String get roleOwner => 'Владелец';

  @override
  String get roleAdmin => 'Администратор';

  @override
  String get roleOperator => 'Оператор';

  @override
  String get roleViewer => 'Наблюдатель';

  @override
  String get memberYou => '(вы)';

  @override
  String memberInactive(String email) {
    return 'Отключён · $email';
  }

  @override
  String get accountSection => 'Аккаунт';

  @override
  String get accountPlan => 'Тариф';

  @override
  String accountPlanValue(String plan, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count камер',
      few: '$count камеры',
      one: '$count камера',
    );
    return '$plan · $_temp0';
  }

  @override
  String get accountRetention => 'Хранение событий';

  @override
  String accountRetentionValue(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days дней',
      few: '$days дня',
      one: '$days день',
    );
    return '$_temp0';
  }

  @override
  String get signOut => 'Выйти';

  @override
  String get next => 'Далее';

  @override
  String get done => 'Готово';

  @override
  String get save => 'Сохранить';

  @override
  String get share => 'Отправить';

  @override
  String get copy => 'Копировать';

  @override
  String get copied => 'Скопировано';

  @override
  String get saved => 'Сохранено';

  @override
  String get addCameraA11y => 'Добавить камеру';

  @override
  String get fabCamera => 'Камера';

  @override
  String get addCameraTitle => 'Новая камера';

  @override
  String errCameraLimit(int limit) {
    String _temp0 = intl.Intl.pluralLogic(
      limit,
      locale: localeName,
      other: 'Ваш тариф позволяет $limit камер',
      few: 'Ваш тариф позволяет $limit камеры',
      one: 'Ваш тариф позволяет $limit камеру',
    );
    return '$_temp0';
  }

  @override
  String get errOwnerProtected => 'Владельца нельзя изменить или удалить.';

  @override
  String get errSelfProtected => 'Нельзя менять свою роль или удалять себя.';

  @override
  String get errWrongPassword => 'Текущий пароль неверный';

  @override
  String get errRtspInvalid => 'Адрес должен начинаться с rtsp://';

  @override
  String get modeQuestion => 'Как камера подключена к интернету?';

  @override
  String get modeHint =>
      'От ответа зависит способ подключения. Если не уверены — выберите первый вариант.';

  @override
  String get modeEdgeTitle => 'Камеры только в нашей сети';

  @override
  String get modeEdgeText => 'Поставим блок OpenVision, он передаст видео.';

  @override
  String get modeEdgeTag => 'Чаще всего';

  @override
  String get modePushTitle => 'Регистратор отправляет поток';

  @override
  String get modePushText => 'Hikvision, Dahua, Milestone — дадим адрес.';

  @override
  String get modePullTitle => 'У камеры есть адрес в интернете';

  @override
  String get modePullText => 'Публичный IP или облачный регистратор.';

  @override
  String get fieldCameraName => 'Название камеры';

  @override
  String get fieldName => 'Название';

  @override
  String get fieldLocationOptional => 'Место (необязательно)';

  @override
  String get locationPlaceholder => 'Например, «Главная дверь»';

  @override
  String get pullTitle => 'Адрес видеопотока';

  @override
  String get pullText =>
      'Найдите RTSP-адрес в настройках камеры или регистратора. Логин и пароль можно указать прямо в адресе.';

  @override
  String get fieldRtsp => 'RTSP-адрес';

  @override
  String get probeButton => 'Проверить подключение';

  @override
  String get probing => 'Проверяем';

  @override
  String get probeConnecting => 'Подключаемся к камере…';

  @override
  String get saveCamera => 'Сохранить камеру';

  @override
  String get probeOkTitle => 'Камера отвечает';

  @override
  String get probeOkHeading => 'Подключение работает';

  @override
  String get warnLowFps =>
      'Меньше 10 кадров в секунду — распознавание будет хуже. Повысьте частоту в настройках камеры, если можно.';

  @override
  String get warnLowResolution =>
      'Разрешение ниже 480p — распознавание будет хуже. Повысьте разрешение в настройках камеры, если можно.';

  @override
  String get probeUseEdge => 'Подключить через блок';

  @override
  String get pushNameTitle => 'Как назвать камеру?';

  @override
  String get pushNameText => 'Название будет в списке камер и в событиях.';

  @override
  String get pushGetAddress => 'Получить адрес';

  @override
  String get pushIntro =>
      'Вставьте адрес в настройки регистратора. Камера станет зелёной, как только пойдёт видео.';

  @override
  String get pushRecommended => 'Рекомендуем';

  @override
  String get pushRtspLabel => 'RTSP — если SRT не поддерживается';

  @override
  String get pushKeyOnce =>
      'Ключ показываем только один раз. Сохраните или отправьте его сейчас.';

  @override
  String get pushOnlineTitle => 'Камера в сети';

  @override
  String get pushOnlineText => 'Видео поступает, анализ начался.';

  @override
  String pushShareSubject(String name) {
    return 'OpenVision: адрес для камеры «$name»';
  }

  @override
  String get edgeInstallTitle => 'Установите блок в вашей сети';

  @override
  String get edgeInstallText =>
      'Обычно это делает IT-специалист: одна команда на компьютере, который видит камеры. Один блок обслуживает все камеры объекта.';

  @override
  String get fieldAgentName => 'Название блока';

  @override
  String get agentNamePlaceholder => 'Например, «Склад — ПК охраны»';

  @override
  String get edgeGetCommand => 'Получить команду';

  @override
  String get edgeCommandLabel => 'Команда установки';

  @override
  String get edgeTokenOnce => 'Токен в команде покажем только один раз.';

  @override
  String get edgeWaitingTitle => 'Ждём, когда блок выйдет на связь';

  @override
  String get edgeWaitingText => 'Обычно до 30 секунд после запуска';

  @override
  String get edgeOnlineTitle => 'Блок на связи';

  @override
  String get edgeOnlineText => 'Теперь выберите его и добавьте камеру.';

  @override
  String get edgeShareIt => 'Отправить IT';

  @override
  String edgeShareSubject(String name) {
    return 'OpenVision: установка блока «$name»';
  }

  @override
  String get edgePickTitle => 'Какой блок читает камеру?';

  @override
  String get edgeInstallNew => 'Установить новый блок';

  @override
  String agentOfflineSince(String time) {
    return 'Не в сети · $time';
  }

  @override
  String get fieldLocalUrl => 'Локальный адрес камеры';

  @override
  String get localUrlHint =>
      'Адрес из локальной сети — его увидит только блок. Проверка появится после подключения.';

  @override
  String get cameraEdit => 'Название и адрес';

  @override
  String get fieldNewUrl => 'Новый адрес (необязательно)';

  @override
  String newUrlHint(String current) {
    return 'Сейчас: $current. Оставьте пустым, чтобы не менять.';
  }

  @override
  String get cameraRotateKey => 'Выдать новый адрес';

  @override
  String get rotateTitle => 'Выдать новый адрес?';

  @override
  String get rotateText =>
      'Старый ключ сразу перестанет работать. Регистратор нужно будет настроить заново.';

  @override
  String get rotateConfirm => 'Выдать';

  @override
  String get teamInviteA11y => 'Пригласить';

  @override
  String get inviteTitle => 'Новый участник';

  @override
  String get fieldPersonName => 'Имя';

  @override
  String get fieldRole => 'Роль';

  @override
  String get roleAdminHint => 'Камеры, команда, журнал';

  @override
  String get roleOperatorHint => 'События, вкл/выкл камер';

  @override
  String get roleViewerHint => 'Только просмотр';

  @override
  String get fieldInitialPassword => 'Начальный пароль';

  @override
  String get initialPasswordHint =>
      'Передайте коллеге сами. Не меньше 10 символов.';

  @override
  String get inviteButton => 'Добавить в команду';

  @override
  String get memberAdded => 'Участник добавлен';

  @override
  String get memberActions => 'Действия';

  @override
  String get memberChangeRole => 'Сменить роль';

  @override
  String get memberDeactivate => 'Отключить доступ';

  @override
  String get memberActivate => 'Включить доступ';

  @override
  String get memberRemove => 'Удалить из команды';

  @override
  String memberRemoveTitle(String name) {
    return 'Удалить $name из команды?';
  }

  @override
  String get memberRemoveText =>
      'Доступ пропадёт сразу. Вернуть можно только новым приглашением.';

  @override
  String get changePassword => 'Сменить пароль';

  @override
  String get fieldCurrentPassword => 'Текущий пароль';

  @override
  String get fieldNewPassword => 'Новый пароль';

  @override
  String get changePasswordText =>
      'На других устройствах после смены нужно будет войти заново.';

  @override
  String get passwordChanged => 'Пароль изменён';
}
