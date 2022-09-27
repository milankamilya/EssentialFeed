//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by MK on 27/09/22.
//

import UIKit
import EssentialFeed

public class ImageCommentCellController: NSObject, CellController {
    
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.messageLabel.text = model.message
        cell.dateLabel.text = model.date
        cell.usernameLabel.text = model.username
        return cell
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
    }
}
