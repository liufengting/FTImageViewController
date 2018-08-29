//
//  FTImageTransition.swift
//  FTImageTransition
//
//  Created by liufengting on 2018/8/10.
//  Copyright © 2018年 liufengting. All rights reserved.
//

import UIKit

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

open class FTZoomTransitionConfig {
    
    open var sourceView: UIView?
    open var sourceFrame = CGRect.zero
    open var targetFrame = CGRect.zero
    open var animationDuriation : TimeInterval = 0.2
    open lazy var transitionImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    static func maxAnimationDuriation() -> TimeInterval {
        return 0.5
    }
    
    public convenience init(sourceView: UIView?, image: UIImage?, targetFrame: CGRect) {
        self.init()
        self.sourceView = sourceView
        self.targetFrame = targetFrame
        self.transitionImageView.image = image
        if self.sourceView != nil {
            self.sourceFrame = (self.sourceView?.superview?.convert((self.sourceView?.frame)!, to: UIApplication.shared.keyWindow))!;
        }
    }
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
    
    public func wireGesturesTo(panGestureViewController: UIViewController, edgePanGestureView: UIView) {
        self.panDismissAnimator.wireGesturesTo(panGestureViewController: panGestureViewController, edgePanGestureView: edgePanGestureView)
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
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       usingSpringWithDamping: 0.75,
                       initialSpringVelocity: 0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.config.transitionImageView.frame = self.config.targetFrame
                        fromVC.view.alpha = 0
        }) { (completed) in
            fromVC.view.alpha = transitionContext.transitionWasCancelled ? 1.0 : 0.0
            toVC.view.alpha = transitionContext.transitionWasCancelled ? 0.0 : 1.0
            self.config.sourceView?.isHidden = false
            self.config.transitionImageView.alpha = transitionContext.transitionWasCancelled ? 1.0 : 0.0
            self.config.transitionImageView.isHidden = !(transitionContext.transitionWasCancelled)
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            if !(transitionContext.transitionWasCancelled) {
                if (self.delegate != nil && (self.delegate!.responds(to: #selector(FTImageTransitionDelegate.ftImageTransitionDidFinishPresent(transition:transitionContext:))))) {
                    self.delegate?.ftImageTransitionDidFinishPresent!(transition: nil, transitionContext: transitionContext)
                }
            }
        }
        
        //        UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext),
        //                                delay: 0,
        //                                options: UIViewKeyframeAnimationOptions.calculationModeCubic,
        //                                animations: {
        //                                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0, animations: {
        //                                        self.config.transitionImageView.frame = self.config.targetFrame
        //                                        fromVC.view.alpha = 0
        //                                    })
        //        }, completion: { (completed) -> () in
        //            fromVC.view.alpha = transitionContext.transitionWasCancelled ? 1.0 : 0.0
        //            toVC.view.alpha = transitionContext.transitionWasCancelled ? 0.0 : 1.0
        //            self.config.sourceView?.isHidden = false
        //            self.config.transitionImageView.alpha = transitionContext.transitionWasCancelled ? 1.0 : 0.0
        //            self.config.transitionImageView.isHidden = !(transitionContext.transitionWasCancelled)
        //            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        //            if !(transitionContext.transitionWasCancelled) {
        //                if (self.delegate != nil && (self.delegate!.responds(to: #selector(FTImageTransitionDelegate.ftImageTransitionDidFinishPresent(transition:transitionContext:))))) {
        //                    self.delegate?.ftImageTransitionDidFinishPresent!(transition: nil, transitionContext: transitionContext)
        //                }
        //            }
        //        })
    }
}

open class FTImageTransitionDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning{
    
    public weak var config : FTZoomTransitionConfig!
    public weak var delegate: FTImageTransitionDelegate?
    
    public var isEdgePan = false
    
    
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
        fromVC.view.alpha = 0.0
        toVC.view.alpha = 0.0
        
        container.addSubview(toVC.view)
        if isEdgePan {
            container.addSubview(fromVC.view)
        }
        container.addSubview(self.config.transitionImageView)
        
        self.config.transitionImageView.frame = config.targetFrame
        if !self.isEdgePan {
            self.config.transitionImageView.isHidden = false
        }
        self.config.transitionImageView.alpha = 1.0
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       usingSpringWithDamping: 0.75,
                       initialSpringVelocity: 0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        toVC.view.alpha = 1
                        if (!transitionContext.isInteractive) {
                            self.config.transitionImageView.frame = self.config.sourceFrame
                        }
        }) { (completed) in
            if (transitionContext.transitionWasCancelled == true){
                container.bringSubview(toFront: fromVC.view)
            }
            if !self.isEdgePan {
                fromVC.view.alpha = transitionContext.transitionWasCancelled ? 1.0 : 0.0
            }
            self.config.transitionImageView.isHidden = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            if (!self.isEdgePan) {
                if (transitionContext.transitionWasCancelled) {
                    if (self.delegate != nil && (self.delegate!.responds(to: #selector(FTImageTransitionDelegate.ftImageTransitionDidCancelDismiss(transition:transitionContext:))))) {
                        self.delegate?.ftImageTransitionDidCancelDismiss!(transition: nil, transitionContext: transitionContext)
                    }
                } else {
                    if (self.delegate != nil && (self.delegate!.responds(to: #selector(FTImageTransitionDelegate.ftImageTransitionDidFinishDismiss(transition:transitionContext:))))) {
                        self.delegate?.ftImageTransitionDidFinishDismiss!(transition: nil, transitionContext: transitionContext)
                    }
                }
            }
        }
        //        UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext),
        //                                delay: 0,
        //                                options: UIViewKeyframeAnimationOptions.calculationModeCubic,
        //                                animations:{
        //                                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration:  1.0, animations: {
        //                                        toVC.view.alpha = 1
        //                                        if (!transitionContext.isInteractive) {
        //                                            self.config.transitionImageView.frame = self.config.sourceFrame
        //                                        }
        //                                    })
        //
        //        }, completion: { (completed) -> () in
        //            if (transitionContext.transitionWasCancelled == true){
        //                container.bringSubview(toFront: fromVC.view)
        //            }
        //            if !self.isEdgePan {
        //                fromVC.view.alpha = transitionContext.transitionWasCancelled ? 1.0 : 0.0
        //            }
        //            self.config.transitionImageView.isHidden = transitionContext.transitionWasCancelled
        //            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        //            if (!self.isEdgePan) {
        //                if (transitionContext.transitionWasCancelled) {
        //                    if (self.delegate != nil && (self.delegate!.responds(to: #selector(FTImageTransitionDelegate.ftImageTransitionDidCancelDismiss(transition:transitionContext:))))) {
        //                        self.delegate?.ftImageTransitionDidCancelDismiss!(transition: nil, transitionContext: transitionContext)
        //                    }
        //                } else {
        //                    if (self.delegate != nil && (self.delegate!.responds(to: #selector(FTImageTransitionDelegate.ftImageTransitionDidFinishDismiss(transition:transitionContext:))))) {
        //                        self.delegate?.ftImageTransitionDidFinishDismiss!(transition: nil, transitionContext: transitionContext)
        //                    }
        //                }
        //            }
        //        })
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
    
    lazy var edgePanGesture : UIScreenEdgePanGestureRecognizer = {
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePanGesture(_:)))
        gesture.edges = .left
        return gesture
    }()
    
    public func wireGesturesTo(panGestureViewController: UIViewController, edgePanGestureView: UIView) {
        self.viewController = panGestureViewController
        preparePanGestureRecognizerInView(panGestureViewController.view)
        prepareEdgePanGestureRecognizerInView(edgePanGestureView)
    }
    
    fileprivate func preparePanGestureRecognizerInView(_ view: UIView) {
        view.addGestureRecognizer(self.panGesture)
    }
    
    fileprivate func prepareEdgePanGestureRecognizerInView(_ view: UIView) {
        view.addGestureRecognizer(self.edgePanGesture)
    }
    
    @objc public func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!)
        var progress: CGFloat = 0.0
        if gestureRecognizer.isEqual(self.panGesture) {
            progress = (translation.y / (gestureRecognizer.view?.bounds.size.height)!)
        } else {
            return
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
    
    @objc public func handleEdgePanGesture(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!)
        var progress: CGFloat = 0.0
        if gestureRecognizer.isEqual(self.edgePanGesture) {
            progress = (translation.x / (gestureRecognizer.view?.bounds.size.width)!)
        } else {
            return
        }
        progress = CGFloat(min(max(Float(progress), -1.0), 1.0))
        switch gestureRecognizer.state {
        case .began:
            self.handleEdgePanDismissBegin()
        case .changed:
            self.handleEdgePanDismissProgress(progress: progress, translation: translation)
        case .cancelled:
            self.handleEdgePanDismissCancel()
        case .ended:
            if shouldCompleteTransition {
                self.handleEdgePanDismissFinish()
            } else {
                self.handleEdgePanDismissCancel()
            }
        default: break
        }
    }
    
    // handle pan gesture actions
    
    public func handleDismissBegin() {
        interactionInProgress = true
        viewController?.dismiss(animated: true, completion: nil)
    }
    
    public func handleDismissProgress(progress: CGFloat, translation: CGPoint) {
        shouldCompleteTransition = (fabsf(Float(progress)) > 0.2)
        self.updateTargetViewFrame(progress, translation: translation)
        update(CGFloat(fabsf(Float(max(0.1, min(progress*3.0, 1.0))))))
    }
    
    public func handleDismissCancel() {
        interactionInProgress = true
        self.viewController?.view.isHidden = true
        UIView.animate(withDuration: self.dismissAnimator.config.animationDuriation,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: {
                        self.dismissAnimator.config.transitionImageView.frame = self.dismissAnimator.config.targetFrame
        }) { (complete) in
            self.interactionInProgress = false
            self.viewController?.view.isHidden = false
            self.cancel()
        }
    }
    
    public func handleDismissFinish() {
        self.interactionInProgress = false
        UIView.animate(withDuration: self.dismissAnimator.config.animationDuriation,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: {
                        self.dismissAnimator.config.transitionImageView.frame = self.dismissAnimator.config.sourceFrame
        }) { (complete) in
            self.viewController?.view.isHidden = true
            self.finish()
        }
    }
    
    // handle edge pan gesture actions
    
    public func handleEdgePanDismissBegin() {
        interactionInProgress = true
        self.dismissAnimator.isEdgePan = true
        viewController?.dismiss(animated: true, completion: nil)
    }
    
    public func handleEdgePanDismissProgress(progress: CGFloat, translation: CGPoint) {
        shouldCompleteTransition = (fabsf(Float(progress)) > 0.2)
        self.dismissAnimator.config.transitionImageView.isHidden = true
        self.viewController?.view.isHidden = false
        var rect = viewController?.view.frame
        rect?.origin.y = 0
        rect?.origin.x = CGFloat(ceilf(Float(translation.x)))
        viewController?.view.frame = rect!
        update(CGFloat(fabsf(Float(progress))))
    }
    
    public func handleEdgePanDismissCancel() {
        interactionInProgress = true
        self.viewController?.view.isHidden = false
        let rect = viewController?.view.frame
        UIView.animate(withDuration: self.dismissAnimator.config.animationDuriation,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: {
                        self.viewController?.view.frame = CGRect(x: 0, y: 0, width: (rect?.width)!, height: (rect?.height)!)
        }) { (complete) in
            self.interactionInProgress = false
            self.dismissAnimator.isEdgePan = false
            self.cancel()
        }
    }
    
    public func handleEdgePanDismissFinish() {
        self.interactionInProgress = false
        self.dismissAnimator.isEdgePan = false
        var rect = viewController?.view.frame
        rect = CGRect(x: (rect?.width)!, y: 0, width: (rect?.width)!, height: (rect?.height)!)
        UIView.animate(withDuration: self.dismissAnimator.config.animationDuriation,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: {
                        self.viewController?.view.frame = rect!
        }) { (complete) in
            self.viewController?.view.isHidden = true
            self.dismissAnimator.isEdgePan = false
            self.finish()
        }
    }
    
    //    MARK: - updateTargetViewFrame
    
    func updateTargetViewFrame(_ progress: CGFloat, translation: CGPoint) {
        let sourceFrame : CGRect = self.dismissAnimator.config.targetFrame
        let targetWidth = sourceFrame.width*CGFloat((1.0-fabsf(Float(progress))))
        let targetHeight = sourceFrame.height*CGFloat((1.0-fabsf(Float(progress))))
        let targetX = sourceFrame.origin.x + (sourceFrame.width)/2.0 + (translation.x) - targetWidth/2.0
        let targetY = sourceFrame.origin.y + (sourceFrame.height)/2.0 + (translation.y) - targetHeight/2.0
        self.dismissAnimator.config.transitionImageView.frame = CGRect(x: targetX, y: targetY, width: targetWidth, height: targetHeight)
    }
    
}
