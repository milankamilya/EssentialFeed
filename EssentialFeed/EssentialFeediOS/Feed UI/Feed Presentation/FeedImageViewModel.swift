//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by MK on 08/12/21.
//

import Foundation

struct FeedImageViewModel<Image> {
    let image: Image?
    let description: String?
    let location: String?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}
