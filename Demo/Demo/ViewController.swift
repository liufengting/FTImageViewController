//
//  ViewController.swift
//  Demo
//
//  Created by liufengting on 2018/7/27.
//  Copyright © 2018年 liufengting. All rights reserved.
//

import UIKit
import FTZoomTransition

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
    
    func screenWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    func screenHeight() -> CGFloat {
        return UIScreen.main.bounds.size.height
    }
        
    // MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.cellMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return self.cellMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
        
        let sender = collectionView.cellForItem(at: indexPath)
        
        // present
        
        var images: [FTImageResource] = []
        for (_, value) in self.dataArray.enumerated() {
            images.append(FTImageResource(image: nil, imageURLString: value))
        }
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        flowLayout.itemSize = CGSize(width: UIScreen.width(), height: UIScreen.height())
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 0.0
        let detial = FTImageViewController(collectionViewLayout: flowLayout, images: images)
        
        
        
        let screenWidth = UIScreen.main.bounds.size.width
        let targetRect = CGRect(x: 0, y: 64, width: screenWidth, height: screenWidth)

        let config = FTZoomTransitionConfig(sourceView: sender!,
                                            targetView: detial.view,
                                            targetFrame: targetRect)
        ftZoomTransition.config = config
        ftZoomTransition.wirePanDismissToViewController(detial, for: detial.collectionView)
        detial.transitioningDelegate = ftZoomTransition
        self.present(detial, animated: true, completion: {

        })
//
    }

}

