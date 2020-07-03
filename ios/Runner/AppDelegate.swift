import UIKit
import Flutter
import AudioKit
import flutter_downloader
import AVFoundation
import MediaPlayer

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate,FlutterStreamHandler {
    
    
    //https://medium.com/@quangtqag/background-audio-player-sync-control-center-516243c2cdd1
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
        
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            if #available(iOS 10.0, *) {
                try audioSession.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
            } else {
                // Fallback on earlier versions
            }
        } catch let error as NSError {
            print("Setting category to AVAudioSessionCategoryPlayback failed: \(error)")
        }
        
      
        setupRemoteTransportControls()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func applicationWillTerminate(_ application: UIApplication) {
        audioPlugin.dispose()
        
        do {
            try AudioKit.stop()
            try AudioKit.shutdown()
        } catch  let error as NSError {
            NSLog("\n \(error)")
        }
       
    }
    
    //Stream handlers
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        audioPlugin.playerEventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        audioPlugin.playerEventSink = nil
           return nil
    }
    
   
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            
            if let set = self.audioPlugin.currentSet {
                let success = self.audioPlugin.pauseSet(name: set)
                if(success){
                    return .success
                }
            }
            
            return .commandFailed
        }

        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if let set = self.audioPlugin.currentSet {
                let success = self.audioPlugin.playSet(name: set)
                if(success){
                    return .success
                }
            }
            return .commandFailed
        }
    }
    
    func setupNowPlaying(setName:String) {
        // Define Now Playing Info
        if let player = audioPlugin.refPlayer{
            var nowPlayingInfo = [String : Any]()
                
            if let image = UIImage(named: "cat") {
                if #available(iOS 10.0, *) {
                    nowPlayingInfo[MPMediaItemPropertyArtwork] =
                        MPMediaItemArtwork(boundsSize: image.size) { size in
                            return image
                    }
                } else {
                    // Fallback on earlier versions
                }
                  }
            
            nowPlayingInfo[MPMediaItemPropertyTitle] = setName
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.duration
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
            // Set the metadata
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            
        }
      
    }
    
   
    
    func setupPlatformChannels(){
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let audioChannel = FlutterMethodChannel(name: "pebbl_plugin/audio",
                                                binaryMessenger: controller.binaryMessenger)
        
        audioChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            self.handleResult(call: call, result:result)
        })
        
        let playbackEventChannel = FlutterEventChannel(name: "pebbl_plugin/playback",
                                                     binaryMessenger: controller.binaryMessenger)
           playbackEventChannel.setStreamHandler(self)
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
            if(success){
                self.setupNowPlaying(setName: name)
            }
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
