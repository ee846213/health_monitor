import Flutter
import UIKit

final class HealthMonitorBackgroundBridge: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let instance = HealthMonitorBackgroundBridge()
    let channel = FlutterMethodChannel(
      name: "health_monitor/platform_bridge",
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "ios.background.start":
      result(self.hostStatusPayload(isRunning: true, summary: "iPhone 后台刷新通道已接入。"))
    case "ios.background.stop":
      result(self.hostStatusPayload(isRunning: false, summary: "iPhone 后台刷新通道已停止。"))
    case "ios.background.status":
      result(self.hostStatusPayload(isRunning: false, summary: "iPhone 宿主后台状态尚未进入系统级实现。"))
    case "ios.background.error":
      let message = (call.arguments as? [String: Any])?["message"] as? String
      result(self.hostStatusPayload(
        isRunning: false,
        summary: "iPhone 宿主后台捕获到异常。",
        lastErrorMessage: message
      ))
    case "ios.background.refresh":
      result(self.hostStatusPayload(
        isRunning: false,
        summary: "iPhone 后台调度刷新请求已接收。",
        notificationBody: "当前仍处于原生桥接骨架阶段。"
      ))
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func hostStatusPayload(
    isRunning: Bool,
    summary: String,
    lastErrorMessage: String? = nil,
    notificationBody: String? = nil
  ) -> [String: Any] {
    var payload: [String: Any] = [
      "isRunning": isRunning,
      "summary": summary,
    ]
    if let lastErrorMessage {
      payload["lastErrorMessage"] = lastErrorMessage
    }
    if let notificationBody {
      payload["notificationBody"] = notificationBody
    }
    return payload
  }
}
