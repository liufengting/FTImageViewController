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
    open var animationDuriation : TimeInterval = 0.45
    open lazy var transitionImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    static func maxAnimationDuriation() -> TimeInterval {
        return 0.5
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

@objc public protocol FTImageTransitionDelegate: NSObjectProtocol {
    @objc
    optional func ftImageTransitionWillStartPresent(transition: FTImageTransition?, transitionContext: UIViewControllerContextTransitioning)
    @objc
    optional func ftImageTransitionDidFinishPresent(transition: FTImageTransition?, transitionContext: UIViewControllerContextTransitioning)
    @objc
    optional func ftImageTransitionWillStartDismiss(transition: FTImageTransition?, transitionContext: UIViewControllerContextTransitioning)
    @objc
    optional func ftImageTransitionDidCancelDismiss(transition: FTImageTransition?, transitionContext: UIViewControllerContextTransitioning)
    @objc
    optional func ftImageTransitionDidFinishDismiss(transition: FTImageTransition?, transitionContext: UIViewControllerContextTransitioning)
}

open class FTImageTransition: NSObject, UIViewControllerTransitioningDelegate, FTImageTransitionDelegate {
    
    open var config: FTZoomTransitionConfig = FTZoomTransitionConfig() {
        willSet{
            presentAnimator.config = newValue
            dismissAnimator.config = newValue
        }
    }
    
    private lazy var presentAnimator: FTImageTransitionPresentAnimator = {
        let animator = FTImageTransitionPresentAnimator()
        animator.delegate = self
        return animator
    }()
    
    private lazy var dismissAnimator: FTImageTransitionDismissAnimator = {
        let animator = FTImageTransitionDismissAnimator()
        animator.delegate = self
        return animator
    }()
    
    public lazy var panDismissAnimator: FTImageTransitionPanDismissAnimator = {
        let animator = FTImageTransitionPanDismissAnimator()
        animator.dismissAnimator = dismissAnimator
        animator.delegate = self
        return animator
    }()
    
    public weak var delegate: FTImageTransitionDelegate?

    public func wirePanDismissToViewController(_ viewController: UIViewController!) {
        self.panDismissAnimator.wirePanDismissToViewController(viewController: viewController)
    }
    
    //    MARK: - UIViewControllerTransitioningDelegate
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentAnimator
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissAnimator
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if panDismissAnimator.interactionInProgress == true {
            return panDismissAnimator
        } else {
            return nil
        }
    }
    
    //    MARK: - UIViewControllerTransitioningDelegate
    
    public func ftImageTransitionWillStartPresent(transition: FTImageTransition?, transitionContext: UIViewControllerContextTransitioning) {
        if self.delegate != nil && (self.delegate!.responds(to: #selector(FTImageTransitionDelegate.ftImageTransitionWillStartPresent(transition:transitionContext:)))) {
            self.delegate?.ftImageTransitionWillStartPresent!(transition: self, transitionContext: transitionContext)
        }
    }

    public func ftImageTransitionDidFinishPresent(transition: FTImageTransition?, transitionContext: UIViewControllerContextTransitioning) {
        if self.delegate != nil && (self.delegate!.responds(to: #selector(FTImageTransitionDelegate.ftImageTransitionDidFinishPresent(transition:transitionContext:)))) {
            self.delegate?.ftImageTransitionDidFinishPresent!(transition: self, transitionContext: transitionContext)
        }
    }
    
    public func ftImageTransitionWillStartDismiss(transition: FTImageTransition?, transitionContext: UIViewControllerContextTransitioning) {
        if self.delegate != nil && (self.delegate!.responds(to: #selector(FTImageTransitionDelegate.ftImageTransitionWillStartDismiss(transition:transitionContext:)))) {
            self.delegate?.ftImageTransitionWillStartDismiss!(transition: self, transitionContext: transitionContext)
        }
    }
    
    public func ftImageTransitionDidCancelDismiss(transition: FTImageTransition?, transitionContext: UIViewControllerContextTransitioning) {
        if self.delegate != nil && (self.delegate!.responds(to: #selector(FTImageTransitionDelegate.ftImageTransitionDidCancelDismiss(transition:transitionContext:)))) {
            self.delegate?.ftImageTransitionDidCancelDismiss!(transition: self, transitionContext: transitionContext)
        }
    }
    
    public func ftImageTransitionDidFinishDismiss(transition: FTImageTransition?, transitionContext: UIViewControllerContextTransitioning) {
        if self.delegate != nil && (self.delegate!.responds(to: #selector(FTImageTransitionDelegate.ftImageTransitionDidFinishDismiss(transition:transitionContext:)))) {
            self.delegate?.ftImageTransitionDidFinishDismiss!(transition: self, transitionContext: transitionContext)
        }
    }
    
}

open class FTImageTransitionPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    public weak var config : FTZoomTransitionConfig!
    public weak var delegate: FTImageTransitionDelegate?

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval{
        return max(FTZoomTransitionConfig.maxAnimationDuriation(), config.animationDuriation)
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if config == nil {
            return
        }
        if (self.delegate != nil && (self.delegate!.responds(to: #selector(FTImageTransitionDelegate.ftImageTransitionWillStartPresent(transition:transitionContext:))))) {
            self.delegate?.ftImageTransitionWillStartPresent!(transition: nil, transitionContext: transitionContext)
        }
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let container = transitionContext.containerView
        
        fromVC.view.frame = container.bounds
        toVC.view.frame = container.bounds;
        container.addSubview(fromVC.view)
        container.addSubview(toVC.view)
        container.addSubview(config.transitionImageView)
        
        toVC.view.alpha = 0
        self.config.sourceView?.isHidden = true
        self.config.transitionImageView.frame = config.sourceFrame

        UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext),
                                delay: 0,
                                options: UIViewKeyframeAnimationOptions.calculationModeCubic,
                                animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
                                        self.config.transitionImageView.frame = self.config.targetFrame
                                        fromVC.view.alpha = 0
                                    })

                                    UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 0.1, animations: {
                                        toVC.view.alpha = 1
                                    })
        }, completion: { (completed) -> () in
            fromVC.view.alpha = transitionContext.transitionWasCancelled ? 1.0 : 0.0
            self.config.sourceView?.isHidden = false
            self.config.transitionImageView.alpha = transitionContext.transitionWasCancelled ? 1.0 : 0.0
            self.config.transitionImageView.isHidden = !(transitionContext.transitionWasCancelled)
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            if !(transitionContext.transitionWasCancelled) {
                if (self.delegate != nil && (self.delegate!.responds(to: #selector(FTImageTransitionDelegate.ftImageTransitionDidFinishPresent(transition:transitionContext:))))) {
                    self.delegate?.ftImageTransitionDidFinishPresent!(transition: nil, transitionContext: transitionContext)
                }
            }
        })
    }
}

open class FTImageTransitionDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning{
    
    public weak var config : FTZoomTransitionConfig!
    public weak var delegate: FTImageTransitionDelegate?

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval{
        return max(FTZoomTransitionConfig.maxAnimationDuriation(), config.animationDuriation)
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if config == nil {
            return
        }
        if (self.delegate != nil && (self.delegate!.responds(to: #selector(FTImageTransitionDelegate.ftImageTransitionWillStartDismiss(transition:transitionContext:))))) {
            self.delegate?.ftImageTransitionWillStartDismiss!(transition: nil, transitionContext: transitionContext)
        }
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let container = transitionContext.containerView
        
        fromVC.view.frame = container.bounds;
        toVC.view.frame = container.bounds;
        toVC.view.alpha = 0.0
        
        container.addSubview(toVC.view)
        container.addSubview(self.config.transitionImageView)
        
        self.config.transitionImageView.frame = config.targetFrame
        self.config.transitionImageView.isHidden = false
        self.config.transitionImageView.alpha = 1.0
        
        UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext),
                                delay: 0,
                                options: UIViewKeyframeAnimationOptions.calculationModeCubic,
                                animations:{
                                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration:  1.0, animations: {
                                        toVC.view.alpha = 1
                                        if (!transitionContext.isInteractive) {
                                            self.config.transitionImageView.frame = self.config.sourceFrame
                                        }
                                    })
                                    
                                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.1, animations: {
                                        fromVC.view.alpha = 0
                                    })
                                    
        }, completion: { (completed) -> () in
            if (transitionContext.transitionWasCancelled == true){
                container.bringSubview(toFront: fromVC.view)
            }
            self.config.transitionImageView.isHidden = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            if (transitionContext.transitionWasCancelled) {
                if (self.delegate != nil && (self.delegate!.responds(to: #selector(FTImageTransitionDelegate.ftImageTransitionDidCancelDismiss(transition:transitionContext:))))) {
                    self.delegate?.ftImageTransitionDidCancelDismiss!(transition: nil, transitionContext: transitionContext)
                }
            } else {
                if (self.delegate != nil && (self.delegate!.responds(to: #selector(FTImageTransitionDelegate.ftImageTransitionDidFinishDismiss(transition:transitionContext:))))) {
                    self.delegate?.ftImageTransitionDidFinishDismiss!(transition: nil, transitionContext: transitionContext)
                }
            }
        })
    }
}

open class FTImageTransitionPanDismissAnimator : UIPercentDrivenInteractiveTransition {
    
    public var interactionInProgress = false
    public weak var dismissAnimator: FTImageTransitionDismissAnimator!
    public weak var viewController: UIViewController?
    fileprivate var shouldCompleteTransition = false
    public weak var delegate: FTImageTransitionDelegate?

    lazy var panGesture : UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        return gesture
    }()

    public func wirePanDismissToViewController(viewController: UIViewController) {
        self.viewController = viewController
        preparePanGestureRecognizerInView(viewController.view)
    }
    
    public func handleDismissBegin() {
        interactionInProgress = true
        viewController?.view.isHidden = true
        viewController?.dismiss(animated: true, completion: nil)
    }
    
    public func handleDismissProgress(progress: CGFloat, translation: CGPoint) {
        shouldCompleteTransition = (fabsf(Float(progress)) > 0.2)
        viewController?.view.isHidden = true
        self.updateTargetViewFrame(progress, translation: translation)
        update(CGFloat(fabsf(Float(progress))))
    }
    
    public func handleDismissCancel() {
        interactionInProgress = false
        viewController?.view.isHidden = false
        cancel()
    }
    
    public func handleDismissFinish() {
        interactionInProgress = false
        viewController?.view.isHidden = true
        self.finishAnimation()
        finish()
    }
    
    fileprivate func preparePanGestureRecognizerInView(_ view: UIView) {
        view.addGestureRecognizer(self.panGesture)
    }

    @objc public func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!)
        var progress: CGFloat = 0.0
        if gestureRecognizer.isEqual(self.panGesture) {
            progress = (translation.y / UIScreen.main.bounds.size.height)
        } else {
            progress = (translation.x / UIScreen.main.bounds.size.width)
        }
        progress = CGFloat(min(max(Float(progress), -1.0), 1.0))
        switch gestureRecognizer.state {
        case .began:
            self.handleDismissBegin()
        case .changed:
            self.handleDismissProgress(progress: progress, translation: translation)
        case .cancelled:
            self.handleDismissCancel()
        case .ended:
            if shouldCompleteTransition {
                self.handleDismissFinish()
            } else {
                self.handleDismissCancel()
            }
        default: break
        }
    }
    
    func updateTargetViewFrame(_ progress: CGFloat, translation: CGPoint) {
        let sourceFrame : CGRect = self.dismissAnimator.config.targetFrame
        let targetWidth = sourceFrame.width*CGFloat((1.0-fabsf(Float(progress))))
        let targetHeight = sourceFrame.height*CGFloat((1.0-fabsf(Float(progress))))
        let targetX = sourceFrame.origin.x + sourceFrame.size.width/2.0 - targetWidth/2.0 + translation.x
        let targetY = sourceFrame.origin.y + sourceFrame.size.height/2.0 - targetHeight/2.0 + translation.y
        self.dismissAnimator.config.transitionImageView.frame = CGRect(x: targetX, y: targetY, width: targetWidth, height: targetHeight)
    }
    
    func finishAnimation() {
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: {
                        self.dismissAnimator.config.transitionImageView.frame = self.dismissAnimator.config.sourceFrame
        }) { (complete) in
            self.dismissAnimator.config.transitionImageView.isHidden = true
        }
    }
}
