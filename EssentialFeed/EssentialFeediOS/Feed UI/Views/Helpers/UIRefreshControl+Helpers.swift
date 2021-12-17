//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by MK on 17/12/21.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
