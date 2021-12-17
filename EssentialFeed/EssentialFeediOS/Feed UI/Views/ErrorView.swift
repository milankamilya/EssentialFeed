//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by MK on 17/12/21.
//

import UIKit

public final class ErrorView: UIView {
    public var message: String?
    @IBOutlet private(set) public var label: UILabel?
    
    public func showMessage(_ message: String) {
        self.message = message
    }
    
    public func hideMessage() {
        self.message = nil
    }
}
