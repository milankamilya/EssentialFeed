//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by MK on 17/12/21.
//

import UIKit

public final class ErrorView: UIView {
    public var message: String? {
        get { return isVisible ? label?.text : nil }
        set { setMessageAnimated(newValue) }
    }
    
    @IBOutlet private var label: UILabel!
    
    private var isVisible: Bool {
        alpha > 0
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        label.text = nil
        alpha = 0
    }
    
    private func setMessageAnimated(_ message: String?) {
        if let message = message {
            showAnimated(message)
        } else {
            hideMessageAnimated()
        }
    }
    
    private func showAnimated(_ message: String) {
        label.text = message
        
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
    
    private func hideMessageAnimated() {
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0 },
            completion: { completed in
                if completed { self.label.text = nil }
            })
    }
}
