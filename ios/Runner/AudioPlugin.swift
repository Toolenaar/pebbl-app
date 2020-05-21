//
//  AudioPlugin.swift
//  Runner
//
//  Created by jochem toolenaar on 20/05/2020.
//
import AudioKit
import Foundation
class AudioPlugin {
    
    var sets: [String: Array<String>] = [
        "test":["test_1_0Core.mp3","test_1_1low.mp3","test_1_3blink.mp3","test_1_4birds.mp3","test_1_paars.mp3"]
    ]
    
    var activeAudioPlayers: [String: AKPlayer]?
    
    // var activeAudioPlayers:Array<AKPlayer>?
    var mixer:AKMixer?
    var booster:AKBooster?
    
    //SETUP
    func initSet(name:String) -> Bool{
        NSLog("\nSETTING UP SET \(name)")
        //setup each stem
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
    private func setupStems(stems: Array<String>) throws{
        activeAudioPlayers = [String: AKPlayer]()
        for stem in stems {
            try self.setupStem(name: stem)
        }
    }
    
    private func setupStem(name:String) throws{
        let file = try AKAudioFile(readFileName: name)
        let player = AKPlayer(audioFile: file)
        player.isLooping = true
        player.buffering = .always
        player.volume = 1.0
        activeAudioPlayers?[name] = player
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
        for player in players {
            try self.playStem(player: player)
        }
    }
    private func pausePlayers(players: Array<AKPlayer>) throws{
        for player in players {
            try self.pauseStem(player: player)
        }
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
