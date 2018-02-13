//
//  ATOMUIActivityIndicatorView.swift
//  SwiftHaveOC
//
//  Created by Lee on 2018/2/13.
//  Copyright © 2018年 CoreDLE. All rights reserved.
//

import UIKit

class ATOMUIActivityIndicatorView: UIView {

    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    

    public class func newInstance() -> ATOMUIActivityIndicatorView{
        let indicatorView = Bundle.main.loadNibNamed("ATOMUIActivityIndicatorView", owner: nil, options: nil)?.first as! ATOMUIActivityIndicatorView
        indicatorView.frame = kScreen_Bounds
        indicatorView.alpha = 0.0
        return indicatorView
    }
}

extension ATOMUIActivityIndicatorView{
    func showIndicatorView(){
        self.indicatorView.startAnimating()
        UIApplication.shared.keyWindow?.addSubview(self)
        UIView.animate(withDuration: 0.25) { [unowned self] in
            self.alpha = 1.0
        }
    }
    
    func hideIndicatorView(){
        UIView.animate(withDuration: 0.25, animations: { [unowned self] in
            self.alpha = 0.0
        }) { (aa:Bool) in
            self.indicatorView.startAnimating()
            self.removeFromSuperview()
        }
    }
}
