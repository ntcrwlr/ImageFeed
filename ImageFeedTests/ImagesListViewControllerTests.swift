@testable import ImageFeed
import XCTest

final class ImagesListViewControllerTests: XCTestCase {
    func testViewControllerCallsPresenterViewDidLoad() {
        let viewController = makeViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)

        _ = viewController.view

        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testTableViewNumberOfRowsUsesPresenterPhotos() throws {
        let viewController = makeViewController()
        let presenter = ImagesListPresenterSpy()
        presenter.photos = [
            Photo.make(id: "1"),
            Photo.make(id: "2")
        ]
        viewController.configure(presenter)

        _ = viewController.view
        let tableView = try XCTUnwrap(viewController.view.findTableView())
        let rows = tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0)

        XCTAssertEqual(rows, 2)
    }

    func testWillDisplayCellNotifiesPresenter() throws {
        let viewController = makeViewController()
        let presenter = ImagesListPresenterSpy()
        presenter.photos = [Photo.make(id: "1")]
        viewController.configure(presenter)

        _ = viewController.view
        let tableView = try XCTUnwrap(viewController.view.findTableView())
        viewController.tableView(tableView, willDisplay: UITableViewCell(), forRowAt: IndexPath(row: 0, section: 0))

        XCTAssertEqual(presenter.didShowCellIndexPath, IndexPath(row: 0, section: 0))
    }

    private func makeViewController() -> ImagesListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
    }
}

private final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    var viewDidLoadCalled = false
    var didUpdatePhotosCalled = false
    var didShowCellIndexPath: IndexPath?
    var didTapLikeIndexPath: IndexPath?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didUpdatePhotos() {
        didUpdatePhotosCalled = true
    }

    func didShowCell(at indexPath: IndexPath) {
        didShowCellIndexPath = indexPath
    }

    func didTapLike(at indexPath: IndexPath) {
        didTapLikeIndexPath = indexPath
    }
}

private extension UIView {
    func findTableView() -> UITableView? {
        if let tableView = self as? UITableView {
            return tableView
        }

        for subview in subviews {
            if let tableView = subview.findTableView() {
                return tableView
            }
        }

        return nil
    }
}
