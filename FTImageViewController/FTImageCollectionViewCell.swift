//
//  FTImageCollectionViewCell.swift
//  Demo
//
//  Created by liufengting on 2018/7/27.
//  Copyright © 2018年 liufengting. All rights reserved.
//

import UIKit

class FTImageCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    static let identifier = "\(FTImageCollectionViewCell.classForCoder())"
    
    public lazy var panGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer()
        pan.delegate = self
        return pan
    }()
    
    public lazy var imageScrollView : FTImageScrollView = {
        let imageSV = FTImageScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.width(), height: UIScreen.height()))
        imageSV.addGestureRecognizer(self.panGesture)
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
    
    //    MARK: - UIGestureRecognizerDelegate
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isEqual(self.panGesture) {
            let translatedPoint = (gestureRecognizer as! UIPanGestureRecognizer).translation(in: gestureRecognizer.view)
            let gestureIsVertical = (fabs(translatedPoint.y) > fabs(translatedPoint.x))
            if self.imageScrollView.contentSize.height > self.imageScrollView.bounds.size.height {
                if gestureIsVertical {
                    print(translatedPoint)
                    if self.imageScrollView.contentOffset.y <= 0 && translatedPoint.y > 0 {
                        self.imageScrollView.isScrollEnabled = false
                        return true
                    } else if self.imageScrollView.contentOffset.y + self.imageScrollView.bounds.size.height > self.imageScrollView.contentSize.height && translatedPoint.y < 0 {
                        self.imageScrollView.isScrollEnabled = false
                        return true
                    }
                }
                self.imageScrollView.isScrollEnabled = true
                return false
            }
            self.imageScrollView.isScrollEnabled = !gestureIsVertical
            return gestureIsVertical
        }
        return true
    }
    
}
