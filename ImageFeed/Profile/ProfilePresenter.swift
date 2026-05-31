import Foundation

protocol ProfileViewControllerProtocol: AnyObject {
    func updateProfileDetails(profile: Profile)
    func updateAvatar(url: String?)
    func switchToSplashViewController()
}

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateAvatar()
    func didTapLogoutButton()
}

protocol ProfileServiceProtocol {
    var profile: Profile? { get }
}

protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
}

protocol ProfileLogoutServiceProtocol {
    func logout()
}

extension ProfileService: ProfileServiceProtocol {}
extension ProfileImageService: ProfileImageServiceProtocol {}
extension ProfileLogoutService: ProfileLogoutServiceProtocol {}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?

    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let profileLogoutService: ProfileLogoutServiceProtocol

    init(
        profileService: ProfileServiceProtocol = ProfileService.shared,
        profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared,
        profileLogoutService: ProfileLogoutServiceProtocol = ProfileLogoutService.shared
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.profileLogoutService = profileLogoutService
    }

    func viewDidLoad() {
        if let profile = profileService.profile {
            view?.updateProfileDetails(profile: profile)
        }
        didUpdateAvatar()
    }

    func didUpdateAvatar() {
        view?.updateAvatar(url: profileImageService.avatarURL)
    }

    func didTapLogoutButton() {
        profileLogoutService.logout()
        view?.switchToSplashViewController()
    }
}
