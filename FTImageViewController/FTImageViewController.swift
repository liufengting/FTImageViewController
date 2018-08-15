//
//  FTImageViewController.swift
//  FTImageViewController
//
//  Created by liufengting on 2018/7/27.
//  Copyright © 2018年 liufengting. All rights reserved.
//

import UIKit
import FTImageTransition

public protocol FTImageViewControllerDelegate {
    func ftImageViewController(ftImageViewController: FTImageViewController, didScrollToPage page: NSInteger)
}

open class FTImageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FTImageScrollViewDelegate {

    public var imageResources: [FTImageResource] = []
    public var currentIndex: NSInteger = 0
    
    public lazy var collectionView: FTImageCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        flowLayout.itemSize = CGSize(width: UIScreen.width(), height: UIScreen.height())
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 0.0
        let cv = FTImageCollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
//        [leftButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        cv.translatesAutoresizingMaskIntoConstraints = false
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
        self.addOrientationChangeNotification()
        self.view.addSubview(self.collectionView)
        let views: [String: AnyObject] = ["collectionView" : self.collectionView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"H:|-0-[collectionView]-0-|",options: [], metrics: [:],  views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|-0-[collectionView]-0-|",options: [], metrics: [:],  views:views))

        
        if self.currentIndex != 0 {
            self.scrollToPage(page: self.currentIndex, animated: false)
        }
        
//        if let gestures = self.view.gestureRecognizers {
//            for recognizer in gestures {
//                if recognizer.isKind(of: UIScreenEdgePanGestureRecognizer.classForCoder()) {
//                    self.collectionView.panGestureRecognizer.require(toFail: recognizer as! UIScreenEdgePanGestureRecognizer)
//                    break
//                }
//            }
//        }
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
    
    func reload() {
        self.collectionView.reloadData()
        self.scrollToPage(page: currentIndex, animated: false)
    }
    
    public func rectForCurrentIndex() -> CGRect {
        if let cell : FTImageCollectionViewCell = collectionView.cellForItem(at: IndexPath(item: self.currentIndex, section: 0)) as? FTImageCollectionViewCell {
            return cell.convert(cell.imageScrollView.imageView.frame, to: UIApplication.shared.keyWindow)
        }
        return CGRect.zero
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
//        cell.panGesture.addTarget(self, action: #selector(handlePanGesture(gesture:)))
        return cell
    }
    
//    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
//        if let transDelegate: FTImageTransition = self.transitioningDelegate as? FTImageTransition {
//            transDelegate.panDismissAnimator.handlePanGesture(gesture)
//        }
//    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.currentIndex = NSInteger(scrollView.contentOffset.x / scrollView.bounds.size.width)
        self.ftImageViewController(ftImageViewController: self, didScrollToPage: self.currentIndex)
    }
    
    
    // MARK: - FTImageScrollViewDelegate
    
    public func ftImageScrollView(ftImageScrollView: FTImageScrollView, didRecognizeSingleTapGesture gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true) { }
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
