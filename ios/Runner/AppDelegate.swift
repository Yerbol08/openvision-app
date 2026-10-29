import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let privacy = PrivacyShield()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    privacy.attach(messenger: engineBridge.applicationRegistrar.messenger())
  }
}

/// Размывает снимок приложения в переключателе, пока открыт экран с лицами.
final class PrivacyShield {
  private var secure = false
  private var cover: UIVisualEffectView?
  private var channel: FlutterMethodChannel?

  func attach(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "openvision/privacy", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "setSecure" else { return result(FlutterMethodNotImplemented) }
      let args = call.arguments as? [String: Any]
      self?.secure = (args?["secure"] as? Bool) ?? false
      result(nil)
    }
    self.channel = channel
    let nc = NotificationCenter.default
    nc.addObserver(self, selector: #selector(resignActive), name: UIApplication.willResignActiveNotification, object: nil)
    nc.addObserver(self, selector: #selector(becomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
  }

  @objc private func resignActive() {
    guard secure, cover == nil, let window = keyWindow() else { return }
    let view = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    view.frame = window.bounds
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    window.addSubview(view)
    cover = view
  }

  @objc private func becomeActive() {
    cover?.removeFromSuperview()
    cover = nil
  }

  private func keyWindow() -> UIWindow? {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
  }
}
