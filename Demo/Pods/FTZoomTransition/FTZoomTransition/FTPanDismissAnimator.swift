//
//  FTPanDismissAnimator.swift
//  FTZoomTransition
//
//  Created by liufengting on 28/12/2016.
//  Copyright © 2016 LiuFengting. All rights reserved.
//

import UIKit

open class FTPanDismissAnimator : UIPercentDrivenInteractiveTransition, UIGestureRecognizerDelegate {
    
    public var interactionInProgress = false
    public weak var dismissAnimator: FTDismissAnimator!
    fileprivate var shouldCompleteTransition = false
    fileprivate weak var viewController: UIViewController!
    fileprivate weak var gestureView: UIView!
    fileprivate lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        gesture.delegate = self
        return gesture
    }()
    
    public func wireToViewController(_ viewController: UIViewController!, for view: UIView) {
        self.viewController = viewController
        self.gestureView = view
        preparePanGestureRecognizerInView(viewController.view)
    }
    
    fileprivate func preparePanGestureRecognizerInView(_ view: UIView) {
        if (self.panGesture.view != nil) {
            self.panGesture.view?.removeGestureRecognizer(self.panGesture)
        }
        view.addGestureRecognizer(self.panGesture)
    }
    
    @objc func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!)
        var progress = (translation.y / UIScreen.main.bounds.size.width)
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
        switch gestureRecognizer.state {
        case .began:
            interactionInProgress = true
            viewController.view.isHidden = true
            viewController.dismiss(animated: true, completion: nil)
        case .changed:
            shouldCompleteTransition = progress > 0.2
            viewController.view.isHidden = true
            self.updateTargetViewFrame(progress, translation: translation)
            update(progress)
        case .cancelled:
            viewController.view.isHidden = false
            interactionInProgress = false
            cancel()
        case .ended:
            interactionInProgress = false
            if !shouldCompleteTransition {
                viewController.view.isHidden = false
                cancel()
            } else {
                viewController.view.isHidden = true
                self.finishAnimation()
                finish()
            }
        default: break
        }
    }
    
//    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        if gestureRecognizer.isEqual(self.panGesture) {
//            if gestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder()) {
//                let pan: UIPanGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
//                if let sc: UIScrollView = gestureRecognizer.view as? UIScrollView {
//                    if sc.contentSize.height > sc.bounds.size.height {
//                        let translation : CGPoint = pan.translation(in: gestureRecognizer.view!)
//                        print(translation)
//                        if sc.contentOffset.y == 0 {
//
//                        } else if sc.contentOffset.y + sc.bounds.size.height >= UIScreen.main.bounds.size.height && translation.y > 0 {
//
//                        }
//                    }else {
//                        return true
//                    }
//                }
//                if (gestureRecognizer.view?.isKind(of: UIScrollView.classForCoder()))! {
//
//                }
//            }
//        }
//
//        return true
//    }
    
    func updateTargetViewFrame(_ progress: CGFloat, translation: CGPoint) {
        let sourceFrame : CGRect = self.dismissAnimator.config.targetFrame
        let targetWidth = sourceFrame.width*(1.0-progress)
        let targetHeight = sourceFrame.height*(1.0-progress)
        let targetX = sourceFrame.origin.x + sourceFrame.size.width/2.0 - targetWidth/2.0 + translation.x
        let targetY = sourceFrame.origin.y + sourceFrame.size.height/2.0 - targetHeight/2.0 + translation.y
        self.dismissAnimator.config.transitionImageView.frame = CGRect(x: targetX, y: targetY, width: targetWidth, height: targetHeight)
    }
    
    func finishAnimation() {
        self.dismissAnimator.config.sourceView?.isHidden = true
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: {
                        self.dismissAnimator.config.transitionImageView.frame = self.dismissAnimator.config.sourceFrame
        }) { (complete) in
            self.dismissAnimator.config.transitionImageView.isHidden = true
            self.dismissAnimator.config.sourceView?.isHidden = false
        }
    }
}
