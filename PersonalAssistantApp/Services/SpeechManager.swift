//
//  SpeechManager.swift
//  PersonalAssistantApp
//
//  Created by Ayşe Fulya on 20.10.2025.
//


import Foundation
import Speech
import AVFoundation

class SpeechManager: NSObject, ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "tr-TR"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @Published var isRecording = false
    @Published var recognizedText = ""
    @Published var errorMessage = ""
    
    override init() {
        super.init()
    }
    
    func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("✅ Ses tanıma izni verildi")
                case .denied:
                    self.errorMessage = "Ses tanıma reddedildi. Ayarlardan izin verin."
                    print("❌ Ses tanıma izni reddedildi")
                case .restricted:
                    self.errorMessage = "Ses tanıma kısıtlı"
                    print("❌ Ses tanıma kısıtlı")
                case .notDetermined:
                    print("⏳ Ses tanıma belirlenmedi")
                @unknown default:
                    print("❌ Bilinmeyen ses tanıma durumu")
                }
            }
        }
    }
    
    func startRecording() {
        guard !isRecording else { return }
        
        recognitionTask?.cancel()
        recognitionTask = nil
        recognizedText = ""
        errorMessage = ""
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(
                .record,
                mode: .measurement,
                options: .duckOthers
            )
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Ses oturumu ayarlanamadı"
            print("❌ Ses oturumu hatası: \(error)")
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            errorMessage = "Tanıma isteği oluşturulamadı"
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            var isFinal = false
            
            if let result = result {
                DispatchQueue.main.async {
                    self.recognizedText = result.bestTranscription.formattedString
                }
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                DispatchQueue.main.async {
                    self.isRecording = false
                }
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            isRecording = true
            print("🎤 Ses kaydı başladı")
        } catch {
            errorMessage = "Ses kaydı başlatılamadı"
            print("❌ Ses kaydı hatası: \(error)")
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        isRecording = false
        
        print("🎤 Ses kaydı durduruldu")
    }
    
    func reset() {
        recognizedText = ""
        errorMessage = ""
    }
}
