@testable import ImageFeed
import XCTest

final class ProfileViewControllerTests: XCTestCase {
    func testViewControllerCallsPresenterViewDidLoad() {
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)

        _ = viewController.view

        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testUpdateProfileDetailsSetsLabels() {
        let viewController = ProfileViewController()
        _ = viewController.view
        let profile = Profile(
            username: "tester",
            name: "Test User",
            loginName: "@tester",
            bio: "Writes tests"
        )

        viewController.updateProfileDetails(profile: profile)

        XCTAssertNotNil(viewController.view.findLabel(withText: "Test User"))
        XCTAssertNotNil(viewController.view.findLabel(withText: "@tester"))
        XCTAssertNotNil(viewController.view.findLabel(withText: "Writes tests"))
    }
}

private final class ProfilePresenterSpy: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    var didUpdateAvatarCalled = false
    var didTapLogoutButtonCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didUpdateAvatar() {
        didUpdateAvatarCalled = true
    }

    func didTapLogoutButton() {
        didTapLogoutButtonCalled = true
    }
}

private extension UIView {
    func findLabel(withText text: String) -> UILabel? {
        if let label = self as? UILabel, label.text == text {
            return label
        }

        for subview in subviews {
            if let label = subview.findLabel(withText: text) {
                return label
            }
        }

        return nil
    }
}
