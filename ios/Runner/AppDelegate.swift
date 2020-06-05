import UIKit
import Flutter
import AudioKit
import flutter_downloader

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    lazy var audioPlugin = AudioPlugin()
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        setupPlatformChannels()
        FlutterDownloaderPlugin.setPluginRegistrantCallback { registry in
            if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
                FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin"))
            }
        }
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
            
            self.initSet(call: call,result: result)
            return
        }else if call.method == "playSet" {
            self.playSet(call: call, result: result)
            return
        }else if call.method == "pauseSet" {
            self.pauseSet(call: call, result: result)
            return
        }else if call.method == "changeStemVolume" {
            self.changeStemVolume(call: call, result: result)
            return
        }else{
            result(FlutterMethodNotImplemented)
        }
    }
    private func changeStemVolume(call: FlutterMethodCall, result: @escaping FlutterResult){
        guard let args = call.arguments as? [String: Any] else {
            result(false)
            return
        }
        if let name = args["name"] as? String, let volume = args["volume"] as? Double{
            self.audioPlugin.changeStemVolume(name: name,volume: volume)
            result(true)
        }else{
            result(false)
        }
    }
    private func playSet(call: FlutterMethodCall, result: @escaping FlutterResult){
        guard let args = call.arguments as? [String: Any] else {
            result(false)
            return
        }
         NSLog("\nINITIALIZE PLAYING SET")
        if let name = args["name"] as? String {
            let success = self.audioPlugin.playSet(name: name)
            result(success)
            return
        }else{
            result(false)
        }
    }
    private func pauseSet(call: FlutterMethodCall, result: @escaping FlutterResult){
           NSLog("\nPAUSING PLAYERS")
           guard let args = call.arguments as? [String: Any] else {
               result(false)
               return
           }
           if let name = args["name"] as? String {
               let success = self.audioPlugin.pauseSet(name: name) as Bool
               result(success)
           }else{
               result(false)
           }
       }
       
    
    private func initSet(call: FlutterMethodCall, result: @escaping FlutterResult){
        guard let args = call.arguments as? [String: Any] else {
            result(false)
            return
        }
        if let name = args["name"] as? String, let paths = args["paths"]  as? Array<String>{
            let success = self.audioPlugin.initSet(name: name,paths: paths)
            result(success)
            return
        }else{
            result(false)
        }
    }
    
    private func getPlatformVersion(result: @escaping FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
    }
    
}
