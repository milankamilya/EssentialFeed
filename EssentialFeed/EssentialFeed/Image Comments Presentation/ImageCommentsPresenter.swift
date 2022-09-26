//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by MK on 26/09/22.
//

import Foundation

public class ImageCommentsPresenter {
    public static var title: String {
        return NSLocalizedString(
            "IMAGE_COMMENTS_VIEW_TITLE",
            tableName: "ImageComments",
            bundle: Bundle(for: Self.self),
            comment: "Title for the image comments view")
    }
}
