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

public class FTImageViewController: UICollectionViewController, FTImageScrollViewDelegate {

    var imageResources: [FTImageResource] = []
    var currentIndex: NSInteger = 0
    var previousStatusBarStyle = UIStatusBarStyle.lightContent
    
    
    convenience init(collectionViewLayout layout: UICollectionViewLayout, images: [FTImageResource]) {
        self.init(collectionViewLayout: layout)
        self.imageResources = images
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = UIColor.black
        self.collectionView.isPagingEnabled = true
        self.collectionView.alwaysBounceHorizontal = true
        self.collectionView.register(FTImageCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: FTImageCollectionViewCell.identifier)
        self.collectionView.reloadData()
        self.previousStatusBarStyle = UIApplication.shared.statusBarStyle
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    public func reloadWithImages(images: [FTImageResource], selectedIndex: NSInteger) {
        self.imageResources = images
        if self.collectionView != nil {
            self.collectionView.reloadData()
            self.scrollToPage(page: selectedIndex, animated: true)
        }
    }
    
    public func scrollToPage(page: NSInteger, animated: Bool) {
        if page != self.currentIndex {
            self.collectionView.scrollToItem(at: IndexPath(item: (min(max(0, page), self.imageResources.count-1)), section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: animated)
        }
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
    
    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageResources.count
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : FTImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: FTImageCollectionViewCell.identifier,
            for: indexPath) as! FTImageCollectionViewCell
        cell.setupWithImageResource(imageResource: self.imageResources[indexPath.item])
        cell.imageScrollView.tapDelegate = self
        return cell
    }
    
    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    
    // MARK: - FTImageScrollViewDelegate
    
    public func ftImageScrollView(ftImageScrollView: FTImageScrollView, didRecognizeSingleTapGesture gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true) { }
    }
}

extension FTImageViewController {
    
    fileprivate func addOrientationChangeNotification() {
        NotificationCenter.default.addObserver(self,selector: #selector(onChangeStatusBarOrientationNotification(notification:)),
                                               name: UIApplication.didChangeStatusBarOrientationNotification,
                                               object: nil)
    }
    
    fileprivate func removeOrientationChangeNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func onChangeStatusBarOrientationNotification(notification : Notification) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
//            self.setupView(shouldAnimate: false)
            self.collectionView.reloadData()
        })
    }
    
}
