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
    
    public func sizeWithHeight(height: CGFloat) -> CGSize {
        var size = CGSize.zero
        size.height = height
        size.width = (self.size.width * height)/self.size.height
        return size
    }
    
    public func sizeWithScreenSize() -> CGSize {
        return self.sizeWithWidth(width: min(UIScreen.width(), UIScreen.height()))
    }
    
    public func rectWithScreenSize() -> CGRect {
        let size = self.sizeWithScreenSize()
        if size.height > UIScreen.height() {
            return CGRect(origin: CGPoint(x: (UIScreen.width() - size.width)/2.0, y: 0), size: size)
        } else {
            return CGRect(origin: CGPoint(x: (UIScreen.width() - size.width)/2.0, y: (UIScreen.height() - size.height)/2.0), size: size)
        }
    }
    
}
