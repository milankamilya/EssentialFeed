//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by MK on 14/12/21.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}

