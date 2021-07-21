import Combine
import CombineCocoa
import UIKit
import Utility

extension BookListViewController: VCInjectable {
    typealias R = BookListRouting
    typealias VM = BookListViewModel
}

// MARK: - properties

final class BookListViewController: UIViewController {
    var routing: R! { didSet { routing.viewController = self } }
    var viewModel: VM!

    private let tableView: UITableView = .init(
        frame: .zero
    )

    private let loadingIndicator: UIActivityIndicatorView = .init(
        style: .largeStyle
    )

    private var dataSource: BookListDataSource!
    private var cancellables: Set<AnyCancellable> = []
}

// MARK: - override methods

extension BookListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchBookList(isAdditional: false)
        setupView()
        setupLayout()
        setupTableView()
        setupButton()
        bindViewModel()
    }
}

// MARK: - internal methods

extension BookListViewController {

    func reload() {
        viewModel.fetchBookList(isAdditional: false)
        tableView.reloadData()
    }
}


// MARK: private methods

private extension BookListViewController {

    func setupView() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
    }

    func setupLayout() {
        tableView.layout {
            $0.top == view.topAnchor
            $0.bottom == view.bottomAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
        }

        loadingIndicator.layout {
            $0.centerX == view.centerXAnchor
            $0.centerY == view.centerYAnchor
        }
    }

    func setupTableView() {
        dataSource = BookListDataSource(viewModel: viewModel)
        dataSource.delegate = self
        tableView.delegate = self

        tableView.register(
            BookCell.self,
            forCellReuseIdentifier: BookCell.resourceName
        )
        tableView.tableFooterView = UIView()
        tableView.dataSource = dataSource
        tableView.rowHeight = 150
    }

    func setupButton() {
        navigationItem.rightBarButtonItem?.tapPublisher
            .sink { [weak self] in

                var successHandler: VoidBlock? {{ [weak self] in
                    self?.viewModel.fetchBookList(isAdditional: false)
                    self?.tableView.reloadData()
                }}

                self?.routing.showAddBookScreen(
                    successHandler: successHandler
                )
            }
            .store(in: &cancellables)
    }

    func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                    case .standby:
                        self?.loadingIndicator.stopAnimating()

                    case .loading:
                        self?.loadingIndicator.startAnimating()

                    case .finished:
                        self?.loadingIndicator.stopAnimating()

                    case .done:
                        self?.loadingIndicator.stopAnimating()
                        self?.tableView.reloadData()

                    case let .failed(error):
                        self?.loadingIndicator.stopAnimating()
                        self?.showError(error: error)
                }
            }
            .store(in: &cancellables)
    }

    func updateWishList() {
        let wishListVC = getRootTabBarController()?.getViewController(
            tag: .wishList
        ) as? WishListViewController

        wishListVC?.reload()
    }
}

// MARK: - Delegate

extension BookListViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard
            let book = viewModel.bookList.any(at: indexPath.row)
        else {
            return
        }

        var successHandler: (BookBusinessModel) -> Void {{ [weak self] book in
            guard let self = self else { return }

            if self.viewModel.isFavoriteBook(id: book.id) {
                self.viewModel.saveFavoriteBook(book: book)
                self.updateWishList()
            }
            self.viewModel.fetchBookList(isAdditional: false)
            self.tableView.reloadData()
        }}

        routing.showEditBookScreen(
            book: book,
            successHandler: successHandler
        )
    }

    func tableView(
        _ tableView: UITableView,
        willDisplay _: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        let lastSection = tableView.numberOfSections - 1
        let lastIndex = tableView.numberOfRows(inSection: lastSection) - 1

        guard tableView.contentOffset.y > 500 else { return }

        if indexPath.section == lastSection && indexPath.row == lastIndex {
            viewModel.fetchBookList(isAdditional: true)
        }
    }
}

extension BookListViewController: BookListDataSourceDelegate {

    func tappedFavoriteButton() {
        updateWishList()
    }
}

// MARK: - Protocol

extension BookListViewController: NavigationBarConfiguration {

    var navigationTitle: String? {
        Resources.Strings.Navigation.Title.bookList
    }

    var rightBarButton: [NavigationBarButton] {
        [.addBook]
    }
}
