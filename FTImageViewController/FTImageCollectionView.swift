//
//  FTImageCollectionView.swift
//  FTImageTransition
//
//  Created by liufengting on 2018/8/15.
//

import UIKit

open class FTImageCollectionView: UICollectionView {

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.commomInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commomInit()
    }
    
    func commomInit() {
        backgroundColor = .clear
        isPagingEnabled = true
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
    }

//    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder()) && otherGestureRecognizer.isKind(of: UIScreenEdgePanGestureRecognizer.classForCoder()) {
//            return true
//        }
//        return false
//    }

}
