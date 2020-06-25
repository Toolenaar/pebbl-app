//
//  AudioPlugin.swift
//  Runner
//
//  Created by jochem toolenaar on 20/05/2020.
//
import AudioKit
import Foundation
class AudioPlugin {
    
    var sets: [String: Array<String>] = [:]
    
    var refPlayer: AKPlayer?
    var activeAudioPlayers: [String: AKPlayer]?
    var playerEventSink: FlutterEventSink?
    
    // var activeAudioPlayers:Array<AKPlayer>?
    var mixer:AKMixer?
    var booster:AKBooster?
    
    var currentSet: String?
    
    //SETUP
    func initSet(name:String, paths: Array<String>) -> Bool{
        NSLog("\nSETTING UP SET \(name)")
        //setup each stem
        sets[name] = paths
        if let set = sets[name]{
            do {
                try setupStems(stems: set)
                
                if let players = activeAudioPlayers {
                    mixer = AKMixer(players.map{$0.value})
                    booster = AKBooster(mixer)
                    AudioKit.output = booster
                    AKSettings.playbackWhileMuted = true
                    try AudioKit.start()
                }else{
                    return false
                }
            } catch {
                return false
            }
            return true
        } 
        return false
    }
    
    func updatePlayerState(state:String){
        guard let eventSink =  playerEventSink else {
            return
        }
        eventSink(state)
    }
    
    private func setupStems(stems: Array<String>) throws{
        activeAudioPlayers = [String: AKPlayer]()
        for stem in stems {
            try self.setupStem(path: stem)
        }
    }
    
    private func setupStem(path:String) throws{
        let file = try AKAudioFile(readFileName: path, baseDir: AKAudioFile.BaseDirectory.documents)
        let player = AKPlayer(audioFile: file)
        player.isLooping = false
        player.buffering = .always
        player.volume = 1.0
        activeAudioPlayers?[path] = player
    }
    
    // PLAYBACK
    func pauseSet(name:String) -> Bool{
        if let players = activeAudioPlayers{
            do {
                try pausePlayers(players:players.map{$0.value})
            } catch {
                return false
            }
            
            return true
        }
        return false
    }
    func playSet(name:String) -> Bool{
        NSLog("\nSTART PLAYING SET \(name)")
        currentSet = name
        if let players = activeAudioPlayers{
            do {
                try playPlayers(players:players.map{$0.value})
            } catch {
                NSLog("\nERROR PLAYING SET \(name)")
                return false
            }
            NSLog("\nPLAYING SET  \(name)")
            return true
        }
        return false
    }
    
    private func playPlayers(players: Array<AKPlayer>) throws{
        
        players[0].completionHandler = completed
        refPlayer = players[0]
        for player in players {
            try self.playStem(player: player)
        }
        updatePlayerState(state: "started")
    }
    private func completed(){
        updatePlayerState(state: "completed")
    }
    private func pausePlayers(players: Array<AKPlayer>) throws{
        
        for player in players {
            try self.pauseStem(player: player)
        }
        updatePlayerState(state: "stopped")
    }
    
    func playStem(player:AKPlayer) throws {
        player.play()
    }
    func pauseStem(player:AKPlayer) throws {
        player.stop()
    }
    func changeStemVolume(name:String,volume:Double){
        NSLog("\nCHANGING VOLUME \(name)")
        if let player = activeAudioPlayers?[name] {
            player.volume = volume
        }
    }
}
