//
//  UIImageView+Animations.swift
//  EssentialFeediOS
//
//  Created by MK on 09/12/21.
//

import UIKit

extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage
        
        guard newImage != nil else { return }
        
        self.alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1.0
        }
    }
}

