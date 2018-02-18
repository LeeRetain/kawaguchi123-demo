//
//  ViewController.swift
//  kawaguchi234
//
//  Created by Lee on 2018/2/17.
//  Copyright © 2018年 CoreDLE. All rights reserved.
//

import UIKit
import Speech

@available(iOS 10.0, *)
class ViewController: UIViewController , SFSpeechRecognizerDelegate, SFSpeechRecognitionTaskDelegate {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var button: UIButton!
    
    
    // MARK: Properties
    // The Locale setting is based on setting of iOS.
    fileprivate let speechRecognizer = SFSpeechRecognizer()!
    fileprivate var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    fileprivate var recognitionTask: SFSpeechRecognitionTask?
    var audioEngine = AVAudioEngine()
    
    fileprivate var recognizedText = ""
    fileprivate var recognitionLimiter: Timer?
    
    //(maximum time 60 seconds is Apple's limit time)
    fileprivate var recognitionLimitSec: Int = 60
    
    fileprivate var noAudioDurationTimer: Timer?
    fileprivate var noAudioDurationLimitSec: Int = 2
    fileprivate var status: String = ""
    fileprivate var localeIdentifier: String?

    @IBAction func buttonClicked(_ sender: Any) {
        _ = self.recordButtonTapped("ja-JP")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioEngine = AVAudioEngine()
        self.initializeAVAudioSession()
        
        _ = isEnabled()
    }

    open func isEnabled() -> Bool {
        if (self.status != "authorized") {
            SFSpeechRecognizer.requestAuthorization { authStatus in
                OperationQueue.main.addOperation {
                    switch authStatus {
                    case .authorized:
                        self.status = "authorized"
                    case .denied:
                        self.status = "denied"
                    case .restricted:
                        self.status = "restricted"
                    case .notDetermined:
                        self.status = "notDetermined"
                    }
                }
            }
        }
        return self.status == "authorized"
    }
    
    fileprivate func startRecording() throws {
        self.setIsTapStart(isTapStart: true)
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = self.getInputNode()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: (self.localeIdentifier)!))
        
        recognizer?.recognitionTask(with: recognitionRequest, delegate: self)
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    // Tells the delegate that a hypothesized transcription is available.
    open func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
        self.recognizedText = transcription.formattedString
        self.stopNoAudioDurationTimer()
        self.startNoAudioDurationTimer()
        self.setTextToMessageInputView(content: transcription.formattedString)
    }
    
    // Tells the delegate when the final utterance is recognized.
    open func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
        self.recognizedText = recognitionResult.bestTranscription.formattedString
        self.setTextToMessageInputView(content: recognitionResult.bestTranscription.formattedString)
    }
    
    // Tells the delegate when the recognition of all requested utterances is finished.
    open func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        self.stopNoAudioDurationTimer()
        //self.onFinalDelegate?.onFinal(self.recognizedText)
    }
    
    // speech recognition start/stop.
    open func recordButtonTapped(_ locale: String) -> String {
        var result = ""
        self.localeIdentifier = locale
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            result = self.recognizedText
            let inputNode = self.getInputNode()
            inputNode.removeTap(onBus: 0)
            self.stopTimer()
            self.setIsTapStart(isTapStart: false)
        }
        else {
            self.recognizedText = ""
            try! startRecording()
            self.startTimer()
            self.setIsTapStart(isTapStart: true)
        }
        return result
    }
    
    func supportedLocales() -> Set<Locale> {
        let ret : Set = SFSpeechRecognizer.supportedLocales()
        return ret
    }
    
    func startTimer() {
        recognitionLimiter = Timer.scheduledTimer(
            timeInterval: TimeInterval(self.recognitionLimitSec),
            target: self,
            selector:#selector(InterruptEvent),
            userInfo: nil,
            repeats: false
        )
    }
    
    func stopTimer() {
        if recognitionLimiter != nil {
            recognitionLimiter?.invalidate()
            recognitionLimiter = nil
        }
    }
    
    func startNoAudioDurationTimer() {
        self.stopTimer()
        noAudioDurationTimer = Timer.scheduledTimer(
            timeInterval: TimeInterval(self.noAudioDurationLimitSec),
            target: self,
            selector:#selector(InterruptEvent),
            userInfo: nil,
            repeats: false
        )
    }
    
    func stopNoAudioDurationTimer() {
        if noAudioDurationTimer != nil {
            noAudioDurationTimer?.invalidate()
            noAudioDurationTimer = nil
        }
    }
    
    @objc func InterruptEvent() {
        var result = ""
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            result = self.recognizedText
        }
        let inputNode = self.getInputNode()
        inputNode.removeTap(onBus: 0)
        self.recognitionRequest = nil
        self.recognitionTask = nil
        recognitionLimiter = nil
        noAudioDurationTimer = nil
        self.resetAVAudioSession()
        self.setTextToMessageInputView(content: result)
        self.setIsTapStart(isTapStart: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [unowned self] in
           _ = self.recordButtonTapped("ja-JP")
        }
    }
    
    func setTextToMessageInputView(content :String){
        textView.text = content
        print("resutl:\(content)")
    }
    
    func setIsTapStart(isTapStart: Bool){
        if isTapStart {
            self.button.setTitle("stop", for: .normal)
        }
        else{
            self.button.setTitle("start", for: .normal)
        }
    }
    
    /** AVAudioSession initialize. */
    func initializeAVAudioSession() {
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        try! AVAudioSession.sharedInstance().setActive(false)
    }
    
    /** AVAudioSession End processing. */
    func resetAVAudioSession() {
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
    }
    
    func getInputNode() -> AVAudioInputNode {
        guard let inputNode = audioEngine.inputNode as Optional else { fatalError("Audio engine has no input node") }
        return inputNode
    }
    
    deinit {
        stopTimer()
        stopNoAudioDurationTimer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

