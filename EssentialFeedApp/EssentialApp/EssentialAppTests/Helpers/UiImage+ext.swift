//
//  UiImage+ext.swift
//  EssentialAppTests
//
//  Created by Habibur Rahman on 9/12/24.
//

import Foundation
import UIKit

extension UIImage {
    public static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(rect)
        }
    }
}
