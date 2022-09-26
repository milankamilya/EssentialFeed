//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by MK on 27/12/21.
//

import Foundation

public final class FeedImagePresenter {
    public static func map(_ image: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            description: image.description,
            location: image.location
        )
    }
}
