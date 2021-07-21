import UIKit
import Combine
import CombineCocoa

// temporary
import FirebaseKit

extension ChatUserListViewController: VCInjectable {
    typealias R = NoRouting
    typealias VM = ChatUserListViewModel
}

// MARK: - properties

final class ChatUserListViewController: UIViewController {
    var routing: R!
    var viewModel: VM!

    private let tableView: UITableView = .init(
        frame: .zero
    )

    private var selectedUser: AccountEntity?
    private var dataSource: ChatUserListDataSource!
    private var cancellables: Set<AnyCancellable> = []
}

// MARK: - override methods

extension ChatUserListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchUsers()
        setupView()
        setupLayout()
        setupNavigationItem()
        setupTableView()
        bindViewModel()
    }
}

// MARK: - private methods

private extension ChatUserListViewController {

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

    func setupNavigationItem() {
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.tapPublisher
            .sink { [weak self] in
                guard
                    let self = self,
                    let partnerUser = self.selectedUser
                else {
                    return
                }

                self.viewModel.createRoom(partnerUser: partnerUser)
                self.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }

    func setupTableView() {
        dataSource = ChatUserListDataSource(viewModel: viewModel)
        tableView.dataSource = dataSource

        tableView.register(
            ChatUserListTableViewCell.self,
            forCellReuseIdentifier: ChatUserListTableViewCell.resourceName
        )
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.rowHeight = 80
    }

    func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                    case .standby:
                        print("standby")

                    case .loading:
                        print("loading")

                    case .finished:
                        print("finished")

                    case .done:
                        self?.tableView.reloadData()

                    case let .failed(error):
                        self?.showError(error: error)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Delegate

extension ChatUserListViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        navigationItem.rightBarButtonItem?.isEnabled = true

        if let user = viewModel.userList.any(at: indexPath.row) {
            selectedUser = user
        }
    }

    func tableView(
        _ tableView: UITableView,
        didDeselectRowAt indexPath: IndexPath
    ) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
}

// MARK: - Protocol

extension ChatUserListViewController: NavigationBarConfiguration {

    var navigationTitle: String? {
        Resources.Strings.General.selectUser
    }

    var rightBarButton: [NavigationBarButton] {
        [.startTalk]
    }
}
