//
//  FTImageContainerViewController.swift
//  FTImageViewController
//
//  Created by liufengting on 2018/8/10.
//

import UIKit

class FTImageContainerViewController: UIViewController {

    public lazy var panGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer()
//        pan.delegate = self
        return pan
    }()
    
    public var imageResource: FTImageResource? = nil

    public lazy var imageScrollView : FTImageScrollView = {
        let imageSV = FTImageScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.width(), height: UIScreen.height()))
//        imageSV.addGestureRecognizer(self.panGesture)
        return imageSV
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if self.imageScrollView.superview != nil {
            self.imageScrollView.removeFromSuperview()
        }
        if self.imageScrollView.superview == nil {
            self.view.addSubview(self.imageScrollView)
        }
        self.setupWithImageResource(imageResource: self.imageResource)
    }
    
    public func setupWithImageResource(imageResource: FTImageResource?) {
        self.imageResource = imageResource
        if self.imageResource != nil {
            self.imageScrollView.setupWithImageResource(imageResource: self.imageResource!)
        }
    }



}
