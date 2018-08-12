//
//  FTImageViewController.swift
//  FTImageViewController
//
//  Created by liufengting on 2018/7/27.
//  Copyright © 2018年 liufengting. All rights reserved.
//

import UIKit

public protocol FTImageViewControllerDelegate {
    func ftImageViewController(ftImageViewController: FTImageViewController, didScrollToPage page: NSInteger)
}

open class FTImageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, FTImageScrollViewDelegate {

    var imageResources: [FTImageResource] = []
    public var currentIndex: NSInteger = 0 {
        didSet {
            self.reload()
        }
    }
    
    public var subViewControllers: Array<UIViewController> = [] {
        didSet {
            self.reload()
        }
    }
    


    
    public override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]? = nil) {
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
        self.setup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    public func setup() {
        self.delegate = self
        self.dataSource = self
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black

        
//        if let transDelegate: FTZoomTransition = self.transitioningDelegate as? FTZoomTransition {
//            transDelegate.panDismissAnimator.wireToViewController(self, delegate: self)
//        }
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
//            self.reload()
//        }
    }
    
    public func setupWithImages(images: [FTImageResource], selectedIndex: NSInteger) {
        self.imageResources = images
        self.currentIndex = selectedIndex

        for (_, value) in self.imageResources.enumerated() {
            let imagevc = FTImageContainerViewController()
            imagevc.imageResource = value
            imagevc.imageScrollView.tapDelegate = self
            self.subViewControllers.append(imagevc)
        }
        
    }
    
    public func reload() {
        if self.subViewControllers.count > 0 && self.currentIndex <= self.subViewControllers.count - 1 && self.isViewLoaded {
            let VC : UIViewController = self.subViewControllers[self.currentIndex]
            self.setViewControllers([VC], direction: .forward, animated: false) { (completion) in }
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.reload()
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    public func reloadWithImages(images: [FTImageResource], selectPage: NSInteger) {
        self.imageResources = images

        self.scrollToPage(page: selectPage, animated: true)
    }
    
    public func scrollToPage(page: NSInteger, animated: Bool) {

    }
    
    public func ftImageViewController(ftImageViewController: FTImageViewController, didScrollToPage page: NSInteger) {

    }
    
    
    //    MARK: - UIPageViewControllerDelegate, UIPageViewControllerDataSource
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = self.subViewControllers.firstIndex(of: viewController)
        return (index == 0 || index == NSNotFound || index == nil) ? nil : self.subViewControllers[index!-1];
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = self.subViewControllers.firstIndex(of: viewController)
        return (index == 0 || index == NSNotFound || index == nil || index! >= self.subViewControllers.count - 1) ? nil : self.subViewControllers[index!+1];
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (completed) {
            
        }
    }
    
//    - (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed;

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.currentIndex = NSInteger(scrollView.contentOffset.x / scrollView.bounds.size.width)
        self.ftImageViewController(ftImageViewController: self, didScrollToPage: self.currentIndex)
    }
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
//        if let transDelegate: FTZoomTransition = self.transitioningDelegate as? FTZoomTransition {
//            transDelegate.panDismissAnimator.handlePanGesture(gesture)
//        }
    }
    
    // MARK: - FTImageScrollViewDelegate
    
    public func ftImageScrollView(ftImageScrollView: FTImageScrollView, didRecognizeSingleTapGesture gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true) { }
    }
    
    public func ftImageScrollViewDidZoomOut(ftImageScrollView: FTImageScrollView) {
        
    }
    
    public func ftImageScrollViewDidZoomIn(ftImageScrollView: FTImageScrollView) {
        
    }
    
    public func viewControllerWillDismiss(viewController: UIViewController) {
//        if let cell : FTImageCollectionViewCell = collectionView.cellForItem(at: IndexPath(item: self.currentIndex, section: 0)) as? FTImageCollectionViewCell {
//            if let transDelegate: FTZoomTransition = self.transitioningDelegate as? FTZoomTransition {
//                transDelegate.config.targetFrame = cell.imageScrollView.imageView.frame
//                transDelegate.config.transitionImageView.image = cell.imageScrollView.imageView.image
//            }
//        }
        
        
    }
    
}

extension FTImageViewController {
    
    fileprivate func addOrientationChangeNotification() {
        NotificationCenter.default.addObserver(self,selector: #selector(onChangeStatusBarOrientationNotification(notification:)),
                                               name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation,
                                               object: nil)
    }
    
    fileprivate func removeOrientationChangeNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func onChangeStatusBarOrientationNotification(notification : Notification) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
//            self.collectionView.reloadData()
        })
    }
    
}
