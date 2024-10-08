import Flutter
import UIKit

public class AsanLoginPlugin: NSObject, FlutterPlugin {
    private var scheme: String = ""
    private var channel: FlutterMethodChannel
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "asan_login", binaryMessenger: registrar.messenger())
        let instance = AsanLoginPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)  // Register to handle deep linking via application delegate
    }
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "performLogin" {
            guard let args = call.arguments as? [String: Any],
                  let url = args["url"] as? String,
                  let clientId = args["clientId"] as? String,
                  let redirectUri = args["redirectUri"] as? String,
                  let scope = args["scope"] as? String,
                  let sessionId = args["sessionId"] as? String,
                  let responseType = args["responseType"] as? String,
                  let scheme = args["scheme"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required arguments", details: nil))
                return
            }
            self.scheme = scheme
            performLogin(url: url, clientId: clientId, redirectUri: redirectUri, scope: scope, sessionId: sessionId, responseType: responseType)
            result(nil)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func performLogin(url: String, clientId: String, redirectUri: String, scope: String, sessionId: String, responseType: String) {
        let loginUrl = getAsanUrl(url: url, clientId: clientId, redirectUri: redirectUri, scope: scope, sessionId: sessionId, responseType: responseType)
        
        if let loginUrl = URL(string: loginUrl) {
            UIApplication.shared.open(loginUrl)
        }
    }
    
    private func getAsanUrl(url: String, clientId: String, redirectUri: String, scope: String, sessionId: String, responseType: String) -> String {
        return "\(url)client_id=\(clientId)&redirect_uri=\(redirectUri)&response_type=\(responseType)&state=\(sessionId)&scope=\(scope)"
    }
    
    // Handle deep link when returning from the browser
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == scheme {
            if let code = url.queryItems?["code"] {
                channel.invokeMethod("onCodeReceived", arguments: code)
            }
            return true
        }
        return false
    }
}

extension URL {
    var queryItems: [String: String]? {
        var items = [String: String]()
        if let components = URLComponents(url: self, resolvingAgainstBaseURL: false) {
            components.queryItems?.forEach { items[$0.name] = $0.value }
        }
        return items
    }
}
