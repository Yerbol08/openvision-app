// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get appName => 'OpenVision';

  @override
  String get retry => 'Қайталау';

  @override
  String get cancel => 'Бас тарту';

  @override
  String get delete => 'Жою';

  @override
  String get back => 'Артқа';

  @override
  String get close => 'Жабу';

  @override
  String get errGeneric => 'Бірдеңе дұрыс болмады. Қайталап көріңіз.';

  @override
  String get errNetwork => 'Сервермен байланыс жоқ. Интернетті тексеріңіз.';

  @override
  String get errForbidden => 'Бұл әрекетке құқығыңыз жоқ.';

  @override
  String get errNotFound => 'Табылмады. Мүмкін, ол жойылған.';

  @override
  String get errInvalidCredentials => 'Пошта немесе құпиясөз қате';

  @override
  String errRateLimited(int seconds) {
    return 'Әрекет тым көп. $seconds с кейін қайталаңыз.';
  }

  @override
  String get errAccountSuspended =>
      'Аккаунт бұғатталған. Қолдау қызметіне жазыңыз.';

  @override
  String get errEmailTaken => 'Бұл поштамен аккаунт бар';

  @override
  String get errFieldRequired => 'Өрісті толтырыңыз';

  @override
  String get errEmailInvalid => 'Пошта мекенжайын тексеріңіз';

  @override
  String get errPasswordShort => 'Кемінде 10 таңба';

  @override
  String get errPasswordLong => '128 таңбадан аспауы керек';

  @override
  String get errFieldInvalid => 'Мәнді тексеріңіз';

  @override
  String get sessionExpired => 'Сеанс аяқталды. Қайта кіріңіз.';

  @override
  String get splashOffline => 'Сервермен байланысу мүмкін болмады.';

  @override
  String get loginTitle => 'Кіру';

  @override
  String get loginSubtitle => 'Компанияңыздың камералары мен оқиғалары';

  @override
  String get fieldEmail => 'Эл. пошта';

  @override
  String get fieldPassword => 'Құпиясөз';

  @override
  String get showPassword => 'Құпиясөзді көрсету';

  @override
  String get hidePassword => 'Құпиясөзді жасыру';

  @override
  String get loginButton => 'Кіру';

  @override
  String get loginNoAccount => 'Аккаунт жоқ па?';

  @override
  String get loginRegisterLink => 'Компанияны тіркеу';

  @override
  String get registerTitle => 'Жаңа компания';

  @override
  String get registerSubtitle =>
      'Сіз аккаунт иесі боласыз және әріптестеріңізді шақыра аласыз.';

  @override
  String get fieldCompany => 'Компания атауы';

  @override
  String get fieldFullName => 'Атыңыз';

  @override
  String get passwordHint => 'Кемінде 10 таңба';

  @override
  String get registerButton => 'Аккаунт жасау';

  @override
  String get registerHaveAccount => 'Аккаунт бар ма?';

  @override
  String get registerLoginLink => 'Кіру';

  @override
  String get tabOverview => 'Шолу';

  @override
  String get tabCameras => 'Камералар';

  @override
  String get tabEvents => 'Оқиғалар';

  @override
  String get tabTeam => 'Команда';

  @override
  String tabBadgeA11y(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count камера жұмыс істемейді',
    );
    return '$_temp0';
  }

  @override
  String overviewSubtitle(String date, String company) {
    return 'Бүгін, $date · $company';
  }

  @override
  String get statEvents => 'Оқиғалар';

  @override
  String get statCamerasOnline => 'Желідегі камералар';

  @override
  String statCamerasOffline(int count) {
    return '$count желіде емес';
  }

  @override
  String get statUniquePeople => 'Бірегей адамдар';

  @override
  String get statKnown => 'Таныс адамдар';

  @override
  String statKnownShare(int percent) {
    return 'Оқиғалардың $percent%';
  }

  @override
  String get chartTitle => 'Сағат бойынша оқиғалар';

  @override
  String chartPeak(String hour, int count) {
    return 'шыңы $hour — $count';
  }

  @override
  String chartA11y(int count, String hour) {
    return 'Сағат бойынша оқиғалар, ең көбі $hour кезінде $count';
  }

  @override
  String get attentionTitle => 'Назар аударыңыз';

  @override
  String get attentionNone => 'Барлық камера жұмыс істеп тұр';

  @override
  String get accountA11y => 'Аккаунт';

  @override
  String camerasPlanUsage(int count, int max) {
    return 'Тариф бойынша $max камераның $count';
  }

  @override
  String get camerasEmpty =>
      'Әзірге камера жоқ. Мұнда камераларыңыз бен олардың күйі көрсетіледі.';

  @override
  String cameraLastEvent(String time) {
    return 'оқиға $time';
  }

  @override
  String get cameraEnabledA11y => 'Камера қосулы';

  @override
  String get cameraToggleFailed =>
      'Камераны ауыстыру мүмкін болмады. Қайталап көріңіз.';

  @override
  String get statusPending => 'Баптау';

  @override
  String get statusConnecting => 'Қосылуда';

  @override
  String get statusOnline => 'Желіде';

  @override
  String get statusOffline => 'Желіде емес';

  @override
  String get statusError => 'Қате';

  @override
  String get statusDisabled => 'Өшірулі';

  @override
  String get statusUnknown => 'Белгісіз';

  @override
  String get reasonWaitingForVideoTitle => 'Бейнені күтудеміз';

  @override
  String get reasonWaitingForVideoText =>
      'Тіркеуіш ағынды біз берген мекенжайға жіберіп жатқанын тексеріңіз.';

  @override
  String get reasonEdgeAgentOfflineTitle => 'OpenVision блогы желіде емес';

  @override
  String get reasonEdgeAgentOfflineText =>
      'Нысандағы блок қосулы әрі интернетке қосылғанын тексеріңіз.';

  @override
  String get reasonNoVideoTitle => 'Бейне келмей тұр';

  @override
  String get reasonNoVideoText => 'Камераның қуаты мен желісін тексеріңіз.';

  @override
  String get reasonWaitingForGpuTitle => 'Талдау қуатын күтудеміз';

  @override
  String get reasonWaitingForGpuText =>
      'Бейне дұрыс, талдау жақында басталады. Ештеңе істеудің қажеті жоқ.';

  @override
  String get reasonSourceUnreachableTitle => 'Камера қолжетімсіз';

  @override
  String get reasonSourceUnreachableText =>
      'Мекенжайды және камераға интернеттен қол жеткізуге болатынын тексеріңіз.';

  @override
  String get reasonSourceAuthFailedTitle => 'Логин немесе құпиясөз қате';

  @override
  String get reasonSourceAuthFailedText =>
      'Камера пайдаланушы атын немесе құпиясөзді қабылдамады.';

  @override
  String get reasonSourceNotFoundTitle => 'Ағын табылмады';

  @override
  String get reasonSourceNotFoundText =>
      'Камерада бұл жол бойынша ағын жоқ. URL мекенжайын тексеріңіз.';

  @override
  String get reasonUnsupportedCodecTitle => 'Қолдау көрсетілмейтін формат';

  @override
  String get reasonUnsupportedCodecText =>
      'H.264 немесе H.265 қажет. Камера баптауларында кодекті ауыстырыңыз.';

  @override
  String get reasonNoVideoTrackTitle => 'Ағында бейне жоқ';

  @override
  String get reasonNoVideoTrackText => 'Ағын қосылды, бірақ онда бейнежол жоқ.';

  @override
  String get reasonPrivateAddressTitle => 'Бұл жергілікті желі мекенжайы';

  @override
  String get reasonPrivateAddressText =>
      'Бұлттан ол көрінбейді. Камераны OpenVision блогы арқылы қосыңыз.';

  @override
  String get reasonIngestErrorTitle => 'Біз жақтағы ақау';

  @override
  String get reasonIngestErrorText => 'Хабарлама алдық, қазір шешіп жатырмыз.';

  @override
  String get reasonUnknownTitle => 'Камера жұмыс істемейді';

  @override
  String get reasonUnknownText => 'Қолдау қызметіне жазыңыз.';

  @override
  String reasonLastSeen(String time) {
    return 'Соңғы сигнал $time';
  }

  @override
  String get timeJustNow => 'жаңа ғана';

  @override
  String timeMinutesAgo(int n) {
    return '$n мин бұрын';
  }

  @override
  String timeHoursAgo(int n) {
    return '$n сағ бұрын';
  }

  @override
  String timeDaysAgo(int n) {
    return '$n күн бұрын';
  }

  @override
  String cameraLastFrame(String time) {
    return 'соңғы кадр · $time';
  }

  @override
  String get cameraEnabled => 'Қосулы';

  @override
  String get cameraLocation => 'Орны';

  @override
  String get cameraConnection => 'Қосылым';

  @override
  String get connectionPull => 'Интернеттегі мекенжай';

  @override
  String get connectionPush => 'Тіркеуіш ағын жібереді';

  @override
  String get connectionEdge => 'OpenVision блогы арқылы';

  @override
  String get cameraVideo => 'Бейне';

  @override
  String cameraVideoValue(int width, int height, int fps, String codec) {
    return '$width×$height · $fps fps · $codec';
  }

  @override
  String get cameraEvents => 'Осы камераның оқиғалары';

  @override
  String get cameraDelete => 'Камераны жою';

  @override
  String cameraDeleteTitle(String name) {
    return '«$name» камерасын жою керек пе?';
  }

  @override
  String get cameraDeleteText =>
      'Камера мен оның оқиғалары жойылады. Мұны қайтару мүмкін емес.';

  @override
  String get cameraDeleted => 'Камера жойылды';

  @override
  String get eventsTitle => 'Оқиғалар';

  @override
  String get filtersA11y => 'Сүзгілер';

  @override
  String get connLive => 'Онлайн — оқиғалар бірден келеді';

  @override
  String get connReconnecting => 'Қайта қосылудамыз…';

  @override
  String get connOffline => 'Интернет жоқ. Сақталған деректер көрсетілген';

  @override
  String get filterTitle => 'Сүзгілер';

  @override
  String get filterReset => 'Тазарту';

  @override
  String get filterPeriod => 'Кезең';

  @override
  String get periodAny => 'Барлық уақыт';

  @override
  String get periodToday => 'Бүгін';

  @override
  String get periodYesterday => 'Кеше';

  @override
  String get period7d => '7 күн';

  @override
  String get periodDates => 'Күндер';

  @override
  String get filterPeople => 'Адамдар';

  @override
  String get peopleAll => 'Барлығы';

  @override
  String get peopleKnown => 'Таныс';

  @override
  String get peopleUnknown => 'Бейтаныс';

  @override
  String get filterCameras => 'Камералар';

  @override
  String get camerasAll => 'Барлық камера';

  @override
  String camerasSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count камера',
    );
    return '$_temp0';
  }

  @override
  String get filterShow => 'Оқиғаларды көрсету';

  @override
  String get filterPerson => 'Осы адам';

  @override
  String get filterPersonClear => 'Адам бойынша сүзгіні алып тастау';

  @override
  String get eventKnown => 'Таныс адам';

  @override
  String get eventUnknown => 'Бейтаныс';

  @override
  String get eventTagNew => 'Жаңа';

  @override
  String get eventTagKnown => 'Таныс';

  @override
  String get eventNewA11y => 'Жаңа';

  @override
  String get dayToday => 'Бүгін';

  @override
  String get dayYesterday => 'Кеше';

  @override
  String get eventsEmpty =>
      'Әзірге оқиға жоқ. Мұнда камералар көрген адамдар пайда болады.';

  @override
  String get eventsEmptyFiltered => 'Бұл сүзгілер бойынша оқиға жоқ.';

  @override
  String eventsNewPill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count жаңа оқиға',
    );
    return '$_temp0';
  }

  @override
  String get eventsLoadMoreFailed => 'Жүктеу мүмкін болмады.';

  @override
  String get eventTitleKnown => 'Таныс';

  @override
  String get eventTitleUnknown => 'Бейтаныс';

  @override
  String get eventPersonUnknown => 'Бейтаныс адам';

  @override
  String eventSeenToday(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count рет',
    );
    return 'Бүгін $_temp0 · алғаш рет $time';
  }

  @override
  String get eventCamera => 'Камера';

  @override
  String get eventTime => 'Уақыт';

  @override
  String get eventKind => 'Түрі';

  @override
  String get kindFace => 'Бет';

  @override
  String get kindOther => 'Оқиға';

  @override
  String get eventAllAppearances => 'Осы адамның барлық көрінуі';

  @override
  String get frameA11y => 'Оқиға кадры';

  @override
  String get cropA11y => 'Бет';

  @override
  String get teamTitle => 'Команда';

  @override
  String teamMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count қатысушы',
    );
    return '$_temp0';
  }

  @override
  String get roleOwner => 'Иесі';

  @override
  String get roleAdmin => 'Әкімші';

  @override
  String get roleOperator => 'Оператор';

  @override
  String get roleViewer => 'Бақылаушы';

  @override
  String get memberYou => '(сіз)';

  @override
  String memberInactive(String email) {
    return 'Өшірілген · $email';
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
      other: '$count камера',
    );
    return '$plan · $_temp0';
  }

  @override
  String get accountRetention => 'Оқиғаларды сақтау';

  @override
  String accountRetentionValue(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days күн',
    );
    return '$_temp0';
  }

  @override
  String get signOut => 'Шығу';

  @override
  String get next => 'Әрі қарай';

  @override
  String get done => 'Дайын';

  @override
  String get save => 'Сақтау';

  @override
  String get share => 'Жіберу';

  @override
  String get copy => 'Көшіру';

  @override
  String get copied => 'Көшірілді';

  @override
  String get saved => 'Сақталды';

  @override
  String get addCameraA11y => 'Камера қосу';

  @override
  String get fabCamera => 'Камера';

  @override
  String get addCameraTitle => 'Жаңа камера';

  @override
  String errCameraLimit(int limit) {
    String _temp0 = intl.Intl.pluralLogic(
      limit,
      locale: localeName,
      other: 'Тарифіңіз $limit камераға рұқсат береді',
    );
    return '$_temp0';
  }

  @override
  String get errOwnerProtected => 'Иесін өзгертуге немесе жоюға болмайды.';

  @override
  String get errSelfProtected =>
      'Өз рөліңізді өзгертуге немесе өзіңізді жоюға болмайды.';

  @override
  String get errWrongPassword => 'Ағымдағы құпиясөз қате';

  @override
  String get errRtspInvalid => 'Мекенжай rtsp:// деп басталуы керек';

  @override
  String get modeQuestion => 'Камера интернетке қалай қосылған?';

  @override
  String get modeHint =>
      'Қосылу тәсілі жауапқа байланысты. Сенімді болмасаңыз, бірінші нұсқаны таңдаңыз.';

  @override
  String get modeEdgeTitle => 'Камералар тек біздің желіде';

  @override
  String get modeEdgeText =>
      'OpenVision блогын орнатамыз, ол бейнені жібереді.';

  @override
  String get modeEdgeTag => 'Жиі таңдалады';

  @override
  String get modePushTitle => 'Тіркеуіш ағын жібереді';

  @override
  String get modePushText => 'Hikvision, Dahua, Milestone — мекенжай береміз.';

  @override
  String get modePullTitle => 'Камераның интернетте мекенжайы бар';

  @override
  String get modePullText => 'Жария IP немесе бұлттық тіркеуіш.';

  @override
  String get fieldCameraName => 'Камера атауы';

  @override
  String get fieldName => 'Атауы';

  @override
  String get fieldLocationOptional => 'Орны (міндетті емес)';

  @override
  String get locationPlaceholder => 'Мысалы, «Басты есік»';

  @override
  String get pullTitle => 'Бейне ағынының мекенжайы';

  @override
  String get pullText =>
      'RTSP мекенжайын камера немесе тіркеуіш баптауларынан табыңыз. Логин мен құпиясөзді мекенжайдың ішінде көрсетуге болады.';

  @override
  String get fieldRtsp => 'RTSP мекенжайы';

  @override
  String get probeButton => 'Қосылымды тексеру';

  @override
  String get probing => 'Тексеріп жатырмыз';

  @override
  String get probeConnecting => 'Камераға қосылудамыз…';

  @override
  String get saveCamera => 'Камераны сақтау';

  @override
  String get probeOkTitle => 'Камера жауап береді';

  @override
  String get probeOkHeading => 'Қосылым жұмыс істеп тұр';

  @override
  String get warnLowFps =>
      'Секундына 10 кадрдан аз — тану нашарлайды. Мүмкін болса, камера баптауларында жиілікті арттырыңыз.';

  @override
  String get warnLowResolution =>
      'Ажыратымдылық 480p-ден төмен — тану нашарлайды. Мүмкін болса, камера баптауларында ажыратымдылықты арттырыңыз.';

  @override
  String get probeUseEdge => 'Блок арқылы қосу';

  @override
  String get pushNameTitle => 'Камераны қалай атаймыз?';

  @override
  String get pushNameText =>
      'Атауы камералар тізімінде және оқиғаларда көрсетіледі.';

  @override
  String get pushGetAddress => 'Мекенжай алу';

  @override
  String get pushIntro =>
      'Мекенжайды тіркеуіш баптауларына қойыңыз. Бейне келе бастағанда камера жасылға айналады.';

  @override
  String get pushRecommended => 'Ұсынамыз';

  @override
  String get pushRtspLabel => 'RTSP — егер SRT қолдау көрсетілмесе';

  @override
  String get pushKeyOnce =>
      'Кілтті тек бір рет көрсетеміз. Оны қазір сақтаңыз немесе жіберіңіз.';

  @override
  String get pushOnlineTitle => 'Камера желіде';

  @override
  String get pushOnlineText => 'Бейне келіп жатыр, талдау басталды.';

  @override
  String pushShareSubject(String name) {
    return 'OpenVision: «$name» камерасының мекенжайы';
  }

  @override
  String get edgeInstallTitle => 'Желіңізге блок орнатыңыз';

  @override
  String get edgeInstallText =>
      'Әдетте мұны IT маманы жасайды: камераларды көретін компьютерде бір команда. Бір блок нысандағы барлық камераға қызмет етеді.';

  @override
  String get fieldAgentName => 'Блок атауы';

  @override
  String get agentNamePlaceholder => 'Мысалы, «Қойма — күзет ДК»';

  @override
  String get edgeGetCommand => 'Команданы алу';

  @override
  String get edgeCommandLabel => 'Орнату командасы';

  @override
  String get edgeTokenOnce => 'Командадағы токенді тек бір рет көрсетеміз.';

  @override
  String get edgeWaitingTitle => 'Блоктың байланысқа шығуын күтудеміз';

  @override
  String get edgeWaitingText =>
      'Әдетте іске қосылғаннан кейін 30 секундқа дейін';

  @override
  String get edgeOnlineTitle => 'Блок байланыста';

  @override
  String get edgeOnlineText => 'Енді оны таңдап, камера қосыңыз.';

  @override
  String get edgeShareIt => 'IT-ге жіберу';

  @override
  String edgeShareSubject(String name) {
    return 'OpenVision: «$name» блогын орнату';
  }

  @override
  String get edgePickTitle => 'Камераны қай блок оқиды?';

  @override
  String get edgeInstallNew => 'Жаңа блок орнату';

  @override
  String agentOfflineSince(String time) {
    return 'Желіде емес · $time';
  }

  @override
  String get fieldLocalUrl => 'Камераның жергілікті мекенжайы';

  @override
  String get localUrlHint =>
      'Жергілікті желідегі мекенжай — оны тек блок көреді. Тексеру қосылғаннан кейін пайда болады.';

  @override
  String get cameraEdit => 'Атауы және мекенжайы';

  @override
  String get fieldNewUrl => 'Жаңа мекенжай (міндетті емес)';

  @override
  String newUrlHint(String current) {
    return 'Қазір: $current. Өзгертпеу үшін бос қалдырыңыз.';
  }

  @override
  String get cameraRotateKey => 'Жаңа мекенжай беру';

  @override
  String get rotateTitle => 'Жаңа мекенжай берілсін бе?';

  @override
  String get rotateText =>
      'Ескі кілт бірден жұмысын тоқтатады. Тіркеуішті қайта баптау керек болады.';

  @override
  String get rotateConfirm => 'Беру';

  @override
  String get teamInviteA11y => 'Шақыру';

  @override
  String get inviteTitle => 'Жаңа қатысушы';

  @override
  String get fieldPersonName => 'Аты';

  @override
  String get fieldRole => 'Рөлі';

  @override
  String get roleAdminHint => 'Камералар, команда, журнал';

  @override
  String get roleOperatorHint => 'Оқиғалар, камераларды қосу/өшіру';

  @override
  String get roleViewerHint => 'Тек қарау';

  @override
  String get fieldInitialPassword => 'Бастапқы құпиясөз';

  @override
  String get initialPasswordHint =>
      'Әріптесіңізге өзіңіз беріңіз. Кемінде 10 таңба.';

  @override
  String get inviteButton => 'Командаға қосу';

  @override
  String get memberAdded => 'Қатысушы қосылды';

  @override
  String get memberActions => 'Әрекеттер';

  @override
  String get memberChangeRole => 'Рөлін өзгерту';

  @override
  String get memberDeactivate => 'Қолжетімділікті өшіру';

  @override
  String get memberActivate => 'Қолжетімділікті қосу';

  @override
  String get memberRemove => 'Командадан шығару';

  @override
  String memberRemoveTitle(String name) {
    return '$name командадан шығарылсын ба?';
  }

  @override
  String get memberRemoveText =>
      'Қолжетімділік бірден жойылады. Тек жаңа шақырумен қайтаруға болады.';

  @override
  String get changePassword => 'Құпиясөзді өзгерту';

  @override
  String get fieldCurrentPassword => 'Ағымдағы құпиясөз';

  @override
  String get fieldNewPassword => 'Жаңа құпиясөз';

  @override
  String get changePasswordText =>
      'Өзгерткеннен кейін басқа құрылғыларда қайта кіру керек болады.';

  @override
  String get passwordChanged => 'Құпиясөз өзгертілді';
}
