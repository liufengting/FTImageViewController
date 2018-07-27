//
//  ImageCollectionViewCell.swift
//  Demo
//
//  Created by liufengting on 2018/7/27.
//  Copyright © 2018年 liufengting. All rights reserved.
//

import UIKit
import Kingfisher

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var contentImageView: UIImageView!
    
    func setupWithImageUrl(imageUrl: String) {
        self.contentImageView.kf.setImage(with: URL(string: imageUrl)!)
    }
    
}
