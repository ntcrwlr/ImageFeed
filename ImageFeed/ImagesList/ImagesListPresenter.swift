import Foundation

protocol ImagesListViewControllerProtocol: AnyObject {
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func reloadRows(at indexPaths: [IndexPath])
    func setLikeButtonEnabled(_ isEnabled: Bool, at indexPath: IndexPath)
    func setIsLiked(_ isLiked: Bool, at indexPath: IndexPath)
}

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get }
    func viewDidLoad()
    func didUpdatePhotos()
    func didShowCell(at indexPath: IndexPath)
    func didTapLike(at indexPath: IndexPath)
}

protocol ImagesListServiceProtocol {
    var photos: [Photo] { get }
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
}

extension ImagesListService: ImagesListServiceProtocol {}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    private(set) var photos: [Photo] = []

    private let imagesListService: ImagesListServiceProtocol

    init(imagesListService: ImagesListServiceProtocol = ImagesListService.shared) {
        self.imagesListService = imagesListService
    }

    func viewDidLoad() {
        photos = imagesListService.photos
        imagesListService.fetchPhotosNextPage()
    }

    func didUpdatePhotos() {
        let oldCount = photos.count
        photos = imagesListService.photos
        view?.updateTableViewAnimated(oldCount: oldCount, newCount: photos.count)
    }

    func didShowCell(at indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }

    func didTapLike(at indexPath: IndexPath) {
        guard indexPath.row < photos.count else { return }

        let photo = photos[indexPath.row]
        let targetLikeState = !photo.isLiked
        view?.setLikeButtonEnabled(false, at: indexPath)

        imagesListService.changeLike(photoId: photo.id, isLike: targetLikeState) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.view?.setLikeButtonEnabled(true, at: indexPath)

                switch result {
                case .success:
                    let updatedPhoto = self.updatedPhoto(from: photo, isLiked: targetLikeState)
                    self.photos[indexPath.row] = updatedPhoto
                    self.view?.setIsLiked(updatedPhoto.isLiked, at: indexPath)

                case .failure(let error):
                    print("[ImagesListPresenter.didTapLike]: like error \(error)")
                }
            }
        }
    }

    private func updatedPhoto(from photo: Photo, isLiked: Bool) -> Photo {
        Photo(
            id: photo.id,
            size: photo.size,
            createdAt: photo.createdAt,
            welcomeDescription: photo.welcomeDescription,
            thumbImageURL: photo.thumbImageURL,
            regularImageURL: photo.regularImageURL,
            largeImageURL: photo.largeImageURL,
            isLiked: isLiked
        )
    }
}
