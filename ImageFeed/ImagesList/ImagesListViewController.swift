//
//  ViewController.swift
//  ImageFeed
//
//  Created by Сергей Бушков on 05.02.2026.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    
    private var presenter: ImagesListPresenterProtocol?
    private var imagesListServiceObserver: NSObjectProtocol?
    private var photos: [Photo] {
        presenter?.photos ?? []
    }

    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if presenter == nil {
            configure(ImagesListPresenter())
        }
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.presenter?.didUpdatePhotos()
        }
        presenter?.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
                guard
                    let viewController = segue.destination as? SingleImageViewController,
                    let indexPath = sender as? IndexPath
                else {
                    super.prepare(for: segue, sender: sender)
                    return
                }
                guard let photo = presenter?.photos[indexPath.row] else { return }
                viewController.imageURL = URL(string: photo.largeImageURL)
            } else {
                super.prepare(for: segue, sender: sender)
            }
        }
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let today = Date()
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { index in
                    IndexPath(row: index, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
    
    deinit {
        if let observer = imagesListServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        guard indexPath.row < photos.count else {
            return 0
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photos[indexPath.row].size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photos[indexPath.row].size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        presenter?.didShowCell(at: indexPath)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.photos.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }

    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let photo = presenter?.photos[indexPath.row] else { return }
        let placeholderImage = UIImage(named: "Stub")

        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: URL(string: photo.regularImageURL),
            placeholder: placeholderImage
        ) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success:
                if tableView.indexPathsForVisibleRows?.contains(indexPath) == true {
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            case .failure(let error):
                print("[ImagesListViewController.configCell]: Failure - \(error.localizedDescription), row: \(indexPath.row)")
            }
        }
        
        cell.dateLabel.text = photo.createdAt.map {
            dateFormatter.string(from: $0)
        }

        cell.setIsLiked(photo.isLiked)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }

        presenter?.didTapLike(at: indexPath)
    }
}

extension ImagesListViewController: ImagesListViewControllerProtocol {
    func reloadRows(at indexPaths: [IndexPath]) {
        tableView.reloadRows(at: indexPaths, with: .automatic)
    }

    func setLikeButtonEnabled(_ isEnabled: Bool, at indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell else { return }
        cell.setLikeButtonEnabled(isEnabled)
    }

    func setIsLiked(_ isLiked: Bool, at indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell else { return }
        cell.setIsLiked(isLiked)
    }
}
