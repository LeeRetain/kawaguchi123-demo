//
//  ATOMMessageInputView.swift
//  SwiftHaveOC
//
//  Created by Lee on 2018/2/3.
//  Copyright © 2018年 CoreDLE. All rights reserved.
//

import UIKit

let kMessageInputView_HeightMax    = CGFloat(88)
let kMessageInputView_Height       = CGFloat(50)
let kMessageInputView_PadingHeight = CGFloat(7)
let kMessageInputView_PadingLeft   = CGFloat(7)
let kMessageInputView_Padingright  = CGFloat(60)

// type
enum ATOMMessageType {
    case ATOMMessageType_Voice
    case ATOMMessageType_Send
}

// delegateを初期化
protocol ATOMMessageInputViewDelegate : NSObjectProtocol {
    func atomMessageInputViewWithInputViewHeightChanged(_ currentView:ATOMMessageInputView, heightToBottomChanged:CGFloat)
    func atomMessageInputViewWithDidClickedVoiceButton(_ currentView:ATOMMessageInputView)
    func atomMessageInputViewWithDidClickedSendButton(_ currentView:ATOMMessageInputView)
}

class ATOMMessageInputView: UIView {
    
    // delegate
    weak var delegate : ATOMMessageInputViewDelegate?
    
    // oldHeight
    var viewHeightOld : CGFloat = 0.0
    
    // inputViewFrame
    var inputViewFrame:CGRect = CGRect(x:0,y:0,width:0,height:0){
        didSet{
            let duoyu = kScreen_Height-KTabbarSafeBottomMargin-kStatusBarAndNavBarHeight
            let oldheightToBottom = duoyu - self.frame.origin.y;
            let newheightToBottom = duoyu - inputViewFrame.origin.y;
            self.frame = inputViewFrame
            if (fabs(oldheightToBottom - newheightToBottom) > 1.0) {
                if (oldheightToBottom > newheightToBottom) {//down↓
//                    [self saveInputStr];
                }
                delegate?.atomMessageInputViewWithInputViewHeightChanged(self, heightToBottomChanged: newheightToBottom)
            }
        }
    }
    
    // messageType
    var messageType: ATOMMessageType = ATOMMessageType.ATOMMessageType_Voice{
        didSet{
            if messageType == .ATOMMessageType_Voice {
                // voice
                sendORVoiceButton.setImage(UIImage(named:"keyboard_voice"), for: .normal)
            }
            else if messageType == .ATOMMessageType_Send{
                // send
                sendORVoiceButton.setImage(UIImage(named:"keyboard_emotion_emoji"), for: .normal)
            }
        }
    }
    
    // contentView
    let contentViewWidth  = kScreen_Width-kMessageInputView_Padingright
    let contentViewHeight = kMessageInputView_Height-2*kMessageInputView_PadingHeight
    
    lazy var contentView: UIScrollView = { [unowned self] in
       var scrollView = UIScrollView()
        scrollView.frame = CGRect(x:kMessageInputView_PadingLeft ,y:kMessageInputView_PadingHeight, width: contentViewWidth, height:self.height-2*kMessageInputView_PadingHeight)
        scrollView.backgroundColor = UIColor.white
        scrollView.layer.borderColor = UIColor.lightGray.cgColor
        scrollView.layer.borderWidth = 0.5
        scrollView.layer.cornerRadius = (CGFloat)(contentViewHeight/2)
        scrollView.layer.masksToBounds = true
        scrollView.alwaysBounceVertical = true
        scrollView.addSubview(inputTextView)
        return scrollView
    }()
    
    // inputView
    lazy var inputTextView: ATOMPlaceHolderTextView = { [unowned self] in
        var inputView = ATOMPlaceHolderTextView()
        inputView.frame = CGRect(x:0, y:0, width: contentViewWidth, height:contentViewHeight)
        inputView.font = UIFont.systemFont(ofSize: 16)
        inputView.returnKeyType = .default
        inputView.scrollsToTop = false
        inputView.delegate = self
        inputView.placeholder = "Aa"
        var edgeInsets = inputView.textContainerInset
        edgeInsets.left  += 8.0
        edgeInsets.right += 8.0
        inputView.textContainerInset = edgeInsets
        return inputView
    }()
    
    // sendButton or VoiceButton
    lazy var sendORVoiceButton: UIButton = { [unowned self] in
        let button = UIButton(type:.custom)
        let buttonImage = UIImage(named:"keyboard_voice")
        let buttonSize = buttonImage?.size
        let buttonX = kMessageInputView_PadingLeft+contentViewWidth+kMessageInputView_Padingright/2-(buttonSize?.width)!/2
        let buttonY = kMessageInputView_Height/2-(buttonSize?.height)!/2
        button.frame = CGRect(x:buttonX, y:buttonY, width:(buttonSize?.width)!, height:(buttonSize?.width)!)
        button.setImage(buttonImage, for: .normal)
        button.adjustsImageWhenDisabled = false
        button.addTarget(self, action: #selector(buttonDidClicked(_ :)), for: .touchUpInside)
        return button
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        inputTextView.removeObserver(self, forKeyPath: "contentSize")
    }
}

// ATOMMessageInputViewを初期化
extension ATOMMessageInputView{
    class func newInstans() -> ATOMMessageInputView {
        let curScreenHeight = CGFloat(UIScreen.main.bounds.height)
        let messageViewY = curScreenHeight-kMessageInputView_Height-kStatusBarAndNavBarHeight-KTabbarSafeBottomMargin
        let rect = CGRect(x:0, y:messageViewY, width:kScreen_Width, height:kMessageInputView_Height)
        let atomMessageView = ATOMMessageInputView()
        atomMessageView.frame = rect
        atomMessageView.layer.shadowColor = UIColor.lightGray.cgColor
        atomMessageView.layer.shadowOpacity = 0.1
        atomMessageView.layer.shadowRadius = 0.2
        atomMessageView.layer.shadowOffset = CGSize(width:0 ,height:-1)
        atomMessageView.viewHeightOld = CGFloat(kMessageInputView_Height)
        atomMessageView.backgroundColor = UIColor.white
        atomMessageView.addSubview(atomMessageView.contentView)
        atomMessageView.addSubview(atomMessageView.sendORVoiceButton)
        atomMessageView.registNotification()
        return atomMessageView
    }
}

// registNotification
extension ATOMMessageInputView{
    
    func isAndResignFirstResponder(){
        if inputTextView.isFirstResponder {
            inputTextView.resignFirstResponder()
        }
    }
    
    func registNotification(){
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardWillShow(_ :)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardWillHide(_ :)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardChangeFrame(_ :)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
        inputTextView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
}

// GetNotification
extension ATOMMessageInputView{
    @objc func keyBoardWillShow(_ notification:Notification){
        if inputTextView.text.isEmpty {
            inputTextView.placeholder = "メッセージを入力"
        }
    }
    
    @objc func keyBoardWillHide(_ notification:Notification){
        if inputTextView.text.isEmpty {
            inputTextView.placeholder = "Aa"
        }
    }
    
    @objc func keyBoardChangeFrame(_ notification:Notification){
        if (notification.name == .UIKeyboardDidChangeFrame) {
            NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidChangeFrame, object: nil)
        }
        if (self.inputTextView.isFirstResponder) {
            let userInfo = notification.userInfo
            let keyboardEndFrame = (userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let keyboardY = keyboardEndFrame.origin.y
            
            let selfOriginY:CGFloat
            if keyboardY == kScreen_Height{
                selfOriginY = kScreen_Height-self.height - CGFloat(kStatusBarAndNavBarHeight) - CGFloat(KTabbarSafeBottomMargin)
            }
            else{
                selfOriginY = keyboardY - self.height - CGFloat(kStatusBarAndNavBarHeight)
            }
            
            if selfOriginY == self.frame.origin.y{
                return;
            }
            
            let changeFrame = { () -> () in
                var tempFrame = self.frame
                tempFrame.origin.y = selfOriginY
                self.inputViewFrame = tempFrame
            }
            
            if (notification.name == .UIKeyboardWillChangeFrame) {
                // 動画時間
                let animationDuration = (userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
                // 動画
                let animationCurve = UIViewAnimationOptions(rawValue: UInt((userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
                UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: {
                    changeFrame()
                },completion: { (aa:Bool) in})
            }
            else{
                changeFrame()
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            updateContentViewFrame()
        }
    }
}

// buttonClicked
extension ATOMMessageInputView{
    @objc func buttonDidClicked(_ button:UIButton){
        if messageType == ATOMMessageType.ATOMMessageType_Voice  {
            // voiceButtonClicked
            delegate?.atomMessageInputViewWithDidClickedVoiceButton(self)
        }
        else{
            // sendButtonClicked
            delegate?.atomMessageInputViewWithDidClickedSendButton(self)
        }
    }
}

// UITextViewDelegate
extension ATOMMessageInputView: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 0 {
            self.messageType = .ATOMMessageType_Send
        }
        else{
            self.messageType = .ATOMMessageType_Voice
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
}

// ATOMMessageInputView ChangeFrame
extension ATOMMessageInputView{
    func updateContentViewFrame(){
        
        let textSize = inputTextView.contentSize
        if abs(inputTextView.frame.size.height-textSize.height) > 0.5{
            inputTextView.height = textSize.height
        }
        var selfHeight = max(kMessageInputView_Height, textSize.height+2*kMessageInputView_PadingHeight)
        selfHeight = min(kMessageInputView_HeightMax, selfHeight)
        let diffHeight = selfHeight - viewHeightOld
        if (abs(diffHeight) > 0.5) {
            var selfFrame = self.frame;
            selfFrame.size.height += CGFloat(diffHeight)
            selfFrame.origin.y -= CGFloat(diffHeight)
            self.inputViewFrame = selfFrame
            self.viewHeightOld = selfHeight;
        }
        let buttonY = selfHeight-CGFloat(kMessageInputView_Height/2)-self.sendORVoiceButton.height/2
        self.sendORVoiceButton.y = buttonY
        self.contentView.contentSize = textSize
        self.contentView.height = selfHeight-CGFloat(2*kMessageInputView_PadingHeight)
        let bottomY = textSize.height;
        let height = self.frame.size.height
        let offsetY = max(0, bottomY - (height - 2*kMessageInputView_PadingHeight))
        self.contentView.setContentOffset(CGPoint(x:0 ,y:offsetY), animated: false)
    }
}
