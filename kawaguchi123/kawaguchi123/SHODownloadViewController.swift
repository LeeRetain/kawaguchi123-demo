//
//  SHODownloadViewController.swift
//  SwiftHaveOC
//
//  Created by Lee on 2018/1/29.
//  Copyright © 2018年 CoreDLE. All rights reserved.
//

import UIKit
import Speech

class SHODownloadViewController: SHOBaseViewController {
    
    @IBOutlet weak var luyinButton: UIButton!
    @IBOutlet weak var showTextView: UITextView!
    
    // 一.
    //首先，我们创建了一个 SFSpeechRecognizer 对象，并指定其 locale identifier 为 en-US，也就是通知语音识别器用户所使用的语言。这个对象将用于语音识别。默认，我们将禁用 microphone 按钮，一直到语音识别器被激活。将语音识别器的 delgate 设为 self，也就是我们的 ViewController。然后，调用 SFSpeechRecognizer.requestAuthorization 获得语音识别的授权。最后，判断授权状态，如果用户已授权，enable 麦克风按钮。否则打印错误信息并禁用麦克风按钮。你可能以为现在运行 app 就能看到用户授权提示了，其实不然。当你运行 app，app 会崩溃。这是什么鬼？
    
    
    // 1.获取用户授权。用户应当允许我们的 app 使用声频输入和语音识别。首先声明一个 speechRecognizer 变量
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ja-JP"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Download"
        
        // 2.
        luyinButton.isEnabled = false
        
        // 3.
        speechRecognizer?.delegate = self
        
        // 4.
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            // 5.
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.luyinButton.isEnabled = isButtonEnabled
            }
        }
    }

    // 二.
    // 搞定用户授权之后，我们来实现语音识别。在 ViewController 中添加如下变量：
    // 这个对象负责发起语音识别请求。它为语音识别器指定一个音频输入源。这个对象用于保存发起语音识别请求后的返回值。通过这个对象，你可以取消或中止当前的语音识别任务。这个对象引用了语音引擎。它负责提供录音输入。
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    func startRecording() {
        
        // recognitionTask 任务是否处于运行状态。如果是，取消任务，开始新的语音识别任
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        // 创建一个 AVAudioSession 用于录音。将它的 category 设置为 record，mode 设置为 measurement，然后开启 audio session。因为对这些属性进行设置有可能导致异常，因此你必须将它们放到 try catch 语句中。
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        }
        catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        // 初始化 recognitionRequest 对象。这里我们创建了一个 SFSpeechAudioBufferRecognitionRequest 对象。在后面，我们会用它将录音数据转发给苹果服务器。
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        // 检查 audioEngine (物理设备) 是否拥有有效的录音设备。如果没有，我们产生一个致命错误。
        let inputNode = audioEngine.inputNode
//        guard let inputNode = audioEngine.inputNode else {
//            fatalError("Audio engine has no input node")
//        }
        
        // 检查 recognitionRequest 对象是否初始化成功，值不为nil。
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        // 告诉 recognitionRequest 在用户说话的同时，将识别结果分批返回。
        recognitionRequest.shouldReportPartialResults = true
        
        // 在 speechRecognizer 上调用 recognitionTask 方法开始识别。方法参数中包括一个完成块。当语音识别引擎每次采集到语音数据、修改当前识别、取消、停止、以及返回最终译稿时都会调用完成块。
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            //定义一个 boolean 变量，用于检查识别是否结束
            var isFinal = false
            
            // 如果 result 不为 nil，将 textView.text 设置为 result 的最佳译稿。如果 result 是最终译稿，将 isFinal 设置为 true。
            if result != nil {
                self.showTextView.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
                
                let indicatorView:ATOMUIActivityIndicatorView?
                if isFinal{
                    indicatorView = ATOMUIActivityIndicatorView.newInstance()
                    indicatorView?.showIndicatorView()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()+6.0, execute: {
                        indicatorView?.hideIndicatorView()
                    })
                }
            }
    
            // 如果没有错误发生，或者 result 已经结束，停止 audioEngine (录音) 并终止 recognitionRequest 和 recognitionTask。同时，使 “开始录音”按钮可用。
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.luyinButton.isEnabled = true
            }
        })
        
        //向 recognitionRequest 加入一个音频输入。注意，可以在启动 recognitionTask 之后再添加音频输入。Speech 框架会在添加完音频输入后立即开始识别。
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        // 预热并启动 audioEngine.
        audioEngine.prepare()
        do {
            try audioEngine.start()
        }
        catch {
            print("audioEngine couldn't start because of an error.")
        }
        showTextView.text = "Say something, I'm listening!"
    }
    
    //当可用状态发生改变时，该方法被调用。只有在语音识别可用的情况下，录音按钮才会启用。
    @IBAction func buttonClicked(_ sender: UIButton) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            luyinButton.isEnabled = false
            luyinButton.setTitle("Start Recording", for: .normal)
        } else {
            startRecording()
            luyinButton.setTitle("Stop Recording", for: .normal)
        }
    }
    
    //在这个方法里，我们必须检查 audioEngine 是否处于运行状态。如果是，app 将停止 audioEngine，停止向 recoginitionRequest 输入音频数据，禁用 microphoneButton 并将按钮标题设置为“开始录音”。如果 audioEngine 未运行，app 调用 startRecording() 并设置按钮标题为“停止录音”。
}

// 代理
extension SHODownloadViewController :SFSpeechRecognizerDelegate{
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            self.luyinButton.isEnabled = true
        } else {
            self.luyinButton.isEnabled = false
        }
    }
}
