//
//  SHOTestViewController.swift
//  SwiftHaveOC
//
//  Created by Lee on 2018/2/3.
//  Copyright © 2018年 CoreDLE. All rights reserved.
//

import UIKit

class SHOTestViewController: SHOBaseViewController {

    var dataArray:[ATOMMessageModel] = [ATOMMessageModel]()
    
    var senderView = UIView()
    
    // tableview
    lazy var tableView: UITableView = {[unowned self] in
        let rect = CGRect(x:0, y:0,width:kScreen_Width,height:kScreen_Height-KTabbarSafeBottomMargin-kStatusBarAndNavBarHeight)
        let tab = UITableView(frame: rect ,style:.plain)
        tab.delegate = self
        tab.dataSource = self
        tab.separatorStyle = .none
        tab.showsHorizontalScrollIndicator = true
        tab.keyboardDismissMode = .onDrag
        tab.register(ATOMMessageCell.self, forCellReuseIdentifier: "ATOMMessageCell")
        return tab
        }()
    
    // messageView
    lazy var messageInputView: ATOMMessageInputView = {
        let messageView = ATOMMessageInputView.newInstans()
        return messageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "test"
        let url0 = "http://120.25.225.17:8182/bianxing/user/sendSms.do"
        var jsonObject0 = Dictionary<String, Any>()
        //jsonObject["smsCode"] = "1019"
        jsonObject0["mobile"] = "15840004567"
        //        jsonObject["mobile"]  = "15840004567"
       // jsonObject0["15840004567"]  = "mobile"
        
        ATOMNetApIManager.sharedInstance.post(url: url0, postParameter: jsonObject0, isPost:true)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.25) {
            let url = "http://120.76.47.52:8080/bianxing/user/mobileLogin.do"
            var jsonObject = Dictionary<String, Any>()
            //jsonObject["smsCode"] = "1019"
            jsonObject["1019"] = "smsCode"
            //        jsonObject["mobile"]  = "15840004567"
            jsonObject["15840004567"]  = "mobile"
            //        jsonObject["start"] = "0"
            //        jsonObject["from"]  = "iOS"
            //        jsonObject["apiVersion"]  = "3.1.2"
            
            //        jsonObject["smsCode"] = "1019"
            //        jsonObject["mobile"]  = "15840004567"
            ////        jsonObject["start"] = "0"
            //        jsonObject["from"]  = "iOS"
            //        jsonObject["apiVersion"]  = "3.1.2"
            
            ATOMNetApIManager.sharedInstance.post(url: url, postParameter: jsonObject, isPost:false)
            
        }
        
        for i in 0..<10 {
            let atomData = ATOMMessageModel()
            if i%2 == 0{
                atomData.isSend = true
                atomData.content = "hhhhhhhshshshshhshsshjdh\nsdhjsahdjashdashdjashdjashdjasdhajs"
                atomData.date = "1518253757"
            }
            else{
                atomData.isSend = false
                atomData.content = "hhhhhhhshshshshhshsshjdh\nsdhjs"
                atomData.date = "1515253757"
            }
            dataArray.append(atomData)
        }
        
        // 1.
        self.view.addSubview(tableView)
        
        // 2.
        if kDevice_Is_iPhoneX {
            let bottomView = UIView()
            bottomView.backgroundColor = UIColor.white
            bottomView.frame = CGRect(x:0, y:kScreen_Height-kStatusBarAndNavBarHeight-KTabbarSafeBottomMargin-50 ,width:kScreen_Width ,height:KTabbarSafeBottomMargin+50)
            self.view.addSubview(bottomView)
        }
        
        // 3.
        messageInputView.delegate = self
        self.view.addSubview(messageInputView)
        
        let contentInsets = UIEdgeInsetsMake(0, 0,messageInputView.frame.size.height, 0);
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = contentInsets;
        
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) { [unowned self] in
            self.scrollToBottomAnimated()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        messageInputView.isAndResignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// ATOMMessageInputViewDelegate
extension SHOTestViewController : ATOMMessageInputViewDelegate{
    // clickedVoiceButton
    func atomMessageInputViewWithDidClickedVoiceButton(_ currentView: ATOMMessageInputView) {

        print("voice")
    }

    // clickedSendButton
    func atomMessageInputViewWithDidClickedSendButton(_ currentView: ATOMMessageInputView) {

        print("send")
    }

    // InputViewHeightChanged
    func atomMessageInputViewWithInputViewHeightChanged(_ currentView: ATOMMessageInputView, heightToBottomChanged: CGFloat) {
    
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, max(currentView.frame.size.height, heightToBottomChanged), 0.0);
        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets

        struct messagePro{
            static var keyboard_is_down = true
            static var keyboard_down_ContentOffset:CGPoint?
            static var keyboard_down_InputViewHeight:CGFloat?
        }
        if heightToBottomChanged > currentView.frame.size.height+KTabbarSafeBottomMargin {
            if messagePro.keyboard_is_down {
                messagePro.keyboard_down_ContentOffset = self.tableView.contentOffset
                messagePro.keyboard_down_InputViewHeight = currentView.frame.size.height
            }
            messagePro.keyboard_is_down = false
            var contentOffset:CGPoint = messagePro.keyboard_down_ContentOffset!
            let spaceHeight = max(0, self.tableView.frame.size.height - self.tableView.contentSize.height-messagePro.keyboard_down_InputViewHeight!)
            contentOffset.y += max(0, heightToBottomChanged - messagePro.keyboard_down_InputViewHeight! - spaceHeight)
            self.tableView.contentOffset = contentOffset
        }
        else{
            messagePro.keyboard_is_down = true
        }
    }
}

extension SHOTestViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let editCommenCell = tableView.dequeueReusableCell(withIdentifier: "ATOMMessageCell") as! ATOMMessageCell
        editCommenCell.selectionStyle = .none
        
        let curIndex = (dataArray.count-1)-indexPath.row
        let curMsg = dataArray[curIndex]
        var preMsg = ATOMMessageModel()
        if  curIndex+1 < dataArray.count {
            preMsg = dataArray[curIndex+1]
        }
        editCommenCell.setMessage(curPriMsg: curMsg, prePriMsg: preMsg)
        
        return editCommenCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let curIndex = (dataArray.count-1)-indexPath.row
        var preMsg = ATOMMessageModel()
        if  curIndex+1 < dataArray.count {
            preMsg = dataArray[curIndex+1]
        }
        return ATOMMessageCell.getCellHieght(curObj: dataArray[curIndex], preObj:preMsg)
    }
}

extension SHOTestViewController{
    func scrollToBottomAnimated(){
        let rows = self.tableView.numberOfRows(inSection: 0)
        if  rows > 0 {
            self.tableView.scrollToRow(at: IndexPath(row:rows-1,section:0), at: .bottom, animated: false)
        }
    }
}
