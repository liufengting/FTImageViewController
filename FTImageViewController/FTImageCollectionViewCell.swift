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
    

    

    
//    //    MARK: - UIGestureRecognizerDelegate
//    
//    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        if gestureRecognizer.isEqual(self.panGesture) {
//            let translatedPoint = (gestureRecognizer as! UIPanGestureRecognizer).translation(in: gestureRecognizer.view)
//            let gestureIsVertical = (fabs(translatedPoint.y) > fabs(translatedPoint.x))
//            if self.imageScrollView.contentSize.height > self.imageScrollView.bounds.size.height {
//                if gestureIsVertical {
//                    print(translatedPoint)
//                    if self.imageScrollView.contentOffset.y <= 0 && translatedPoint.y > 0 {
//                        self.imageScrollView.isScrollEnabled = false
//                        return true
//                    } else if self.imageScrollView.contentOffset.y + self.imageScrollView.bounds.size.height > self.imageScrollView.contentSize.height && translatedPoint.y < 0 {
//                        self.imageScrollView.isScrollEnabled = false
//                        return true
//                    }
//                }
//                self.imageScrollView.isScrollEnabled = true
//                return false
//            }
//            self.imageScrollView.isScrollEnabled = !gestureIsVertical
//            return gestureIsVertical
//        }
//        return true
//    }
//    
}
