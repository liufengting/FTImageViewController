//
//  FTImageViewController.swift
//  FTImageViewController
//
//  Created by liufengting on 2018/7/27.
//  Copyright © 2018年 liufengting. All rights reserved.
//

import UIKit
import FTImageTransition

@objc public protocol FTImageViewControllerDelegate: NSObjectProtocol {
    
    @objc optional func ftImageViewControllerShouldTapToDismiss(imageViewController: FTImageViewController) -> Bool
    @objc optional func ftImageViewController(imageViewController: FTImageViewController, didScrollToPage page: NSInteger)
    @objc optional func ftImageViewController(imageViewController: FTImageViewController, imageScrollView: FTImageScrollView, didRecognizeSingleTapGesture gesture: UITapGestureRecognizer)
    @objc optional func ftImageViewController(imageViewController: FTImageViewController, imageScrollView: FTImageScrollView, didZoomOutAt scale: CGFloat)
    @objc optional func ftImageViewController(imageViewController: FTImageViewController, imageScrollView: FTImageScrollView, didZoomInAt scale: CGFloat)
    
    // life cycle
    @objc optional func ftImageViewControllerWillPresent(imageViewController: FTImageViewController)
    @objc optional func ftImageViewControllerDidPresent(imageViewController: FTImageViewController)
    @objc optional func ftImageViewControllerWillDismiss(imageViewController: FTImageViewController)
    @objc optional func ftImageViewControllerDidCancelDismiss(imageViewController: FTImageViewController)
    @objc optional func ftImageViewControllerDidDismiss(imageViewController: FTImageViewController)
}

public protocol FTImageViewControllerDataSource: NSObjectProtocol {
    func numberOfImages(in imageViewController: FTImageViewController) -> Int
    func ftImageViewController(imageViewController: FTImageViewController, imageResourceFor index: NSInteger) -> FTImageResource
    func ftImageViewController(imageViewController: FTImageViewController, viewForIndex: NSInteger) -> UIView?
    func ftImageViewController(imageViewController: FTImageViewController, sourceImageForIndex: NSInteger) -> UIImage?
}

extension UIViewController {
    
    func ft_present(imageViewController: FTImageViewController) {
        
    }
    
}

extension FTImageViewController {
    

}

extension FTImageViewController: FTImageTransitionDelegate {

    public func ftImageTransitionWillStartPresent(transition: FTImageTransition?, transitionContext: UIViewControllerContextTransitioning) {
        if self.delegate != nil && (self.delegate?.responds(to: #selector(FTImageViewControllerDelegate.ftImageViewControllerWillPresent(imageViewController:))))! {
            self.delegate?.ftImageViewControllerWillPresent!(imageViewController: self)
        }
    }

    public func ftImageTransitionDidFinishPresent(transition: FTImageTransition?, transitionContext: UIViewControllerContextTransitioning) {
        if self.delegate != nil && (self.delegate?.responds(to: #selector(FTImageViewControllerDelegate.ftImageViewControllerDidPresent(imageViewController:))))! {
            self.delegate?.ftImageViewControllerDidPresent!(imageViewController: self)
        }
    }

    public func ftImageTransitionWillStartDismiss(transition: FTImageTransition?, transitionContext: UIViewControllerContextTransitioning) {
        if self.initialModel == .datasource && self.dataSource != nil {
            if let view = self.dataSource?.ftImageViewController(imageViewController: self, viewForIndex: self.currentIndex) {
                view.isHidden = true
                transition?.config.targetFrame = self.imageViewFrameForCurrentIndex()
                transition?.config.transitionImageView.image = self.imageForCurrentIndex()
                transition?.config.sourceFrame = (view.superview?.convert(view.frame, to: UIApplication.shared.keyWindow))!
            }
        }
        if self.delegate != nil && (self.delegate?.responds(to: #selector(FTImageViewControllerDelegate.ftImageViewControllerWillDismiss(imageViewController:))))! {
            self.delegate?.ftImageViewControllerWillDismiss!(imageViewController: self)
        }
    }

    public func ftImageTransitionDidCancelDismiss(transition: FTImageTransition?, transitionContext: UIViewControllerContextTransitioning) {
        if self.delegate != nil && (self.delegate?.responds(to: #selector(FTImageViewControllerDelegate.ftImageViewControllerDidCancelDismiss(imageViewController:))))! {
            self.delegate?.ftImageViewControllerDidCancelDismiss!(imageViewController: self)
        }
    }

    public func ftImageTransitionDidFinishDismiss(transition: FTImageTransition?, transitionContext: UIViewControllerContextTransitioning) {
        if self.initialModel == .datasource && self.dataSource != nil {
            if let view = self.dataSource?.ftImageViewController(imageViewController: self, viewForIndex: self.currentIndex) {
                view.isHidden = false
            }
        }
        if self.delegate != nil && (self.delegate?.responds(to: #selector(FTImageViewControllerDelegate.ftImageViewControllerDidDismiss(imageViewController:))))! {
            self.delegate?.ftImageViewControllerDidDismiss!(imageViewController: self)
        }
    }
}

enum FTImageViewControllerInitialMode {
    case array
    case datasource
}

open class FTImageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FTImageScrollViewDelegate {

    var initialModel: FTImageViewControllerInitialMode = .array
    
    public var currentIndex: NSInteger = 0
    
    public var imageResources: [FTImageResource] = [] {
        willSet {
            self.initialModel = .array
        }
    }
    
    public weak var dataSource: FTImageViewControllerDataSource? = nil {
        willSet {
            self.initialModel = .datasource
        }
    }
    
    public weak var delegate: FTImageViewControllerDelegate? = nil
    
    public lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        layout.itemSize = CGSize(width: UIScreen.width(), height: UIScreen.height())
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        return layout
    }()
    
    public lazy var collectionView: FTImageCollectionView = {
        let cv = FTImageCollectionView(frame: self.view.bounds, collectionViewLayout: self.flowLayout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(FTImageCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: FTImageCollectionViewCell.identifier)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()

    public lazy var ftZoomTransition: FTImageTransition = {
        let transition = FTImageTransition()
        transition.delegate = self
        return transition
    }()
    
    public func setupWith(images: [FTImageResource], selectedIndex: NSInteger, sourceView: UIView? = nil, sourceImage: UIImage? = nil) {
        self.imageResources = images
        self.currentIndex = selectedIndex
        self.configTransition(sourceView: sourceView, sourceImage: sourceImage)
    }
    
    public func setupWith(dataSource: FTImageViewControllerDataSource, selectedIndex: NSInteger) {
        self.dataSource = dataSource
        self.currentIndex = selectedIndex
        
        var sourceView: UIView? = nil
        var sourceImage: UIImage? = nil
        if self.dataSource != nil {
            sourceView = self.dataSource?.ftImageViewController(imageViewController: self, viewForIndex: self.currentIndex)
            sourceImage = self.dataSource?.ftImageViewController(imageViewController: self, sourceImageForIndex: self.currentIndex)
        }
        self.configTransition(sourceView: sourceView, sourceImage: sourceImage)
    }
    
    func configTransition(sourceView: UIView? = nil, sourceImage: UIImage? = nil) {
        var targetRect : CGRect = CGRect.zero
        if let image: UIImage = sourceImage {
            targetRect = image.rectWithScreenSize()
        }
        let config = FTZoomTransitionConfig(sourceView: sourceView, image: sourceImage, targetFrame: targetRect)
        self.ftZoomTransition.config = config
        self.ftZoomTransition.wireGesturesTo(panGestureViewController: self, edgePanGestureView: self.collectionView)
        self.transitioningDelegate = self.ftZoomTransition
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialSetup()
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initialSetup()
    }
    
    func initialSetup() {

    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.automaticallyAdjustsScrollViewInsets = false
        self.addOrientationChangeNotification()
        self.view.addSubview(self.collectionView)
        let views: [String: AnyObject] = ["collectionView" : self.collectionView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"H:|-0-[collectionView]-0-|",options: [], metrics: [:],  views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|-0-[collectionView]-0-|",options: [], metrics: [:],  views:views))

        if self.currentIndex != 0 {
            self.scrollToPage(page: self.currentIndex, animated: false)
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    public func reload() {
        self.collectionView.reloadData()
        self.scrollToPage(page: currentIndex, animated: false)
    }
    
    public func imageViewFrameForCurrentIndex() -> CGRect {
        self.scrollToPage(page: self.currentIndex, animated: true)
        if let cell : FTImageCollectionViewCell = collectionView.cellForItem(at: IndexPath(item: self.currentIndex, section: 0)) as? FTImageCollectionViewCell {
            return cell.imageScrollView.convert(cell.imageScrollView.imageView.frame, to: UIApplication.shared.keyWindow)
        }
        return CGRect.zero
    }
    
    public func imageForCurrentIndex() -> UIImage? {
        if let cell : FTImageCollectionViewCell = collectionView.cellForItem(at: IndexPath(item: self.currentIndex, section: 0)) as? FTImageCollectionViewCell {
            return cell.imageScrollView.imageView.image
        }
        return nil
    }
    
    public func scrollToPage(page: NSInteger, animated: Bool) {
        self.collectionView.scrollToItem(at: IndexPath(item: page, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: animated)
        self.collectionView.layoutIfNeeded() // Note: add this line, so that 'collectionView.cellForItem(at:_)' does't return nil any more!!!
    }
    
    public func ftImageViewController(ftImageViewController: FTImageViewController, didScrollToPage page: NSInteger) {

    }
    
    fileprivate func imageReourceForIndexPath(indexPath: IndexPath) -> FTImageResource? {
        if self.initialModel == .datasource {
            if self.dataSource != nil {
                return self.dataSource?.ftImageViewController(imageViewController: self, imageResourceFor: indexPath.item)
            }
        }
        if indexPath.item <= self.imageResources.count - 1 {
            return self.imageResources[indexPath.item]
        }
        return nil
    }
    
    // MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.width(), height: UIScreen.height())
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.initialModel == .datasource {
            if self.dataSource != nil {
                return (self.dataSource?.numberOfImages(in: self))!
            }
        }
        return self.imageResources.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : FTImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: FTImageCollectionViewCell.identifier,
            for: indexPath) as! FTImageCollectionViewCell
        cell.setupWithImageResource(imageResource: self.imageReourceForIndexPath(indexPath: indexPath))
        cell.imageScrollView.tapDelegate = self
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.currentIndex = NSInteger(scrollView.contentOffset.x / scrollView.bounds.size.width)
        self.scrollToPage(page: self.currentIndex, animated: true)
        self.ftImageViewController(ftImageViewController: self, didScrollToPage: self.currentIndex)
        if self.delegate != nil && (self.delegate!.responds(to: #selector(FTImageViewControllerDelegate.ftImageViewController(imageViewController:didScrollToPage:))))  {
            self.delegate?.ftImageViewController!(imageViewController: self, didScrollToPage: self.currentIndex)
        }
    }
    
    // MARK: - FTImageScrollViewDelegate
    
    public func ftImageScrollView(imageScrollView: FTImageScrollView, didRecognizeSingleTapGesture gesture: UITapGestureRecognizer) {
        self.collectionView.layoutIfNeeded()
        var shouldDismiss: Bool = true
        if self.delegate != nil && (self.delegate?.responds(to: #selector(FTImageViewControllerDelegate.ftImageViewControllerShouldTapToDismiss(imageViewController:))))! {
            shouldDismiss = (self.delegate?.ftImageViewControllerShouldTapToDismiss!(imageViewController: self))!
        }
        if shouldDismiss {
            self.dismiss(animated: true) { }
        }
        if self.delegate != nil && (self.delegate!.responds(to: #selector(FTImageViewControllerDelegate.ftImageViewController(imageViewController:imageScrollView:didRecognizeSingleTapGesture:))))  {
            self.delegate?.ftImageViewController!(imageViewController: self, imageScrollView: imageScrollView, didRecognizeSingleTapGesture: gesture)
        }
    }
    
    public func ftImageScrollViewDidZoomIn(imageScrollView: FTImageScrollView, at scale: CGFloat) {
        if self.delegate != nil && (self.delegate!.responds(to: #selector(FTImageViewControllerDelegate.ftImageViewController(imageViewController:imageScrollView:didZoomInAt:))))  {
            self.delegate?.ftImageViewController!(imageViewController: self, imageScrollView: imageScrollView, didZoomInAt: scale)
        }
    }
    
    public func ftImageScrollViewDidZoomOut(imageScrollView: FTImageScrollView, at scale: CGFloat) {
        if self.delegate != nil && (self.delegate!.responds(to: #selector(FTImageViewControllerDelegate.ftImageViewController(imageViewController:imageScrollView:didZoomOutAt:))))  {
            self.delegate?.ftImageViewController!(imageViewController: self, imageScrollView: imageScrollView, didZoomOutAt: scale)
        }
    }
    
    deinit {
        self.removeOrientationChangeNotification()
    }

}

extension FTImageViewController {
    
    fileprivate func addOrientationChangeNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onChangeStatusBarOrientationNotification(notification:)),
                                               name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation,
                                               object: nil)
    }
    
    fileprivate func removeOrientationChangeNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func onChangeStatusBarOrientationNotification(notification : Notification) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.reload()
        })
    }

}
