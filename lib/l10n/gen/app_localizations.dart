import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('kk'),
    Locale('ru'),
  ];

  /// No description provided for @appName.
  ///
  /// In ru, this message translates to:
  /// **'OpenVision'**
  String get appName;

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get delete;

  /// No description provided for @back.
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get back;

  /// No description provided for @close.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get close;

  /// No description provided for @errGeneric.
  ///
  /// In ru, this message translates to:
  /// **'Что-то пошло не так. Повторите попытку.'**
  String get errGeneric;

  /// No description provided for @errNetwork.
  ///
  /// In ru, this message translates to:
  /// **'Нет связи с сервером. Проверьте интернет.'**
  String get errNetwork;

  /// No description provided for @errForbidden.
  ///
  /// In ru, this message translates to:
  /// **'Для этого действия нет прав.'**
  String get errForbidden;

  /// No description provided for @errNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Не найдено. Возможно, это уже удалили.'**
  String get errNotFound;

  /// No description provided for @errInvalidCredentials.
  ///
  /// In ru, this message translates to:
  /// **'Неверная почта или пароль'**
  String get errInvalidCredentials;

  /// No description provided for @errRateLimited.
  ///
  /// In ru, this message translates to:
  /// **'Слишком много попыток. Повторите через {seconds} с.'**
  String errRateLimited(int seconds);

  /// No description provided for @errAccountSuspended.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт заблокирован. Обратитесь в поддержку.'**
  String get errAccountSuspended;

  /// No description provided for @errEmailTaken.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт с этой почтой уже есть'**
  String get errEmailTaken;

  /// No description provided for @errFieldRequired.
  ///
  /// In ru, this message translates to:
  /// **'Заполните поле'**
  String get errFieldRequired;

  /// No description provided for @errEmailInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте адрес почты'**
  String get errEmailInvalid;

  /// No description provided for @errPasswordShort.
  ///
  /// In ru, this message translates to:
  /// **'Не меньше 10 символов'**
  String get errPasswordShort;

  /// No description provided for @errPasswordLong.
  ///
  /// In ru, this message translates to:
  /// **'Не больше 128 символов'**
  String get errPasswordLong;

  /// No description provided for @errFieldInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте значение'**
  String get errFieldInvalid;

  /// No description provided for @sessionExpired.
  ///
  /// In ru, this message translates to:
  /// **'Сессия завершена. Войдите снова.'**
  String get sessionExpired;

  /// No description provided for @splashOffline.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось связаться с сервером.'**
  String get splashOffline;

  /// No description provided for @loginTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вход'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Камеры и события вашей компании'**
  String get loginSubtitle;

  /// No description provided for @fieldEmail.
  ///
  /// In ru, this message translates to:
  /// **'Эл. почта'**
  String get fieldEmail;

  /// No description provided for @fieldPassword.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get fieldPassword;

  /// No description provided for @showPassword.
  ///
  /// In ru, this message translates to:
  /// **'Показать пароль'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть пароль'**
  String get hidePassword;

  /// No description provided for @loginButton.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get loginButton;

  /// No description provided for @loginNoAccount.
  ///
  /// In ru, this message translates to:
  /// **'Нет аккаунта?'**
  String get loginNoAccount;

  /// No description provided for @loginRegisterLink.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрировать компанию'**
  String get loginRegisterLink;

  /// No description provided for @registerTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новая компания'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Вы станете владельцем аккаунта и сможете пригласить коллег.'**
  String get registerSubtitle;

  /// No description provided for @fieldCompany.
  ///
  /// In ru, this message translates to:
  /// **'Название компании'**
  String get fieldCompany;

  /// No description provided for @fieldFullName.
  ///
  /// In ru, this message translates to:
  /// **'Ваше имя'**
  String get fieldFullName;

  /// No description provided for @passwordHint.
  ///
  /// In ru, this message translates to:
  /// **'Не меньше 10 символов'**
  String get passwordHint;

  /// No description provided for @registerButton.
  ///
  /// In ru, this message translates to:
  /// **'Создать аккаунт'**
  String get registerButton;

  /// No description provided for @registerHaveAccount.
  ///
  /// In ru, this message translates to:
  /// **'Уже есть аккаунт?'**
  String get registerHaveAccount;

  /// No description provided for @registerLoginLink.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get registerLoginLink;

  /// No description provided for @tabOverview.
  ///
  /// In ru, this message translates to:
  /// **'Обзор'**
  String get tabOverview;

  /// No description provided for @tabCameras.
  ///
  /// In ru, this message translates to:
  /// **'Камеры'**
  String get tabCameras;

  /// No description provided for @tabEvents.
  ///
  /// In ru, this message translates to:
  /// **'События'**
  String get tabEvents;

  /// No description provided for @tabTeam.
  ///
  /// In ru, this message translates to:
  /// **'Команда'**
  String get tabTeam;

  /// No description provided for @tabBadgeA11y.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} камера не работает} few{{count} камеры не работают} other{{count} камер не работают}}'**
  String tabBadgeA11y(int count);

  /// No description provided for @overviewSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня, {date} · {company}'**
  String overviewSubtitle(String date, String company);

  /// No description provided for @statEvents.
  ///
  /// In ru, this message translates to:
  /// **'События'**
  String get statEvents;

  /// No description provided for @statCamerasOnline.
  ///
  /// In ru, this message translates to:
  /// **'Камеры в сети'**
  String get statCamerasOnline;

  /// No description provided for @statCamerasOffline.
  ///
  /// In ru, this message translates to:
  /// **'{count} не в сети'**
  String statCamerasOffline(int count);

  /// No description provided for @statUniquePeople.
  ///
  /// In ru, this message translates to:
  /// **'Уникальных людей'**
  String get statUniquePeople;

  /// No description provided for @statKnown.
  ///
  /// In ru, this message translates to:
  /// **'Известные'**
  String get statKnown;

  /// No description provided for @statKnownShare.
  ///
  /// In ru, this message translates to:
  /// **'{percent}% событий'**
  String statKnownShare(int percent);

  /// No description provided for @chartTitle.
  ///
  /// In ru, this message translates to:
  /// **'События по часам'**
  String get chartTitle;

  /// No description provided for @chartPeak.
  ///
  /// In ru, this message translates to:
  /// **'пик {hour} — {count}'**
  String chartPeak(String hour, int count);

  /// No description provided for @chartA11y.
  ///
  /// In ru, this message translates to:
  /// **'Событий по часам, максимум {count} в {hour}'**
  String chartA11y(int count, String hour);

  /// No description provided for @attentionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Требуют внимания'**
  String get attentionTitle;

  /// No description provided for @attentionNone.
  ///
  /// In ru, this message translates to:
  /// **'Все камеры работают'**
  String get attentionNone;

  /// No description provided for @accountA11y.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт'**
  String get accountA11y;

  /// No description provided for @camerasPlanUsage.
  ///
  /// In ru, this message translates to:
  /// **'{count} из {max} по тарифу'**
  String camerasPlanUsage(int count, int max);

  /// No description provided for @camerasEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет камер. Здесь будут ваши камеры и их состояние.'**
  String get camerasEmpty;

  /// No description provided for @cameraLastEvent.
  ///
  /// In ru, this message translates to:
  /// **'событие {time}'**
  String cameraLastEvent(String time);

  /// No description provided for @cameraEnabledA11y.
  ///
  /// In ru, this message translates to:
  /// **'Камера включена'**
  String get cameraEnabledA11y;

  /// No description provided for @cameraToggleFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось переключить камеру. Попробуйте ещё раз.'**
  String get cameraToggleFailed;

  /// No description provided for @statusPending.
  ///
  /// In ru, this message translates to:
  /// **'Настройка'**
  String get statusPending;

  /// No description provided for @statusConnecting.
  ///
  /// In ru, this message translates to:
  /// **'Подключение'**
  String get statusConnecting;

  /// No description provided for @statusOnline.
  ///
  /// In ru, this message translates to:
  /// **'В сети'**
  String get statusOnline;

  /// No description provided for @statusOffline.
  ///
  /// In ru, this message translates to:
  /// **'Не в сети'**
  String get statusOffline;

  /// No description provided for @statusError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get statusError;

  /// No description provided for @statusDisabled.
  ///
  /// In ru, this message translates to:
  /// **'Выключена'**
  String get statusDisabled;

  /// No description provided for @statusUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Неизвестно'**
  String get statusUnknown;

  /// No description provided for @reasonWaitingForVideoTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ждём видео'**
  String get reasonWaitingForVideoTitle;

  /// No description provided for @reasonWaitingForVideoText.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте, что регистратор отправляет поток на адрес, который мы выдали.'**
  String get reasonWaitingForVideoText;

  /// No description provided for @reasonEdgeAgentOfflineTitle.
  ///
  /// In ru, this message translates to:
  /// **'Блок OpenVision не в сети'**
  String get reasonEdgeAgentOfflineTitle;

  /// No description provided for @reasonEdgeAgentOfflineText.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте, что блок на объекте включён и подключён к интернету.'**
  String get reasonEdgeAgentOfflineText;

  /// No description provided for @reasonNoVideoTitle.
  ///
  /// In ru, this message translates to:
  /// **'Видео не поступает'**
  String get reasonNoVideoTitle;

  /// No description provided for @reasonNoVideoText.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте питание и сеть камеры.'**
  String get reasonNoVideoText;

  /// No description provided for @reasonWaitingForGpuTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ожидание мощностей анализа'**
  String get reasonWaitingForGpuTitle;

  /// No description provided for @reasonWaitingForGpuText.
  ///
  /// In ru, this message translates to:
  /// **'Видео в порядке, анализ скоро начнётся. Ничего делать не нужно.'**
  String get reasonWaitingForGpuText;

  /// No description provided for @reasonSourceUnreachableTitle.
  ///
  /// In ru, this message translates to:
  /// **'Камера недоступна'**
  String get reasonSourceUnreachableTitle;

  /// No description provided for @reasonSourceUnreachableText.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте адрес и что камера доступна из интернета.'**
  String get reasonSourceUnreachableText;

  /// No description provided for @reasonSourceAuthFailedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Неверный логин или пароль'**
  String get reasonSourceAuthFailedTitle;

  /// No description provided for @reasonSourceAuthFailedText.
  ///
  /// In ru, this message translates to:
  /// **'Камера отклонила имя пользователя или пароль.'**
  String get reasonSourceAuthFailedText;

  /// No description provided for @reasonSourceNotFoundTitle.
  ///
  /// In ru, this message translates to:
  /// **'Поток не найден'**
  String get reasonSourceNotFoundTitle;

  /// No description provided for @reasonSourceNotFoundText.
  ///
  /// In ru, this message translates to:
  /// **'По этому пути у камеры нет потока. Проверьте URL.'**
  String get reasonSourceNotFoundText;

  /// No description provided for @reasonUnsupportedCodecTitle.
  ///
  /// In ru, this message translates to:
  /// **'Неподдерживаемый формат'**
  String get reasonUnsupportedCodecTitle;

  /// No description provided for @reasonUnsupportedCodecText.
  ///
  /// In ru, this message translates to:
  /// **'Нужен H.264 или H.265. Смените кодек в настройках камеры.'**
  String get reasonUnsupportedCodecText;

  /// No description provided for @reasonNoVideoTrackTitle.
  ///
  /// In ru, this message translates to:
  /// **'В потоке нет видео'**
  String get reasonNoVideoTrackTitle;

  /// No description provided for @reasonNoVideoTrackText.
  ///
  /// In ru, this message translates to:
  /// **'Поток подключился, но видеодорожки в нём нет.'**
  String get reasonNoVideoTrackText;

  /// No description provided for @reasonPrivateAddressTitle.
  ///
  /// In ru, this message translates to:
  /// **'Это адрес локальной сети'**
  String get reasonPrivateAddressTitle;

  /// No description provided for @reasonPrivateAddressText.
  ///
  /// In ru, this message translates to:
  /// **'Из облака его не видно. Подключите камеру через блок OpenVision.'**
  String get reasonPrivateAddressText;

  /// No description provided for @reasonIngestErrorTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сбой на нашей стороне'**
  String get reasonIngestErrorTitle;

  /// No description provided for @reasonIngestErrorText.
  ///
  /// In ru, this message translates to:
  /// **'Мы уже получили уведомление и разбираемся.'**
  String get reasonIngestErrorText;

  /// No description provided for @reasonUnknownTitle.
  ///
  /// In ru, this message translates to:
  /// **'Камера не работает'**
  String get reasonUnknownTitle;

  /// No description provided for @reasonUnknownText.
  ///
  /// In ru, this message translates to:
  /// **'Обратитесь в поддержку.'**
  String get reasonUnknownText;

  /// No description provided for @reasonLastSeen.
  ///
  /// In ru, this message translates to:
  /// **'Последний сигнал {time}'**
  String reasonLastSeen(String time);

  /// No description provided for @timeJustNow.
  ///
  /// In ru, this message translates to:
  /// **'только что'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In ru, this message translates to:
  /// **'{n} мин назад'**
  String timeMinutesAgo(int n);

  /// No description provided for @timeHoursAgo.
  ///
  /// In ru, this message translates to:
  /// **'{n} ч назад'**
  String timeHoursAgo(int n);

  /// No description provided for @timeDaysAgo.
  ///
  /// In ru, this message translates to:
  /// **'{n} дн. назад'**
  String timeDaysAgo(int n);

  /// No description provided for @cameraLastFrame.
  ///
  /// In ru, this message translates to:
  /// **'последний кадр · {time}'**
  String cameraLastFrame(String time);

  /// No description provided for @cameraEnabled.
  ///
  /// In ru, this message translates to:
  /// **'Включена'**
  String get cameraEnabled;

  /// No description provided for @cameraLocation.
  ///
  /// In ru, this message translates to:
  /// **'Место'**
  String get cameraLocation;

  /// No description provided for @cameraConnection.
  ///
  /// In ru, this message translates to:
  /// **'Подключение'**
  String get cameraConnection;

  /// No description provided for @connectionPull.
  ///
  /// In ru, this message translates to:
  /// **'Адрес в интернете'**
  String get connectionPull;

  /// No description provided for @connectionPush.
  ///
  /// In ru, this message translates to:
  /// **'Регистратор отправляет поток'**
  String get connectionPush;

  /// No description provided for @connectionEdge.
  ///
  /// In ru, this message translates to:
  /// **'Через блок OpenVision'**
  String get connectionEdge;

  /// No description provided for @cameraVideo.
  ///
  /// In ru, this message translates to:
  /// **'Видео'**
  String get cameraVideo;

  /// No description provided for @cameraVideoValue.
  ///
  /// In ru, this message translates to:
  /// **'{width}×{height} · {fps} fps · {codec}'**
  String cameraVideoValue(int width, int height, int fps, String codec);

  /// No description provided for @cameraEvents.
  ///
  /// In ru, this message translates to:
  /// **'События этой камеры'**
  String get cameraEvents;

  /// No description provided for @cameraDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить камеру'**
  String get cameraDelete;

  /// No description provided for @cameraDeleteTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить камеру «{name}»?'**
  String cameraDeleteTitle(String name);

  /// No description provided for @cameraDeleteText.
  ///
  /// In ru, this message translates to:
  /// **'Камера и её события будут удалены. Это нельзя отменить.'**
  String get cameraDeleteText;

  /// No description provided for @cameraDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Камера удалена'**
  String get cameraDeleted;

  /// No description provided for @eventsTitle.
  ///
  /// In ru, this message translates to:
  /// **'События'**
  String get eventsTitle;

  /// No description provided for @filtersA11y.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры'**
  String get filtersA11y;

  /// No description provided for @connLive.
  ///
  /// In ru, this message translates to:
  /// **'Онлайн — события приходят сразу'**
  String get connLive;

  /// No description provided for @connReconnecting.
  ///
  /// In ru, this message translates to:
  /// **'Переподключаемся…'**
  String get connReconnecting;

  /// No description provided for @connOffline.
  ///
  /// In ru, this message translates to:
  /// **'Нет интернета. Показаны сохранённые данные'**
  String get connOffline;

  /// No description provided for @filterTitle.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры'**
  String get filterTitle;

  /// No description provided for @filterReset.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get filterReset;

  /// No description provided for @filterPeriod.
  ///
  /// In ru, this message translates to:
  /// **'Период'**
  String get filterPeriod;

  /// No description provided for @periodAny.
  ///
  /// In ru, this message translates to:
  /// **'Всё время'**
  String get periodAny;

  /// No description provided for @periodToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get periodToday;

  /// No description provided for @periodYesterday.
  ///
  /// In ru, this message translates to:
  /// **'Вчера'**
  String get periodYesterday;

  /// No description provided for @period7d.
  ///
  /// In ru, this message translates to:
  /// **'7 дней'**
  String get period7d;

  /// No description provided for @periodDates.
  ///
  /// In ru, this message translates to:
  /// **'Даты'**
  String get periodDates;

  /// No description provided for @filterPeople.
  ///
  /// In ru, this message translates to:
  /// **'Люди'**
  String get filterPeople;

  /// No description provided for @peopleAll.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get peopleAll;

  /// No description provided for @peopleKnown.
  ///
  /// In ru, this message translates to:
  /// **'Известные'**
  String get peopleKnown;

  /// No description provided for @peopleUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Неизвестные'**
  String get peopleUnknown;

  /// No description provided for @filterCameras.
  ///
  /// In ru, this message translates to:
  /// **'Камеры'**
  String get filterCameras;

  /// No description provided for @camerasAll.
  ///
  /// In ru, this message translates to:
  /// **'Все камеры'**
  String get camerasAll;

  /// No description provided for @camerasSelected.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} камера} few{{count} камеры} other{{count} камер}}'**
  String camerasSelected(int count);

  /// No description provided for @filterShow.
  ///
  /// In ru, this message translates to:
  /// **'Показать события'**
  String get filterShow;

  /// No description provided for @filterPerson.
  ///
  /// In ru, this message translates to:
  /// **'Этот человек'**
  String get filterPerson;

  /// No description provided for @filterPersonClear.
  ///
  /// In ru, this message translates to:
  /// **'Убрать фильтр по человеку'**
  String get filterPersonClear;

  /// No description provided for @eventKnown.
  ///
  /// In ru, this message translates to:
  /// **'Известный человек'**
  String get eventKnown;

  /// No description provided for @eventUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Неизвестный'**
  String get eventUnknown;

  /// No description provided for @eventTagNew.
  ///
  /// In ru, this message translates to:
  /// **'Новый'**
  String get eventTagNew;

  /// No description provided for @eventTagKnown.
  ///
  /// In ru, this message translates to:
  /// **'Известный'**
  String get eventTagKnown;

  /// No description provided for @eventNewA11y.
  ///
  /// In ru, this message translates to:
  /// **'Новое'**
  String get eventNewA11y;

  /// No description provided for @dayToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get dayToday;

  /// No description provided for @dayYesterday.
  ///
  /// In ru, this message translates to:
  /// **'Вчера'**
  String get dayYesterday;

  /// No description provided for @eventsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Событий пока нет. Здесь появятся люди, которых увидят камеры.'**
  String get eventsEmpty;

  /// No description provided for @eventsEmptyFiltered.
  ///
  /// In ru, this message translates to:
  /// **'Нет событий по этим фильтрам.'**
  String get eventsEmptyFiltered;

  /// No description provided for @eventsNewPill.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} новое событие} few{{count} новых события} other{{count} новых событий}}'**
  String eventsNewPill(int count);

  /// No description provided for @eventsLoadMoreFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить.'**
  String get eventsLoadMoreFailed;

  /// No description provided for @eventTitleKnown.
  ///
  /// In ru, this message translates to:
  /// **'Известный'**
  String get eventTitleKnown;

  /// No description provided for @eventTitleUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Неизвестный'**
  String get eventTitleUnknown;

  /// No description provided for @eventPersonUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Неизвестный человек'**
  String get eventPersonUnknown;

  /// No description provided for @eventSeenToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня {count, plural, one{{count} раз} few{{count} раза} other{{count} раз}} · первый раз в {time}'**
  String eventSeenToday(int count, String time);

  /// No description provided for @eventCamera.
  ///
  /// In ru, this message translates to:
  /// **'Камера'**
  String get eventCamera;

  /// No description provided for @eventTime.
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get eventTime;

  /// No description provided for @eventKind.
  ///
  /// In ru, this message translates to:
  /// **'Тип'**
  String get eventKind;

  /// No description provided for @kindFace.
  ///
  /// In ru, this message translates to:
  /// **'Лицо'**
  String get kindFace;

  /// No description provided for @kindOther.
  ///
  /// In ru, this message translates to:
  /// **'Событие'**
  String get kindOther;

  /// No description provided for @eventAllAppearances.
  ///
  /// In ru, this message translates to:
  /// **'Все появления этого человека'**
  String get eventAllAppearances;

  /// No description provided for @frameA11y.
  ///
  /// In ru, this message translates to:
  /// **'Кадр события'**
  String get frameA11y;

  /// No description provided for @cropA11y.
  ///
  /// In ru, this message translates to:
  /// **'Лицо'**
  String get cropA11y;

  /// No description provided for @teamTitle.
  ///
  /// In ru, this message translates to:
  /// **'Команда'**
  String get teamTitle;

  /// No description provided for @teamMembers.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} участник} few{{count} участника} other{{count} участников}}'**
  String teamMembers(int count);

  /// No description provided for @roleOwner.
  ///
  /// In ru, this message translates to:
  /// **'Владелец'**
  String get roleOwner;

  /// No description provided for @roleAdmin.
  ///
  /// In ru, this message translates to:
  /// **'Администратор'**
  String get roleAdmin;

  /// No description provided for @roleOperator.
  ///
  /// In ru, this message translates to:
  /// **'Оператор'**
  String get roleOperator;

  /// No description provided for @roleViewer.
  ///
  /// In ru, this message translates to:
  /// **'Наблюдатель'**
  String get roleViewer;

  /// No description provided for @memberYou.
  ///
  /// In ru, this message translates to:
  /// **'(вы)'**
  String get memberYou;

  /// No description provided for @memberInactive.
  ///
  /// In ru, this message translates to:
  /// **'Отключён · {email}'**
  String memberInactive(String email);

  /// No description provided for @accountSection.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт'**
  String get accountSection;

  /// No description provided for @accountPlan.
  ///
  /// In ru, this message translates to:
  /// **'Тариф'**
  String get accountPlan;

  /// No description provided for @accountPlanValue.
  ///
  /// In ru, this message translates to:
  /// **'{plan} · {count, plural, one{{count} камера} few{{count} камеры} other{{count} камер}}'**
  String accountPlanValue(String plan, int count);

  /// No description provided for @accountRetention.
  ///
  /// In ru, this message translates to:
  /// **'Хранение событий'**
  String get accountRetention;

  /// No description provided for @accountRetentionValue.
  ///
  /// In ru, this message translates to:
  /// **'{days, plural, one{{days} день} few{{days} дня} other{{days} дней}}'**
  String accountRetentionValue(int days);

  /// No description provided for @signOut.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get signOut;

  /// No description provided for @next.
  ///
  /// In ru, this message translates to:
  /// **'Далее'**
  String get next;

  /// No description provided for @done.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get done;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @share.
  ///
  /// In ru, this message translates to:
  /// **'Отправить'**
  String get share;

  /// No description provided for @copy.
  ///
  /// In ru, this message translates to:
  /// **'Копировать'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In ru, this message translates to:
  /// **'Скопировано'**
  String get copied;

  /// No description provided for @saved.
  ///
  /// In ru, this message translates to:
  /// **'Сохранено'**
  String get saved;

  /// No description provided for @addCameraA11y.
  ///
  /// In ru, this message translates to:
  /// **'Добавить камеру'**
  String get addCameraA11y;

  /// No description provided for @fabCamera.
  ///
  /// In ru, this message translates to:
  /// **'Камера'**
  String get fabCamera;

  /// No description provided for @addCameraTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новая камера'**
  String get addCameraTitle;

  /// No description provided for @errCameraLimit.
  ///
  /// In ru, this message translates to:
  /// **'{limit, plural, one{Ваш тариф позволяет {limit} камеру} few{Ваш тариф позволяет {limit} камеры} other{Ваш тариф позволяет {limit} камер}}'**
  String errCameraLimit(int limit);

  /// No description provided for @errOwnerProtected.
  ///
  /// In ru, this message translates to:
  /// **'Владельца нельзя изменить или удалить.'**
  String get errOwnerProtected;

  /// No description provided for @errSelfProtected.
  ///
  /// In ru, this message translates to:
  /// **'Нельзя менять свою роль или удалять себя.'**
  String get errSelfProtected;

  /// No description provided for @errWrongPassword.
  ///
  /// In ru, this message translates to:
  /// **'Текущий пароль неверный'**
  String get errWrongPassword;

  /// No description provided for @errRtspInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Адрес должен начинаться с rtsp://'**
  String get errRtspInvalid;

  /// No description provided for @modeQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Как камера подключена к интернету?'**
  String get modeQuestion;

  /// No description provided for @modeHint.
  ///
  /// In ru, this message translates to:
  /// **'От ответа зависит способ подключения. Если не уверены — выберите первый вариант.'**
  String get modeHint;

  /// No description provided for @modeEdgeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Камеры только в нашей сети'**
  String get modeEdgeTitle;

  /// No description provided for @modeEdgeText.
  ///
  /// In ru, this message translates to:
  /// **'Поставим блок OpenVision, он передаст видео.'**
  String get modeEdgeText;

  /// No description provided for @modeEdgeTag.
  ///
  /// In ru, this message translates to:
  /// **'Чаще всего'**
  String get modeEdgeTag;

  /// No description provided for @modePushTitle.
  ///
  /// In ru, this message translates to:
  /// **'Регистратор отправляет поток'**
  String get modePushTitle;

  /// No description provided for @modePushText.
  ///
  /// In ru, this message translates to:
  /// **'Hikvision, Dahua, Milestone — дадим адрес.'**
  String get modePushText;

  /// No description provided for @modePullTitle.
  ///
  /// In ru, this message translates to:
  /// **'У камеры есть адрес в интернете'**
  String get modePullTitle;

  /// No description provided for @modePullText.
  ///
  /// In ru, this message translates to:
  /// **'Публичный IP или облачный регистратор.'**
  String get modePullText;

  /// No description provided for @fieldCameraName.
  ///
  /// In ru, this message translates to:
  /// **'Название камеры'**
  String get fieldCameraName;

  /// No description provided for @fieldName.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get fieldName;

  /// No description provided for @fieldLocationOptional.
  ///
  /// In ru, this message translates to:
  /// **'Место (необязательно)'**
  String get fieldLocationOptional;

  /// No description provided for @locationPlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Например, «Главная дверь»'**
  String get locationPlaceholder;

  /// No description provided for @pullTitle.
  ///
  /// In ru, this message translates to:
  /// **'Адрес видеопотока'**
  String get pullTitle;

  /// No description provided for @pullText.
  ///
  /// In ru, this message translates to:
  /// **'Найдите RTSP-адрес в настройках камеры или регистратора. Логин и пароль можно указать прямо в адресе.'**
  String get pullText;

  /// No description provided for @fieldRtsp.
  ///
  /// In ru, this message translates to:
  /// **'RTSP-адрес'**
  String get fieldRtsp;

  /// No description provided for @probeButton.
  ///
  /// In ru, this message translates to:
  /// **'Проверить подключение'**
  String get probeButton;

  /// No description provided for @probing.
  ///
  /// In ru, this message translates to:
  /// **'Проверяем'**
  String get probing;

  /// No description provided for @probeConnecting.
  ///
  /// In ru, this message translates to:
  /// **'Подключаемся к камере…'**
  String get probeConnecting;

  /// No description provided for @saveCamera.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить камеру'**
  String get saveCamera;

  /// No description provided for @probeOkTitle.
  ///
  /// In ru, this message translates to:
  /// **'Камера отвечает'**
  String get probeOkTitle;

  /// No description provided for @probeOkHeading.
  ///
  /// In ru, this message translates to:
  /// **'Подключение работает'**
  String get probeOkHeading;

  /// No description provided for @warnLowFps.
  ///
  /// In ru, this message translates to:
  /// **'Меньше 10 кадров в секунду — распознавание будет хуже. Повысьте частоту в настройках камеры, если можно.'**
  String get warnLowFps;

  /// No description provided for @warnLowResolution.
  ///
  /// In ru, this message translates to:
  /// **'Разрешение ниже 480p — распознавание будет хуже. Повысьте разрешение в настройках камеры, если можно.'**
  String get warnLowResolution;

  /// No description provided for @probeUseEdge.
  ///
  /// In ru, this message translates to:
  /// **'Подключить через блок'**
  String get probeUseEdge;

  /// No description provided for @pushNameTitle.
  ///
  /// In ru, this message translates to:
  /// **'Как назвать камеру?'**
  String get pushNameTitle;

  /// No description provided for @pushNameText.
  ///
  /// In ru, this message translates to:
  /// **'Название будет в списке камер и в событиях.'**
  String get pushNameText;

  /// No description provided for @pushGetAddress.
  ///
  /// In ru, this message translates to:
  /// **'Получить адрес'**
  String get pushGetAddress;

  /// No description provided for @pushIntro.
  ///
  /// In ru, this message translates to:
  /// **'Вставьте адрес в настройки регистратора. Камера станет зелёной, как только пойдёт видео.'**
  String get pushIntro;

  /// No description provided for @pushRecommended.
  ///
  /// In ru, this message translates to:
  /// **'Рекомендуем'**
  String get pushRecommended;

  /// No description provided for @pushRtspLabel.
  ///
  /// In ru, this message translates to:
  /// **'RTSP — если SRT не поддерживается'**
  String get pushRtspLabel;

  /// No description provided for @pushKeyOnce.
  ///
  /// In ru, this message translates to:
  /// **'Ключ показываем только один раз. Сохраните или отправьте его сейчас.'**
  String get pushKeyOnce;

  /// No description provided for @pushOnlineTitle.
  ///
  /// In ru, this message translates to:
  /// **'Камера в сети'**
  String get pushOnlineTitle;

  /// No description provided for @pushOnlineText.
  ///
  /// In ru, this message translates to:
  /// **'Видео поступает, анализ начался.'**
  String get pushOnlineText;

  /// No description provided for @pushShareSubject.
  ///
  /// In ru, this message translates to:
  /// **'OpenVision: адрес для камеры «{name}»'**
  String pushShareSubject(String name);

  /// No description provided for @edgeInstallTitle.
  ///
  /// In ru, this message translates to:
  /// **'Установите блок в вашей сети'**
  String get edgeInstallTitle;

  /// No description provided for @edgeInstallText.
  ///
  /// In ru, this message translates to:
  /// **'Обычно это делает IT-специалист: одна команда на компьютере, который видит камеры. Один блок обслуживает все камеры объекта.'**
  String get edgeInstallText;

  /// No description provided for @fieldAgentName.
  ///
  /// In ru, this message translates to:
  /// **'Название блока'**
  String get fieldAgentName;

  /// No description provided for @agentNamePlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Например, «Склад — ПК охраны»'**
  String get agentNamePlaceholder;

  /// No description provided for @edgeGetCommand.
  ///
  /// In ru, this message translates to:
  /// **'Получить команду'**
  String get edgeGetCommand;

  /// No description provided for @edgeCommandLabel.
  ///
  /// In ru, this message translates to:
  /// **'Команда установки'**
  String get edgeCommandLabel;

  /// No description provided for @edgeTokenOnce.
  ///
  /// In ru, this message translates to:
  /// **'Токен в команде покажем только один раз.'**
  String get edgeTokenOnce;

  /// No description provided for @edgeWaitingTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ждём, когда блок выйдет на связь'**
  String get edgeWaitingTitle;

  /// No description provided for @edgeWaitingText.
  ///
  /// In ru, this message translates to:
  /// **'Обычно до 30 секунд после запуска'**
  String get edgeWaitingText;

  /// No description provided for @edgeOnlineTitle.
  ///
  /// In ru, this message translates to:
  /// **'Блок на связи'**
  String get edgeOnlineTitle;

  /// No description provided for @edgeOnlineText.
  ///
  /// In ru, this message translates to:
  /// **'Теперь выберите его и добавьте камеру.'**
  String get edgeOnlineText;

  /// No description provided for @edgeShareIt.
  ///
  /// In ru, this message translates to:
  /// **'Отправить IT'**
  String get edgeShareIt;

  /// No description provided for @edgeShareSubject.
  ///
  /// In ru, this message translates to:
  /// **'OpenVision: установка блока «{name}»'**
  String edgeShareSubject(String name);

  /// No description provided for @edgePickTitle.
  ///
  /// In ru, this message translates to:
  /// **'Какой блок читает камеру?'**
  String get edgePickTitle;

  /// No description provided for @edgeInstallNew.
  ///
  /// In ru, this message translates to:
  /// **'Установить новый блок'**
  String get edgeInstallNew;

  /// No description provided for @agentOfflineSince.
  ///
  /// In ru, this message translates to:
  /// **'Не в сети · {time}'**
  String agentOfflineSince(String time);

  /// No description provided for @fieldLocalUrl.
  ///
  /// In ru, this message translates to:
  /// **'Локальный адрес камеры'**
  String get fieldLocalUrl;

  /// No description provided for @localUrlHint.
  ///
  /// In ru, this message translates to:
  /// **'Адрес из локальной сети — его увидит только блок. Проверка появится после подключения.'**
  String get localUrlHint;

  /// No description provided for @cameraEdit.
  ///
  /// In ru, this message translates to:
  /// **'Название и адрес'**
  String get cameraEdit;

  /// No description provided for @fieldNewUrl.
  ///
  /// In ru, this message translates to:
  /// **'Новый адрес (необязательно)'**
  String get fieldNewUrl;

  /// No description provided for @newUrlHint.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас: {current}. Оставьте пустым, чтобы не менять.'**
  String newUrlHint(String current);

  /// No description provided for @cameraRotateKey.
  ///
  /// In ru, this message translates to:
  /// **'Выдать новый адрес'**
  String get cameraRotateKey;

  /// No description provided for @rotateTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выдать новый адрес?'**
  String get rotateTitle;

  /// No description provided for @rotateText.
  ///
  /// In ru, this message translates to:
  /// **'Старый ключ сразу перестанет работать. Регистратор нужно будет настроить заново.'**
  String get rotateText;

  /// No description provided for @rotateConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Выдать'**
  String get rotateConfirm;

  /// No description provided for @teamInviteA11y.
  ///
  /// In ru, this message translates to:
  /// **'Пригласить'**
  String get teamInviteA11y;

  /// No description provided for @inviteTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новый участник'**
  String get inviteTitle;

  /// No description provided for @fieldPersonName.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get fieldPersonName;

  /// No description provided for @fieldRole.
  ///
  /// In ru, this message translates to:
  /// **'Роль'**
  String get fieldRole;

  /// No description provided for @roleAdminHint.
  ///
  /// In ru, this message translates to:
  /// **'Камеры, команда, журнал'**
  String get roleAdminHint;

  /// No description provided for @roleOperatorHint.
  ///
  /// In ru, this message translates to:
  /// **'События, вкл/выкл камер'**
  String get roleOperatorHint;

  /// No description provided for @roleViewerHint.
  ///
  /// In ru, this message translates to:
  /// **'Только просмотр'**
  String get roleViewerHint;

  /// No description provided for @fieldInitialPassword.
  ///
  /// In ru, this message translates to:
  /// **'Начальный пароль'**
  String get fieldInitialPassword;

  /// No description provided for @initialPasswordHint.
  ///
  /// In ru, this message translates to:
  /// **'Передайте коллеге сами. Не меньше 10 символов.'**
  String get initialPasswordHint;

  /// No description provided for @inviteButton.
  ///
  /// In ru, this message translates to:
  /// **'Добавить в команду'**
  String get inviteButton;

  /// No description provided for @memberAdded.
  ///
  /// In ru, this message translates to:
  /// **'Участник добавлен'**
  String get memberAdded;

  /// No description provided for @memberActions.
  ///
  /// In ru, this message translates to:
  /// **'Действия'**
  String get memberActions;

  /// No description provided for @memberChangeRole.
  ///
  /// In ru, this message translates to:
  /// **'Сменить роль'**
  String get memberChangeRole;

  /// No description provided for @memberDeactivate.
  ///
  /// In ru, this message translates to:
  /// **'Отключить доступ'**
  String get memberDeactivate;

  /// No description provided for @memberActivate.
  ///
  /// In ru, this message translates to:
  /// **'Включить доступ'**
  String get memberActivate;

  /// No description provided for @memberRemove.
  ///
  /// In ru, this message translates to:
  /// **'Удалить из команды'**
  String get memberRemove;

  /// No description provided for @memberRemoveTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить {name} из команды?'**
  String memberRemoveTitle(String name);

  /// No description provided for @memberRemoveText.
  ///
  /// In ru, this message translates to:
  /// **'Доступ пропадёт сразу. Вернуть можно только новым приглашением.'**
  String get memberRemoveText;

  /// No description provided for @changePassword.
  ///
  /// In ru, this message translates to:
  /// **'Сменить пароль'**
  String get changePassword;

  /// No description provided for @fieldCurrentPassword.
  ///
  /// In ru, this message translates to:
  /// **'Текущий пароль'**
  String get fieldCurrentPassword;

  /// No description provided for @fieldNewPassword.
  ///
  /// In ru, this message translates to:
  /// **'Новый пароль'**
  String get fieldNewPassword;

  /// No description provided for @changePasswordText.
  ///
  /// In ru, this message translates to:
  /// **'На других устройствах после смены нужно будет войти заново.'**
  String get changePasswordText;

  /// No description provided for @passwordChanged.
  ///
  /// In ru, this message translates to:
  /// **'Пароль изменён'**
  String get passwordChanged;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
