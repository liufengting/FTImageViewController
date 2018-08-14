//
//  FTImageScrollView.swift
//  FTImageViewController
//
//  Created by liufengting on 2018/7/27.
//  Copyright © 2018年 liufengting. All rights reserved.
//

import UIKit
import Kingfisher

protocol FTImageResourceProtocol {
    var image : UIImage? { get }
    var imageURLString : String? { get }
}

public struct FTImageResource : FTImageResourceProtocol {
    var image: UIImage?
    var imageURLString: String?
    
    public init(image: UIImage?, imageURLString: String?) {
        self.image = image
        self.imageURLString = imageURLString
    }
}

@objc public protocol FTImageScrollViewDelegate: NSObjectProtocol {
    func ftImageScrollView(ftImageScrollView: FTImageScrollView, didRecognizeSingleTapGesture gesture: UITapGestureRecognizer)
    @objc optional func ftImageScrollViewDidZoomOut(ftImageScrollView: FTImageScrollView)
    @objc optional func ftImageScrollViewDidZoomIn(ftImageScrollView: FTImageScrollView)
}

public class FTImageScrollView: UIScrollView, UIScrollViewDelegate {

    open weak var tapDelegate: FTImageScrollViewDelegate?
    open lazy var imageView: UIImageView = {
        let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        iv.contentMode = UIView.ContentMode.scaleAspectFit
        return iv
    }()
    
    open lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(frame: CGRect(x: frame.width/2.0, y: frame.height/2.0, width: 40.0, height: 40.0))
        ai.activityIndicatorViewStyle = .white
        ai.hidesWhenStopped = true
        return ai
    }()

    open lazy var singleTapGesture : UITapGestureRecognizer = {
        let st = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(sender:)))
        st.numberOfTapsRequired = 1
        st.delaysTouchesBegan = true
        return st
    }()
    
    open lazy var doubleTapGesture : UITapGestureRecognizer = {
        let dt = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap(sender:)))
        dt.numberOfTapsRequired = 2
        dt.delaysTouchesBegan = true
        return dt
    }()
    
//    open lazy var panGesture : UIPanGestureRecognizer = {
//        let pg = UIPanGestureRecognizer()
//        pg.maximumNumberOfTouches = 1
//        pg.minimumNumberOfTouches = 1
//        return pg
//    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonSetup()
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonSetup()
    }
    
    fileprivate func commonSetup() {
        self.backgroundColor = UIColor.clear
        if #available(iOS 11.0, *) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        } else {

        }
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.decelerationRate = UIScrollViewDecelerationRateFast
        self.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        self.minimumZoomScale = 1.0
        self.maximumZoomScale = 3.0
        self.isScrollEnabled = true
        self.delegate = self
        self.setupGestures()
    }
    
    fileprivate func setupGestures() {
        singleTapGesture.require(toFail: doubleTapGesture)
        self.addGestureRecognizer(singleTapGesture)
        self.addGestureRecognizer(doubleTapGesture)
    }
    
    public override func setNeedsLayout() {
        super.setNeedsLayout()
        self.activityIndicator.frame = CGRect(x: frame.width/2.0, y: frame.height/2.0, width: 40.0, height: 40.0);
    }
    
    public func setupWithImageResource(imageResource : FTImageResource) {
        self.addSubview(activityIndicator)
        self.addSubview(imageView)
        
        self.loadImageResource(imageResource: imageResource)
    }
    
    fileprivate func loadImageResource(imageResource: FTImageResource) {
        activityIndicator.startAnimating()
        if let img : UIImage = imageResource.image {
            imageView.image = img
            activityIndicator.stopAnimating()
            self.updateFrameWithImage(image: img)
        }else if let imageURL : String = imageResource.imageURLString {
            imageView.kf.setImage(with: URL(string: imageURL)!,
                                  placeholder: nil,
                                  options: nil,
                                  progressBlock: { (done, total) in
                                    
            }) { (image, error, cashType, url) in
                if image != nil && error == nil {
                    self.activityIndicator.stopAnimating()
                }
                self.updateFrameWithImage(image: image)
            }
        }
    }
    
    func updateFrameWithImage(image: UIImage?) {
        if let im = image {
            let rect = im.rectWithScreenWidth()
            self.imageView.frame = rect
            self.contentSize = CGSize(width: UIScreen.width(), height: max(rect.height, UIScreen.height()))
        }
    }
    
    
    //    MARK: - UIScrollViewDelegate
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView?{
        return imageView
    }
        
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat){
        let ws = scrollView.frame.size.width - scrollView.contentInset.left - scrollView.contentInset.right
        let hs = scrollView.frame.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom
        let w = imageView.frame.size.width
        let h = imageView.frame.size.height
        var rct = imageView.frame
        rct.origin.x = (ws > w) ? (ws-w)/2 : 0
        rct.origin.y = (hs > h) ? (hs-h)/2 : 0
        imageView.frame = rct;
        print(rct)
    }
    
    //    MARK: - handleSingleTap
    
    @objc func handleSingleTap(sender: UITapGestureRecognizer){
        self.tapDelegate?.ftImageScrollView(ftImageScrollView: self, didRecognizeSingleTapGesture: sender)
    }
    
    //    MARK: - handleDoubleTap
    
    @objc func handleDoubleTap(sender: UITapGestureRecognizer){
        let touchPoint = sender.location(in: self)
        if (self.zoomScale == self.maximumZoomScale){
            self.setZoomScale(self.minimumZoomScale, animated: true)
            if (self.tapDelegate != nil && (self.tapDelegate?.responds(to: #selector(FTImageScrollViewDelegate.ftImageScrollViewDidZoomIn(ftImageScrollView:))))!) {
                self.tapDelegate?.ftImageScrollViewDidZoomIn!(ftImageScrollView: self)
            }
        }else{
            self.zoom(to: CGRect(x: touchPoint.x, y: touchPoint.y, width: 1, height: 1), animated: true)
            if (self.tapDelegate != nil && (self.tapDelegate?.responds(to: #selector(FTImageScrollViewDelegate.ftImageScrollViewDidZoomOut(ftImageScrollView:))))!) {
                self.tapDelegate?.ftImageScrollViewDidZoomOut!(ftImageScrollView: self)
            }
        }
    }
    
}
