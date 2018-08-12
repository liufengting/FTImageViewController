//
//  FTImageTransition.swift
//  FTImageTransition
//
//  Created by liufengting on 2018/8/10.
//  Copyright © 2018年 liufengting. All rights reserved.
//

import UIKit

open class FTZoomTransitionConfig {
    
    open var sourceView: UIView?
    open var sourceFrame = CGRect.zero
    open var targetFrame = CGRect.zero
    open var animationDuriation : TimeInterval = 0.3
    open lazy var transitionImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    static func maxAnimationDuriation() -> TimeInterval {
        return 0.3
    }
    
    public convenience init(sourceView: UIView, image: UIImage?, targetFrame: CGRect) {
        self.init()
        self.sourceView = sourceView
        self.targetFrame = targetFrame
        self.transitionImageView.image = image
        if self.sourceView != nil {
            self.sourceFrame = (self.sourceView?.superview?.convert((self.sourceView?.frame)!, to: UIApplication.shared.keyWindow))!;
        }
    }
}

open class FTImageTransition: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    open var config: FTZoomTransitionConfig!
    
    final let presentAnimator = FTPresentAnimator()
    final let dismissAnimator = FTDismissAnimator()
    public let panDismissAnimator = FTPanDismissAnimator()
    
    public func wirePanDismissToViewController(_ viewController: UIViewController!, for view: UIView) {
        self.panDismissAnimator.wirePanDismissToViewController(viewController: viewController, for: view)
    }
    
    public func wireEdgePanDismissToViewController(viewController: UIViewController) {
        self.panDismissAnimator.wireEdgePanDismissToViewController(viewController: viewController)
    }
    
    
    //    MARK: - UIViewControllerTransitioningDelegate
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if panDismissAnimator.interactionInProgress == true {
            panDismissAnimator.dismissAnimator = dismissAnimator
            return panDismissAnimator
        } else {
            return nil
        }
    }
    
    //    MARK: - UIViewControllerAnimatedTransitioning
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval{
        return max(FTZoomTransitionConfig.maxAnimationDuriation(), config.animationDuriation)
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if config == nil {
            return
        }
        
        let container = transitionContext.containerView
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        
        fromVC.view.frame = container.bounds
        toVC.view.frame = container.bounds;
        container.addSubview(fromVC.view)
        container.addSubview(toVC.view)
        
        if self.config.transitionImageView.superview == nil {
            container.addSubview(config.transitionImageView)
        }
        
        
        self.config.transitionImageView.frame = config.targetFrame
        
        self.config.transitionImageView.alpha = 1.0
        self.config.transitionImageView.isHidden = false
        
        //        self.config.transitionImageView.frame = config.targetFrame
        //        self.config.transitionImageView.isHidden = false
        
        
        
        
        
        
        self.config.transitionImageView.frame = config.sourceFrame
        self.config.sourceView?.isHidden = true
        toVC.view.alpha = 0
        
        let keyframeAnimationOption = UIView.KeyframeAnimationOptions.calculationModeCubic
        UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext),
                                delay: 0,
                                options: keyframeAnimationOption,
                                animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
                                        self.config.transitionImageView.frame = self.config.targetFrame
                                        fromVC.view.alpha = 0
                                    })
                                    
                                    UIView.addKeyframe(withRelativeStartTime: 0.99, relativeDuration: 0.01, animations: {
                                        toVC.view.alpha = 1
                                    })
        }, completion: { (completed) -> () in
            fromVC.view.alpha = transitionContext.transitionWasCancelled ? 1.0 : 0.0
            self.config.transitionImageView.alpha = transitionContext.transitionWasCancelled ? 1.0 : 0.0
            self.config.transitionImageView.isHidden = true
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
}

