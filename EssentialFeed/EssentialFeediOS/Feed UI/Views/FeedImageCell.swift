//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by MK on 29/11/21.
//

import Foundation
import UIKit

public final class FeedImageCell: UITableViewCell {
    
    @IBOutlet private(set) public var locationContainer: UIView!
    @IBOutlet private(set) public var locationLabel: UILabel!
    @IBOutlet private(set) public var descriptionLabel: UILabel!
    @IBOutlet private(set) public var feedImageContainer: UIView!
    @IBOutlet private(set) public var feedImageView: UIImageView!
    @IBOutlet private(set) public var feedImageRetryButton: UIButton!
    
    var onRetry: (() -> Void)?
 
    @IBAction private func retryButtonTapped() {
        onRetry?()
    }
}
