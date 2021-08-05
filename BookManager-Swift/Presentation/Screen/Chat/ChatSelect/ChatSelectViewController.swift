import Combine
import CombineCocoa
import UIKit
import Utility

extension ChatSelectViewController: VCInjectable {
    typealias R = ChatSelectRouting
    typealias VM = ChatSelectViewModel
}

// MARK: - properties

final class ChatSelectViewController: UIViewController {

    var routing: R! { didSet { routing.viewController = self } }
    var viewModel: VM!

    private let tableView: UITableView = .init(
        frame: .zero
    )

    private let loadingIndicator: UIActivityIndicatorView = .init(
        style: .largeStyle
    )

    private var dataSource: ChatSelectDataSource!
    private var cancellables: Set<AnyCancellable> = []
}

// MARK: - override methods

extension ChatSelectViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupTableView()
        setupEvent()
        bindViewModel()
    }
}

// MARK: - private methods

private extension ChatSelectViewController {

    func setupView() {
        view.backgroundColor = .white
        view.addSubview(tableView)
    }

    func setupLayout() {
        tableView.layout {
            $0.top == view.topAnchor
            $0.bottom == view.bottomAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
        }
    }

    func setupTableView() {
        dataSource = ChatSelectDataSource(viewModel: viewModel)
        tableView.dataSource = dataSource

        tableView.register(
            ChatSelectTableViewCell.self,
            forCellReuseIdentifier: ChatSelectTableViewCell.resourceName
        )
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.rowHeight = 80
    }

    func setupEvent() {
        navigationItem.rightBarButtonItem?.tapPublisher
            .sink { [weak self] in
                self?.routing.showChatUserListScreen()
            }
            .store(in: &cancellables)
    }

    func bindViewModel() {
        viewModel.fetchRooms()
        viewModel.findCurrentUser()

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
}

// MARK: - Delegate

extension ChatSelectViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let room = viewModel.roomList.any(at: indexPath.row) {
            let roomId = room.users.last?.id ?? String.blank

            if let user = viewModel.user {
                self.routing.showChatRoomScreen(roomId: roomId, user: user)
            }
        }
    }
}

// MARK: - Protocol

extension ChatSelectViewController: NavigationBarConfiguration {

    var navigationTitle: String? {
        Resources.Strings.Navigation.Title.talkList
    }

    var rightBarButton: [NavigationBarButton] {
        [.addUser]
    }
}
