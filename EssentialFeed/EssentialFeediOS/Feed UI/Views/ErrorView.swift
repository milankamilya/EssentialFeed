//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by MK on 17/12/21.
//

import UIKit

public final class ErrorView: UIView {
    public var message: String? {
        get { return label?.text }
        set { label?.text = newValue }
    }
    
    @IBOutlet private var label: UILabel?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        label?.text = nil
    }
    
    public func showMessage(_ message: String) {
        self.message = message
    }
    
    public func hideMessage() {
        self.message = nil
    }
}
