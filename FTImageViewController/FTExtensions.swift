//
//  FTExtensions.swift
//  Demo
//
//  Created by liufengting on 2018/7/30.
//  Copyright © 2018年 liufengting. All rights reserved.
//

import UIKit

extension UIScreen {
    
    public static func width() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
    public static func height() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
}

extension UIImage {
    
    public func sizeWithWidth(width: CGFloat) -> CGSize {
        var size = CGSize.zero
        size.width = width
        size.height = (self.size.height * width)/self.size.width
        return size
    }
    
    public func sizeWithScreenWidth() -> CGSize {
        return self.sizeWithWidth(width: UIScreen.width())
    }
    
    public func rectWithScreenWidth() -> CGRect {
        let size = self.sizeWithScreenWidth()
        if size.height > UIScreen.height() {
            return CGRect(origin: CGPoint.zero, size: size)
        } else {
            return CGRect(origin: CGPoint(x: 0, y: (UIScreen.height() - size.height)/2.0), size: size)
        }
    }
    
}
