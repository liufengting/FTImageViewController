//
//  FTImageViewController.swift
//  FTImageViewController
//
//  Created by liufengting on 2018/7/27.
//  Copyright © 2018年 liufengting. All rights reserved.
//

import UIKit
import FTZoomTransition

public protocol FTImageViewControllerDelegate {
    
    func ftImageViewController(ftImageViewController: FTImageViewController, didScrollToPage page: NSInteger)

}

open class FTImageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FTImageScrollViewDelegate , FTPanDismissAnimatorDelegate{

    var imageResources: [FTImageResource] = []
    var currentIndex: NSInteger = 0
    
    public lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        flowLayout.itemSize = CGSize(width: UIScreen.width(), height: UIScreen.height())
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 0.0
        let cv = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        cv.backgroundColor = .clear
        cv.isPagingEnabled = true
        cv.register(FTImageCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: FTImageCollectionViewCell.identifier)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()

    public convenience init(images: [FTImageResource], selectedIndex: NSInteger) {
        self.init()
        self.imageResources = images
        self.currentIndex = selectedIndex
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.view.addSubview(self.collectionView)
        if self.currentIndex != 0 {
            self.scrollToPage(page: self.currentIndex, animated: false)
        }
        
        if let transDelegate: FTZoomTransition = self.transitioningDelegate as? FTZoomTransition {
            transDelegate.panDismissAnimator.wireToViewController(self, delegate: self)
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionView.frame = self.view.bounds
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    public func reloadWithImages(images: [FTImageResource], selectPage: NSInteger) {
        self.imageResources = images
        self.collectionView.reloadData()
        self.scrollToPage(page: selectPage, animated: true)
    }
    
    public func scrollToPage(page: NSInteger, animated: Bool) {
        self.collectionView.scrollToItem(at: IndexPath(item: (min(max(0, page), self.imageResources.count-1)), section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: animated)
    }
    
    public func ftImageViewController(ftImageViewController: FTImageViewController, didScrollToPage page: NSInteger) {

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
        return self.imageResources.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : FTImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: FTImageCollectionViewCell.identifier,
            for: indexPath) as! FTImageCollectionViewCell
        cell.setupWithImageResource(imageResource: self.imageResources[indexPath.item])
        cell.imageScrollView.tapDelegate = self
        cell.panGesture.addTarget(self, action: #selector(handlePanGesture(gesture:)))
        return cell
    }
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        if let transDelegate: FTZoomTransition = self.transitioningDelegate as? FTZoomTransition {
            transDelegate.panDismissAnimator.handlePanGesture(gesture)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    // MARK: - FTImageScrollViewDelegate
    
    public func ftImageScrollView(ftImageScrollView: FTImageScrollView, didRecognizeSingleTapGesture gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true) { }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.currentIndex = NSInteger(scrollView.contentOffset.x / scrollView.bounds.size.width)
        self.ftImageViewController(ftImageViewController: self, didScrollToPage: self.currentIndex)
    }
    
    
    public func viewControllerWillDismiss(viewController: UIViewController) {
        if let cell : FTImageCollectionViewCell = collectionView.cellForItem(at: IndexPath(item: self.currentIndex, section: 0)) as? FTImageCollectionViewCell {
            if let transDelegate: FTZoomTransition = self.transitioningDelegate as? FTZoomTransition {
                transDelegate.config.targetFrame = cell.imageScrollView.imageView.frame
                transDelegate.config.transitionImageView.image = cell.imageScrollView.imageView.image
            }
        }
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
            self.collectionView.reloadData()
        })
    }
    
}
