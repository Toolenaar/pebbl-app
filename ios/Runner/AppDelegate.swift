import UIKit
import Flutter
import AudioKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    lazy var audioPlugin = AudioPlugin()
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        setupPlatformChannels()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func setupPlatformChannels(){
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let audioChannel = FlutterMethodChannel(name: "pebbl_plugin/audio",
                                                binaryMessenger: controller.binaryMessenger)
        
        audioChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            self.handleResult(call: call, result:result)
        })
    }
    
    func handleResult(call: FlutterMethodCall, result: @escaping FlutterResult){
        // Note: this method is invoked on the UI thread.
        NSLog("\nHANDLING RESULT")
        if call.method == "getPlatformVersion" {
            self.getPlatformVersion(result: result)
            return
        }else if call.method == "initSet" {
            
            guard let args = call.arguments as? [String: Any] else {
                result(false)
                return
            }
            if let name = args["name"] as? String {
                let success = self.audioPlugin.initSet(name: name)
                result(success)
            }else{
                result(false)
            }
            return
        }else if call.method == "playSet" {
            guard let args = call.arguments as? [String: Any] else {
                result(false)
                return
            }
            if let name = args["name"] as? String {
                let success = self.audioPlugin.playSet(name: name)
                result(success)
            }else{
                result(false)
            }
            return
        }else{
            result(FlutterMethodNotImplemented)
        }
    }
    private func getPlatformVersion(result: @escaping FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
    }
    
}
