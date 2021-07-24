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

    private var dataSource: ChatSelectDataSource!
    private var cancellables: Set<AnyCancellable> = []

    deinit {
        viewModel.removeListener()
    }
}

// MARK: - override methods

extension ChatSelectViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupTableView()
        setupEvent()
        fetchRooms()
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
        dataSource = ChatSelectDataSource()
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

    func fetchRooms() {
        viewModel.fetchRooms { [weak self] documentChange, room in
            guard let self = self else { return }

            switch documentChange.type {

                case .added:
                    self.dataSource.roomList.append(room)

                case .removed:
                    self.dataSource.roomList = self.dataSource.roomList.filter { $0.id != room.id }

                case .modified:
                    self.dataSource.roomList = []
                    self.dataSource.roomList.append(room)
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    func bindViewModel() {
        viewModel.findUser()

        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                    case .standby:
                        Logger.debug(message: "standby")

                    case .loading:
                        Logger.debug(message: "loading")

                    case .finished:
                        Logger.debug(message: "finished")

                    case .done:
                        Logger.debug(message: "done")

                    case let .failed(error):
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

        if let room = dataSource.roomList.any(at: indexPath.row) {
            let roomId = room.users.map { String($0.id) }.joined()

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
