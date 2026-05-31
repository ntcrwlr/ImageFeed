@testable import ImageFeed
import XCTest

final class ImagesListPresenterTests: XCTestCase {
    func testViewDidLoadFetchesNextPage() {
        let service = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(imagesListService: service)

        presenter.viewDidLoad()

        XCTAssertEqual(service.fetchPhotosNextPageCallCount, 1)
    }

    func testDidUpdatePhotosUpdatesViewWithOldAndNewCount() {
        let service = ImagesListServiceSpy()
        service.photos = [
            Photo.make(id: "1"),
            Photo.make(id: "2")
        ]
        let view = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter(imagesListService: service)
        presenter.view = view

        presenter.didUpdatePhotos()

        XCTAssertEqual(view.updatedOldCount, 0)
        XCTAssertEqual(view.updatedNewCount, 2)
    }

    func testDidShowLastCellFetchesNextPage() {
        let service = ImagesListServiceSpy()
        service.photos = [Photo.make(id: "1")]
        let presenter = ImagesListPresenter(imagesListService: service)
        presenter.viewDidLoad()

        presenter.didShowCell(at: IndexPath(row: 0, section: 0))

        XCTAssertEqual(service.fetchPhotosNextPageCallCount, 2)
    }

    func testDidTapLikeChangesLikeAndUpdatesView() {
        let expectation = expectation(description: "Wait for like completion")
        let service = ImagesListServiceSpy()
        service.photos = [Photo.make(id: "1", isLiked: false)]
        let view = ImagesListViewControllerSpy()
        view.onSetIsLiked = {
            expectation.fulfill()
        }
        let presenter = ImagesListPresenter(imagesListService: service)
        presenter.view = view
        presenter.viewDidLoad()

        presenter.didTapLike(at: IndexPath(row: 0, section: 0))

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(service.changedLikePhotoId, "1")
        XCTAssertEqual(service.changedLikeValue, true)
        XCTAssertEqual(view.likeButtonEnabledValues, [false, true])
        XCTAssertEqual(view.isLikedValue, true)
    }
}

private final class ImagesListServiceSpy: ImagesListServiceProtocol {
    var photos: [Photo] = []
    var fetchPhotosNextPageCallCount = 0
    var changedLikePhotoId: String?
    var changedLikeValue: Bool?

    func fetchPhotosNextPage() {
        fetchPhotosNextPageCallCount += 1
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        changedLikePhotoId = photoId
        changedLikeValue = isLike
        completion(.success(()))
    }
}

private final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var updatedOldCount: Int?
    var updatedNewCount: Int?
    var reloadedIndexPaths: [IndexPath] = []
    var likeButtonEnabledValues: [Bool] = []
    var isLikedValue: Bool?
    var onSetIsLiked: (() -> Void)?

    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        updatedOldCount = oldCount
        updatedNewCount = newCount
    }

    func reloadRows(at indexPaths: [IndexPath]) {
        reloadedIndexPaths = indexPaths
    }

    func setLikeButtonEnabled(_ isEnabled: Bool, at indexPath: IndexPath) {
        likeButtonEnabledValues.append(isEnabled)
    }

    func setIsLiked(_ isLiked: Bool, at indexPath: IndexPath) {
        isLikedValue = isLiked
        onSetIsLiked?()
    }
}
