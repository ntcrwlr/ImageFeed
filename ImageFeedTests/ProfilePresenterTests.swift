@testable import ImageFeed
import XCTest

final class ProfilePresenterTests: XCTestCase {
    func testViewDidLoadUpdatesProfileAndAvatar() {
        let profile = Profile(
            username: "tester",
            name: "Test User",
            loginName: "@tester",
            bio: "Writes tests"
        )
        let profileService = ProfileServiceStub(profile: profile)
        let imageService = ProfileImageServiceStub(avatarURL: "https://example.com/avatar.jpg")
        let logoutService = ProfileLogoutServiceSpy()
        let view = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(
            profileService: profileService,
            profileImageService: imageService,
            profileLogoutService: logoutService
        )
        presenter.view = view

        presenter.viewDidLoad()

        XCTAssertEqual(view.updatedProfile?.username, "tester")
        XCTAssertEqual(view.updatedAvatarURL, "https://example.com/avatar.jpg")
    }

    func testDidTapLogoutButtonLogsOutAndSwitchesToSplash() {
        let logoutService = ProfileLogoutServiceSpy()
        let view = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(
            profileService: ProfileServiceStub(profile: nil),
            profileImageService: ProfileImageServiceStub(avatarURL: nil),
            profileLogoutService: logoutService
        )
        presenter.view = view

        presenter.didTapLogoutButton()

        XCTAssertTrue(logoutService.logoutCalled)
        XCTAssertTrue(view.switchToSplashViewControllerCalled)
    }
}

private struct ProfileServiceStub: ProfileServiceProtocol {
    let profile: Profile?
}

private struct ProfileImageServiceStub: ProfileImageServiceProtocol {
    let avatarURL: String?
}

private final class ProfileLogoutServiceSpy: ProfileLogoutServiceProtocol {
    var logoutCalled = false

    func logout() {
        logoutCalled = true
    }
}

private final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var updatedProfile: Profile?
    var updatedAvatarURL: String?
    var switchToSplashViewControllerCalled = false

    func updateProfileDetails(profile: Profile) {
        updatedProfile = profile
    }

    func updateAvatar(url: String?) {
        updatedAvatarURL = url
    }

    func switchToSplashViewController() {
        switchToSplashViewControllerCalled = true
    }
}
