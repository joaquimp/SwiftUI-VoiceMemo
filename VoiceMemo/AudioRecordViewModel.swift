//
//  AudioRecordVM.swift
//  VoiceMemo
//
//  Created by Joaquim Pessoa Filho on 11/09/24.
//

// adapted to https://github.com/App-Lobby/CO-Voice

import Foundation
import AVFoundation
import Combine

@Observable
class AudioRecordViewModel: NSObject, AVAudioPlayerDelegate {
    private var audioRecorder: AVAudioRecorder!
    private var audioPlayer: AVAudioPlayer?
    private var fileName: URL?
    private(set) var recordTime: String = "00:00:0"
    private var timer:Timer?
    private var timeInterval: TimeInterval = TimeInterval()
    
    
    @ObservationIgnored
    var hasAudio: Bool {
        return fileName != nil
    }
    
    var isRecording: Bool = false
    var isPlaying: Bool = false
    
    func startRecording() {
        self.reset()
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Recoding setting session: \(error)")
        }
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileName = path.appendingPathComponent("\(UUID().uuidString).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 1200,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        if let fileName = self.fileName {
            do {
                audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
                audioRecorder.prepareToRecord()
                audioRecorder.record()
                isRecording = true
                self.timeInterval = TimeInterval()
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { timer in
                    self.timeInterval = self.timeInterval + timer.timeInterval
                    self.recordTime = self.timeInterval.toString()
                })
            } catch {
                print("start recoding: \(error)")
                reset()
            }
        }
    }
    
    func stopRecording() {
        timer?.invalidate()
        timer = nil
        audioRecorder.stop()
        isRecording = false
    }
    
    func startPlaying(audioData: Data) {
        let playSession = AVAudioSession.sharedInstance()
        
        do {
            try playSession.setCategory(.playback)
        } catch {
            print("Setting Player category: \(error)")
        }
        
        do {
            audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Start Audio Player: \(error)")
        }
    }
    
    func startPlaying() {
        guard let audioData = getAudioData() else { return }
        self.startPlaying(audioData: audioData)
    }
    
    func stopPlaying() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    private func deleteRecording() {
        guard let fileName = fileName else { return }
        self.stopPlaying()
        self.stopRecording()
        try? FileManager.default.removeItem(at: fileName)
        self.fileName = nil
    }
    
    func reset() {
        deleteRecording()
        recordTime = "00:00:0"
    }
    
    func getAudioData() -> Data? {
        guard let fileName = fileName else { return nil }
        
        return try? Data(contentsOf: fileName)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayer = nil
        isPlaying = false
    }
    
    deinit {
        self.deleteRecording()
    }
}
