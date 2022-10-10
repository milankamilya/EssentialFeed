//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by MK on 10/10/22.
//

import EssentialFeed
import UIKit
import EssentialFeediOS
import Combine

final public class CommentsUIComposer {
    private init() {}

    public static func commentsComposedWith(
        commentsLoader: @escaping () -> AnyPublisher<[ImageComment], Error>) -> ListViewController {

        let presentationAdapter = LoadResourcePresentationAdapter<[ImageComment], CommentsViewAdapter>(loader: commentsLoader)
        
        let commentsController = makeCommentsViewController(title: ImageCommentsPresenter.title)
        commentsController.onRefresh = presentationAdapter.loadResource
        
        presentationAdapter.presenter = LoadResourcePresenter(
            loadingView: WeakRefVirtualProxy(commentsController),
            resourceView: CommentsViewAdapter(controller: commentsController),
            errorView: WeakRefVirtualProxy(commentsController),
            mapper: { ImageCommentsPresenter.map($0) })
        
        return commentsController
    }
    
    private static func makeCommentsViewController(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.title = title
        return feedController
    }
}

final class CommentsViewAdapter: ResourceView {
    weak var controller: ListViewController?
    
    init(controller: ListViewController) {
        self.controller = controller
    }
    
    func display(_ viewModel: ImageCommentsViewModel) {
        controller?.display(viewModel.comments.map({ viewModel in
            CellController(id: viewModel, ImageCommentCellController(model: viewModel))
        }))
    }
}
