import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Trigger real DarkSword Kernel Exploit & FreeFire process search in background
    DispatchQueue.global(qos: .userInitiated).async {
      print("[+] Starting DarkSword Kernel Exploit & FreeFire Search Engine...")
      darksword_exploit_entry(0, nil)
    }


    GeneratedPluginRegistrant.register(with: self)
    let appResult = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "com.freefire.esp/memory", binaryMessenger: controller.binaryMessenger)
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
        } else {
          result(FlutterMethodNotImplemented)
        }
      })
    }

    return appResult
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}


