//
//  FTImageCollectionViewCell.swift
//  Demo
//
//  Created by liufengting on 2018/7/27.
//  Copyright © 2018年 liufengting. All rights reserved.
//

import UIKit

open class FTImageCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "\(FTImageCollectionViewCell.classForCoder())"
    
    public lazy var imageScrollView : FTImageScrollView = {
        let imageSV = FTImageScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.width(), height: UIScreen.height()))
        return imageSV
    }()
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.imageScrollView.prepareForReuse()
    }
    
    public func setupWithImageResource(imageResource: FTImageResource?) {
        self.backgroundColor = UIColor.clear
        if self.imageScrollView.superview != nil {
            self.imageScrollView.removeFromSuperview()
        }
        if self.imageScrollView.superview == nil {
            self.contentView.addSubview(self.imageScrollView)
        }
        self.imageScrollView.setupWithImageResource(imageResource: imageResource)
    }
    
}
