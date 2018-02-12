//
//  ATOMMessageCell.swift
//  SwiftHaveOC
//
//  Created by Lee on 2018/2/10.
//  Copyright © 2018年 CoreDLE. All rights reserved.
//

let isShowTitleTime:Bool  = true
let isShowDetailTime:Bool = true
let isShowMeIcon:Bool     = false

let kPaddingLeftWidth = CGFloat(15)

let kMessageCell_FontContent  = UIFont.systemFont(ofSize: 15)
let kMessageCell_PadingWidth  = CGFloat(20)
let kMessageCell_PadingHeight = CGFloat(11)
let kMessageCell_ContentWidth = CGFloat(kScreen_Width*0.6)
let kMessageCell_TimeHeight   = CGFloat(40)
let kMessageCell_UserIconWith = CGFloat(40)
let kMessageCell_DetailTimeHeight = CGFloat(20)
let kMessageCell_DetailTimeWidth  = CGFloat(40)

import UIKit

class ATOMMessageCell: UITableViewCell {

    var curMessage  :ATOMMessageModel?
    var preMessage  :ATOMMessageModel?
    var userIcon    :UIImageView?
    var bgImgView   :UIImageView?
    var contentLabel:UILabel?
    var timeLabel   :UILabel?
    var detailTimeLabel   :UILabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        if  self.userIcon == nil {
            self.userIcon = UIImageView(image: UIImage(named: "head"))
            self.userIcon?.frame = CGRect(x:0,y:0,width:kMessageCell_UserIconWith,height:kMessageCell_UserIconWith)
            self.userIcon?.layer.cornerRadius = kMessageCell_UserIconWith/2
            self.userIcon?.layer.masksToBounds = true
            self.contentView.addSubview(self.userIcon!)
        }
        if self.bgImgView == nil {
            bgImgView = UIImageView()
            bgImgView?.frame = CGRect(x:0,y:0,width:0,height:0)
            self.contentView.addSubview(self.bgImgView!)
        }
        if self.contentLabel == nil {
            self.contentLabel = UILabel()
            self.contentLabel?.frame = CGRect(x:kMessageCell_PadingWidth,y:kMessageCell_PadingHeight,width:0,height:0)
            self.contentLabel?.numberOfLines = 0
            self.contentLabel?.font = kMessageCell_FontContent
            self.contentLabel?.textColor = UIColor.black
            self.contentLabel?.backgroundColor = UIColor.clear
            self.bgImgView?.addSubview(self.contentLabel!)
        }
        
        if self.detailTimeLabel == nil && isShowDetailTime{
            self.detailTimeLabel = UILabel()
            self.detailTimeLabel?.frame = CGRect(x:0,y:0,width:kMessageCell_DetailTimeWidth,height:kMessageCell_DetailTimeHeight)
            self.detailTimeLabel?.numberOfLines = 0
            self.detailTimeLabel?.font = kMessageCell_FontContent
            self.detailTimeLabel?.textColor = UIColor.black
            self.detailTimeLabel?.backgroundColor = UIColor.clear
            self.detailTimeLabel?.textAlignment = .center
            self.contentView.addSubview(self.detailTimeLabel!)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension ATOMMessageCell{
    func setMessage(curPriMsg:ATOMMessageModel, prePriMsg:ATOMMessageModel){
        
        if curMessage == curPriMsg && preMessage == prePriMsg {
            configSendStatus()
            return
        }
        else{
            curMessage = curPriMsg
            preMessage = prePriMsg
        }
        if curMessage==nil {
            return
        }
        
        var curBottomY:CGFloat = 0
        if isShowTitleTime {
            let time = ATOMMessageCell.displayTimeStrWithCurMsg(curMsg: curMessage!, preMsg: preMessage!)
            if !time.isEmpty {
                if self.timeLabel == nil{
                    self.timeLabel = UILabel(frame:CGRect(x:kPaddingLeftWidth,y:(kMessageCell_TimeHeight-20)/2,width:kScreen_Width-2*kPaddingLeftWidth,height:20))
                    self.timeLabel?.backgroundColor = UIColor.clear
                    self.timeLabel?.font = UIFont.systemFont(ofSize: 12)
                    self.timeLabel?.textColor = UIColor.lightGray
                    self.timeLabel?.textAlignment = .center
                    self.contentView.addSubview(self.timeLabel!)
                }
                self.timeLabel?.isHidden = false
                self.timeLabel?.text = time
                curBottomY += kMessageCell_TimeHeight
            }
            else{
                self.timeLabel?.isHidden = true
            }
        }
        
        var bgImg         :UIImage?
        var bgImgViewSize :CGSize?
        var bgImgViewFrame:CGRect;
        var textSize      :CGSize?
        
        if curMessage?.content != nil {
            textSize = ATOMMessageCell.getStringSize(content: (curMessage?.content!)!, font: kMessageCell_FontContent, constrainedToSize: CGSize(width:kMessageCell_ContentWidth,height:CGFloat.greatestFiniteMagnitude))
        }
        else{
            textSize = CGSize(width:0, height:0)
        }
        self.contentLabel?.frame.size.width = kMessageCell_ContentWidth
        self.contentLabel?.text = curMessage?.content
        self.contentLabel?.sizeToFit()
        
        textSize?.height = (self.contentLabel?.frame.height)!
        
        self.contentLabel?.frame.origin.y = kMessageCell_PadingHeight
        bgImgViewSize = CGSize(width: (textSize?.width)!+2*kMessageCell_PadingWidth ,height:(textSize?.height)!+2*kMessageCell_PadingHeight)
        
        if (curMessage?.isSend!)! {
            self.userIcon?.isHidden = !isShowMeIcon
            // isMe
            if isShowMeIcon {
                bgImgViewFrame = CGRect(x:kScreen_Width-kPaddingLeftWidth-kMessageCell_UserIconWith-(bgImgViewSize?.width)!,y:curBottomY+kMessageCell_PadingHeight,width:(bgImgViewSize?.width)!,height:(bgImgViewSize?.height)!)
                self.userIcon?.center = CGPoint(x:kScreen_Width-kPaddingLeftWidth-kMessageCell_UserIconWith/2,y:bgImgViewFrame.maxY-kMessageCell_UserIconWith/2)
                self.bgImgView?.frame = bgImgViewFrame
            }
            else{
                bgImgViewFrame = CGRect(x:kScreen_Width-kPaddingLeftWidth-(bgImgViewSize?.width)!,y:curBottomY+kMessageCell_PadingHeight,width:(bgImgViewSize?.width)!,height:(bgImgViewSize?.height)!)
                self.bgImgView?.frame = bgImgViewFrame
            }
        }
        else{
            self.userIcon?.isHidden = isShowMeIcon
            bgImgViewFrame = CGRect(x:kPaddingLeftWidth+kMessageCell_UserIconWith, y:curBottomY+kMessageCell_PadingHeight,width:(bgImgViewSize?.width)!,height:(bgImgViewSize?.height)!)
            self.userIcon?.center = CGPoint(x:kPaddingLeftWidth+kMessageCell_UserIconWith/2,y:bgImgViewFrame.maxY-kMessageCell_UserIconWith/2)
            self.bgImgView?.frame = bgImgViewFrame
        }
        if (curMessage?.isSend!)! {
            // isMe
            bgImg = UIImage(named:"messageRight_bg_img")
        }
        else{
            bgImg = UIImage(named:"messageLeft_bg_img")
        }
        bgImg = bgImg?.resizableImage(withCapInsets: UIEdgeInsets(top:18,left:30,bottom:(bgImg?.size.height)!-19,right:(bgImg?.size.width)!-31))
        if (curMessage?.isSend!)! {
            self.userIcon?.image = UIImage(named:"head")
        }
        else{
            self.userIcon?.image = UIImage(named:"head1")
        }
        
//        [self.userIcon sd_setImageWithURL:[_curPriMsg.sender.avatar urlImageWithCodePathResizeToView:_userIconView] placeholderImage:kPlaceholderMonkeyRoundView(_userIconView)];
        self.bgImgView?.image = bgImg
        
        if isShowDetailTime {
            self.detailTimeLabel?.text = Date.getDetailTitleDateString(curDatestr: curPriMsg.date!)
            if curPriMsg.isSend!{
                self.detailTimeLabel?.center = CGPoint(x:kScreen_Width-2*kPaddingLeftWidth-(bgImgViewSize?.width)!,y:bgImgViewFrame.maxY-kMessageCell_DetailTimeHeight/2)
            }
            else{
                self.detailTimeLabel?.center = CGPoint(x:2*kPaddingLeftWidth+(bgImgViewSize?.width)!+kMessageCell_UserIconWith,y:bgImgViewFrame.maxY-kMessageCell_DetailTimeHeight/2)
            }
        }
    }
}

extension ATOMMessageCell{
    class func getCellHieght(curObj: ATOMMessageModel, preObj:ATOMMessageModel) -> CGFloat{
        var cellHeight:CGFloat = 0
        let textSize = getStringSize(content: curObj.content!, font: kMessageCell_FontContent, constrainedToSize: CGSize(width:kMessageCell_ContentWidth,height:CGFloat.greatestFiniteMagnitude))
        cellHeight += textSize.height + kMessageCell_PadingHeight*4
        if isShowTitleTime {
            let time = ATOMMessageCell.displayTimeStrWithCurMsg(curMsg: curObj, preMsg: preObj)
            if !time.isEmpty {
                cellHeight += kMessageCell_TimeHeight;
            }
        }
        return cellHeight
    }
    
    class func displayTimeStrWithCurMsg(curMsg: ATOMMessageModel, preMsg:ATOMMessageModel) ->String{
        return Date.getTitleDateString(curDatestr:curMsg.date!, preDatestr:preMsg.date ?? "" )
    }
    
    class func getStringSize(content:String, font: UIFont, constrainedToSize:CGSize) -> CGSize{
        // 幅は適正な値、高さは多めの数値を指定
        let maxSize = CGSize(width: constrainedToSize.width, height: constrainedToSize.height)
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byWordWrapping
        // フォントのサイズによって高さが変わるので実際のサイズを指定
        let size = (content as NSString).boundingRect(with: maxSize, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: font,NSAttributedStringKey.paragraphStyle:style], context: nil).size
        return size
    }
}

extension ATOMMessageCell{
    func configSendStatus(){
        
    }
}
