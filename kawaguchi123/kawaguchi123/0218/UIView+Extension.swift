//
//  UITableView+Extension.swift
//  kawaguchi234tableview
//
//  Created by Lee on 2018/2/18.
//  Copyright © 2018年 CoreDLE. All rights reserved.
//

import UIKit

extension UIView {
    
    private struct AssociatedKeys {
        static var descriptiveName = "AssociatedKeys.DescriptiveName.blankPageView"
    }
    
    private (set) var blankPageView: EaseBlankPageView {
        get {
            if let blankPageView = objc_getAssociatedObject(
                self,
                &AssociatedKeys.descriptiveName
                ) as? EaseBlankPageView {
                return blankPageView
            }
            self.blankPageView = EaseBlankPageView(frame:UIScreen.main.bounds)
            return self.blankPageView
        }
        set(blankPageView) {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.descriptiveName,
                blankPageView,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    func configBlankView(hasData: Bool){
        if (hasData) {
            self.blankPageView.isHidden = true
            self.blankPageView.removeFromSuperview()
        }
        else{
            self.blankPageView.isHidden = false
            blankPageContainer().insertSubview(self.blankPageView, at: 0)
            self.blankPageView.configView(hasData: hasData)
        }
    }
    
    func blankPageContainer() -> UIView{
        var blankPageContainer = self
        for aView in self.subviews {
            if aView is UITableView {
                blankPageContainer = aView
            }
        }
        return blankPageContainer
    }
}

class EaseBlankPageView: UIView {
    var atomImageView: UIImageView?
    var imageView_w:CGFloat?
    var imageView_h:CGFloat?
    var imageView_x:CGFloat?
    var imageView_y:CGFloat?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.imageView_w = 160
        self.imageView_h = 160
        self.imageView_x = (frame.width-imageView_w!)/2
        self.imageView_y = (frame.height-imageView_h!)/2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func configView(hasData: Bool){
        if hasData {
            self.removeFromSuperview()
            return
        }
        self.alpha = 1.0
        if atomImageView == nil{
            atomImageView = UIImageView()
            atomImageView?.contentMode = .scaleAspectFill
            self.addSubview(atomImageView!)
        }

        atomImageView?.image = UIImage(named:"2.jpg")
        atomImageView?.frame = CGRect(x:imageView_x!, y:imageView_y!, width:imageView_w!, height: imageView_h!)
    }
}

