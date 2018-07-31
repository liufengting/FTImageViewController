//
//  ViewController.swift
//  Demo
//
//  Created by liufengting on 2018/7/27.
//  Copyright © 2018年 liufengting. All rights reserved.
//

import UIKit
import FTZoomTransition
import FTImageViewController

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    let ftZoomTransition = FTZoomTransition()

    let cellMargin : CGFloat = 1.0
    let cellColums : NSInteger = 3
    lazy var cellWidth : CGFloat = {
        return (UIScreen.main.bounds.size.width - self.cellMargin * CGFloat(self.cellColums - 1))/CGFloat(self.cellColums);
    }()
    
    
    var dataArray : [String] = ["https://ws1.sinaimg.cn/mw600/a2e93f36gy1fto9w7lofsj20v80sgtdi.jpg",
                                "https://ws3.sinaimg.cn/mw600/e0e4ecc3gy1fto9n5r93rj20gt0p10vw.jpg",
                                "https://wx2.sinaimg.cn/mw600/006mYqTmly4ftrrukfzofj30es0kyq4o.jpg",
                                "https://wx2.sinaimg.cn/mw600/6d09a066gy1ftrsx6r1u1j20m818gwx7.jpg",
                                "https://ww3.sinaimg.cn/mw600/0073ob6Pgy1ftrssmtar0j310t1jk15s.jpg",
                                "https://ww3.sinaimg.cn/mw600/006XNEY7gy1ftrseng1r8j30e809hq4a.jpg",
                                "https://ww3.sinaimg.cn/mw600/0073tLPGgy1ftrqxqpitzj30u014041o.jpg",
                                "https://wx3.sinaimg.cn/mw600/005BYxJSly1ftrlohc169j30u00u0djv.jpg",
                                "https://wx3.sinaimg.cn/mw600/00731fumly1ftplr9ac4cj30ci1d5q5t.jpg",
                                "https://ws1.sinaimg.cn/mw600/a2e93f36gy1fto9w7lofsj20v80sgtdi.jpg",
                                "https://ws1.sinaimg.cn/mw600/a2e93f36gy1fto9w7lofsj20v80sgtdi.jpg",
                                "https://ws1.sinaimg.cn/mw600/a2e93f36gy1fto9w7lofsj20v80sgtdi.jpg",
                                "https://ws1.sinaimg.cn/mw600/a2e93f36gy1fto9w7lofsj20v80sgtdi.jpg",
                                "https://ws1.sinaimg.cn/mw600/a2e93f36gy1fto9w7lofsj20v80sgtdi.jpg",
                                "https://ws1.sinaimg.cn/mw600/a2e93f36gy1fto9w7lofsj20v80sgtdi.jpg",
                                "https://ws1.sinaimg.cn/mw600/a2e93f36gy1fto9w7lofsj20v80sgtdi.jpg",
                                "https://ws1.sinaimg.cn/mw600/a2e93f36gy1fto9w7lofsj20v80sgtdi.jpg",
                                "https://ws1.sinaimg.cn/mw600/a2e93f36gy1fto9w7lofsj20v80sgtdi.jpg",
                                "https://ws1.sinaimg.cn/mw600/a2e93f36gy1fto9w7lofsj20v80sgtdi.jpg",
                                "https://ws1.sinaimg.cn/mw600/a2e93f36gy1fto9w7lofsj20v80sgtdi.jpg",
                                "https://ws1.sinaimg.cn/mw600/a2e93f36gy1fto9w7lofsj20v80sgtdi.jpg",
                                "https://ws1.sinaimg.cn/mw600/a2e93f36gy1fto9w7lofsj20v80sgtdi.jpg",
                                "https://ws1.sinaimg.cn/mw600/a2e93f36gy1fto9w7lofsj20v80sgtdi.jpg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
        
    // MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.cellMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return self.cellMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.cellWidth, height: self.cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : ImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(ImageCollectionViewCell.classForCoder())",
                                for: indexPath) as! ImageCollectionViewCell
        cell.setupWithImageUrl(imageUrl: self.dataArray[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        self.handleCellTapAtIndexPath(indexPath: indexPath)
    }
    
    func handleCellTapAtIndexPath(indexPath: IndexPath) {
        
        let sender : ImageCollectionViewCell = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
        
        // present
        
        var images: [FTImageResource] = []
        for (_, value) in self.dataArray.enumerated() {
            images.append(FTImageResource(image: nil, imageURLString: value))
        }
        

        let detial = FTImageViewController(images: images, selectedIndex: indexPath.item)
        let targetRect : CGRect = (sender.contentImageView.image?.rectWithScreenWidth())!

        let config = FTZoomTransitionConfig(sourceView: sender,
                                            image: sender.contentImageView.image,
                                            targetFrame: targetRect)
        ftZoomTransition.config = config
        ftZoomTransition.wirePanDismissToViewController(detial, for: detial.collectionView)
        detial.transitioningDelegate = ftZoomTransition
        self.present(detial, animated: true, completion: {

        })
//
    }

}
