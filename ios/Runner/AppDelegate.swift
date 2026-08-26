import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private static var channelRegistered = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let appResult = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    if let controller = window?.rootViewController as? FlutterViewController {
      AppDelegate.registerMemoryMethodChannel(messenger: controller.binaryMessenger)
    }
    return appResult
  }

  @objc static func registerMemoryMethodChannel(messenger: FlutterBinaryMessenger) {
    guard !channelRegistered else { return }
    channelRegistered = true

    let channel = FlutterMethodChannel(name: "com.freefire.esp/memory", binaryMessenger: messenger)
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
    print("[+] MethodChannel com.freefire.esp/memory successfully registered!")
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}

