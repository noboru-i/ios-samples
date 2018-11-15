//
//  SpeechViewController.swift
//  iossamples
//
//  Created by noboru-i on 2018/11/14.
//  Copyright (c) 2018 noboru-i. All rights reserved.
//

import UIKit
import Speech

// refer from https://dev.classmethod.jp/smartphone/iphone/try-ios10-speech-recognizer/
class SpeechViewController: UIViewController {

    @IBOutlet weak var recognizeButton: UIButton!
    @IBOutlet weak var label: UILabel!

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    override func viewDidLoad() {
        super.viewDidLoad()

        speechRecognizer.delegate = self
        requestRecognizerAuthorization()
    }

    @IBAction func onClickRecognize(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recognizeButton.isEnabled = false
            recognizeButton.setTitle("stopping", for: .disabled)
        } else {
            try! startRecording()
            recognizeButton.setTitle("stop voice recognize", for: [])
        }
    }

    private func requestRecognizerAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation { [weak self] in
                guard let `self` = self else { return }

                switch authStatus {
                case .authorized:
                    self.recognizeButton.isEnabled = true
                case .denied:
                    self.recognizeButton.isEnabled = false
                    self.recognizeButton.setTitle("voice recognition is denied.", for: .disabled)
                case .restricted:
                    self.recognizeButton.isEnabled = false
                    self.recognizeButton.setTitle("this device cannot use voice recognition.", for: .disabled)
                case .notDetermined:
                    self.recognizeButton.isEnabled = false
                    self.recognizeButton.setTitle("voice recognition is not allowed yet.", for: .disabled)
                }
            }
        }
    }

    private func startRecording() throws {
        refreshTask()

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSession.Category.record, mode: AVAudioSession.Mode.default)
        try audioSession.setMode(AVAudioSession.Mode.measurement)
        try audioSession.setActive(true)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let `self` = self else { return }

            var isFinal = false
            if let result = result {
                self.label.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }

            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.recognizeButton.isEnabled = true
                self.recognizeButton.setTitle("start voice recognize", for: [])
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }

        try startAudioEngine()
    }

    private func refreshTask() {
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
    }

    private func startAudioEngine() throws {
        audioEngine.prepare()

        try audioEngine.start()
        label.text = "Please start speaking."
    }
}

extension SpeechViewController: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recognizeButton.isEnabled = true
            recognizeButton.setTitle("start voice recognize", for: [])
        } else {
            recognizeButton.isEnabled = false
            recognizeButton.setTitle("stop voice recognize", for: .disabled)
        }
    }
}
