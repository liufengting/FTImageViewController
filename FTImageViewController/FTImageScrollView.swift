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
    func ftImageScrollView(imageScrollView: FTImageScrollView, didRecognizeSingleTapGesture gesture: UITapGestureRecognizer)
    @objc optional func ftImageScrollViewDidZoomOut(imageScrollView: FTImageScrollView, at scale: CGFloat)
    @objc optional func ftImageScrollViewDidZoomIn(imageScrollView: FTImageScrollView, at scale: CGFloat)
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
        }
        self.decelerationRate = UIScrollViewDecelerationRateNormal
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
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
    
    public func prepareForReuse() {
        self.setZoomScale(1.0, animated: true)
        self.updateFrameWithImage(image: imageView.image)
    }
    
    public func setupWithImageResource(imageResource : FTImageResource?) {
        self.addSubview(activityIndicator)
        self.addSubview(imageView)
        self.loadImageResource(imageResource: imageResource)
    }
    
    fileprivate func loadImageResource(imageResource: FTImageResource?) {
        activityIndicator.startAnimating()
        if let resource: FTImageResource = imageResource {
            if let img : UIImage = resource.image {
                imageView.image = img
                activityIndicator.stopAnimating()
                self.updateFrameWithImage(image: img)
            }else if let imageURL : String = resource.imageURLString {
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
    }
    
    public func updateFrameWithImage(image: UIImage?) {
        if let im = image {
            let rect = im.rectWithScreenSize()
            self.imageView.frame = rect
            self.contentSize = CGSize(width: UIScreen.width(), height: max(rect.height, UIScreen.height()))
        }
    }
    
    //    MARK: - UIScrollViewDelegate
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView?{
        return imageView
    }

    //    MARK: - handleSingleTap
    
    @objc func handleSingleTap(sender: UITapGestureRecognizer){
        self.tapDelegate?.ftImageScrollView(imageScrollView: self, didRecognizeSingleTapGesture: sender)
    }
    
    //    MARK: - handleDoubleTap
    
    @objc func handleDoubleTap(sender: UITapGestureRecognizer){
        let touchPoint = sender.location(in: self.imageView)
        if (self.zoomScale > self.minimumZoomScale) {
            self.setZoomScale(self.minimumZoomScale, animated: true)
            if (self.tapDelegate != nil && (self.tapDelegate?.responds(to: #selector(FTImageScrollViewDelegate.ftImageScrollViewDidZoomIn(imageScrollView:at:))))!) {
                self.tapDelegate?.ftImageScrollViewDidZoomIn!(imageScrollView: self, at: self.minimumZoomScale)
            }
        } else {
            let zoomRect = zoomRectForScrollViewWith(maximumZoomScale, touchPoint: touchPoint)
            zoom(to: zoomRect, animated: true)
            if (self.tapDelegate != nil && (self.tapDelegate?.responds(to: #selector(FTImageScrollViewDelegate.ftImageScrollViewDidZoomOut(imageScrollView:at:))))!) {
                self.tapDelegate?.ftImageScrollViewDidZoomOut!(imageScrollView: self, at: self.maximumZoomScale)
            }
        }
    }

    func zoomRectForScrollViewWith(_ scale: CGFloat, touchPoint: CGPoint) -> CGRect {
        let w = frame.size.width / scale
        let h = frame.size.height / scale
        let x = touchPoint.x - (h / max(UIScreen.main.scale, 2.0))
        let y = touchPoint.y - (w / max(UIScreen.main.scale, 2.0))
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
}
