//
//  TextFieldExtension.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/19.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit

extension UITextField {
    func addBorderBottom(height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.height - height, width: self.frame.width, height: height)
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
    }
}
