//
//  UITableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by MK on 09/12/21.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        let cell = dequeueReusableCell(withIdentifier: identifier)
        return cell as! T
    }
}
