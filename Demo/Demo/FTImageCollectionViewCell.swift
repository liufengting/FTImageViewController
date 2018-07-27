//
//  FTImageCollectionViewCell.swift
//  Demo
//
//  Created by liufengting on 2018/7/27.
//  Copyright © 2018年 liufengting. All rights reserved.
//

import UIKit

extension UIScreen {
    
    public static func width() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
    public static func height() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
}

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
    
}
