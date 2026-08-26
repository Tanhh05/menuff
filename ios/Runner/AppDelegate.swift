import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var channelRegistered = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let appResult = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    setupMethodChannel()
    return appResult
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    setupMethodChannel()
  }

  private func setupMethodChannel() {
    guard !channelRegistered else { return }

    var controller: FlutterViewController? = window?.rootViewController as? FlutterViewController
    if controller == nil {
      for window in UIApplication.shared.windows {
        if let rootVC = window.rootViewController as? FlutterViewController {
          controller = rootVC
          break
        }
      }
    }

    guard let flutterVC = controller else {
      return
    }

    let channel = FlutterMethodChannel(name: "com.freefire.esp/memory", binaryMessenger: flutterVC.binaryMessenger)
    channel.setMethodCallHandler({ (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getMemoryInfo" {
        let proc = get_target_process_info()
        let infoDict: [String: Any] = [
          "pid": proc.pid,
          "proc_kaddr": String(format: "0x%X", proc.proc_kaddr),
          "task_kaddr": String(format: "0x%X", proc.task_kaddr),
          "vm_map_kaddr": String(format: "0x%X", proc.vm_map_kaddr),
          "isAttached": proc.pid > 0
        ]
        result(infoDict)
      } else if call.method == "startExploit" {
        DispatchQueue.global(qos: .userInitiated).async {
          print("[+] Manual trigger: Starting DarkSword Kernel Exploit...")
          darksword_exploit_entry(0, nil)
        }
        result("STARTED")
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    channelRegistered = true
    print("[+] MethodChannel com.freefire.esp/memory successfully registered!")
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
