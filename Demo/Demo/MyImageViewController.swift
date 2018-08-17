//
//  MyImageViewController.swift
//  Demo
//
//  Created by liufengting on 2018/8/17.
//  Copyright © 2018年 liufengting. All rights reserved.
//

import FTImageViewController

class MyImageViewController: FTImageViewController, FTImageViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    //    MARK: - FTImageViewControllerDelegate
    
    func ftImageViewController(imageViewController: FTImageViewController, didScrollToPage page: NSInteger) {
        
    }

}
