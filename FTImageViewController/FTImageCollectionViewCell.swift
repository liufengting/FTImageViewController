//
//  FTImageCollectionViewCell.swift
//  Demo
//
//  Created by liufengting on 2018/7/27.
//  Copyright © 2018年 liufengting. All rights reserved.
//

import UIKit

class FTImageCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "\(FTImageCollectionViewCell.classForCoder())"
    
    public lazy var imageScrollView : FTImageScrollView = {
        let imageSV = FTImageScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.width(), height: UIScreen.height()))
        return imageSV
    }()
    
    public func setupWithImageResource(imageResource: FTImageResource) {
        self.backgroundColor = UIColor.clear
        if self.imageScrollView.superview != nil {
            self.imageScrollView.removeFromSuperview()
        }
        if self.imageScrollView.superview == nil {
            self.addSubview(self.imageScrollView)
        }
        self.imageScrollView.setupWithImageResource(imageResource: imageResource)
    }
    
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        if self.imageScrollView.contentSize.height > self.imageScrollView.bounds.size.height {
//            return self.imageScrollView
//        } else {
//            return self
//        }
//    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if self.imageScrollView.contentSize.height > self.imageScrollView.bounds.size.height {
//            self.imageScrollView.touchesBegan(touches, with: event)
//        } else {
//            super.touchesBegan(touches, with: event)
//        }
//    }
//    
    
}
