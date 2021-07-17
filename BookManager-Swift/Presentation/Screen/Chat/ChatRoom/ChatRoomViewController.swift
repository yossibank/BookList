import Combine
import CombineCocoa
import UIKit

extension ChatRoomViewController: VCInjectable {
    typealias R = NoRouting
    typealias VM = ChatRoomViewModel
}

// MARK: - properties

final class ChatRoomViewController: UIViewController {

    private struct Constants {
        static let accessoryHeight: CGFloat = 100
        static let contentInset: UIEdgeInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
    }

    var routing: R!
    var viewModel: VM!

    private let tableView: UITableView = .init(
        frame: .zero
    )

    private var dataSource: ChatRoomDataSource!
    private var cancellables: Set<AnyCancellable> = []

    private lazy var keyboardAccessoryView: KeyboardAccessoryView = {
        let view = KeyboardAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: Constants.accessoryHeight)
        view.delegate = self
        return view
    }()

    deinit {
        viewModel.removeListener()
    }
}

// MARK: - override methods

extension ChatRoomViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupTableView()
        setupNotification()
        fetchChatMessages()
    }

    override var inputAccessoryView: UIView? {
        keyboardAccessoryView
    }

    override var canBecomeFirstResponder: Bool {
        true
    }
}

// MARK: - private methods

private extension ChatRoomViewController {

    func setupView() {
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
        dataSource = ChatRoomDataSource(viewModel: viewModel)
        tableView.dataSource = dataSource

        tableView.register(
            MyMessageTableViewCell.xib(),
            forCellReuseIdentifier: MyMessageTableViewCell.resourceName
        )
        tableView.register(
            OtherMessageTableViewCell.xib(),
            forCellReuseIdentifier: OtherMessageTableViewCell.resourceName
        )
        tableView.backgroundColor = Resources.Colors.lineBackground
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.transform = .init(scaleX: 1, y: -1)
        tableView.keyboardDismissMode = .onDrag
    }

    func setupNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    func fetchChatMessages() {
        viewModel.fetchChatMessages { [weak self] documentChange, chatMessage in
            guard let self = self else { return }

            switch documentChange.type {

                case .added:
                    self.dataSource.chatMessages.insert(chatMessage, at: 0)
                    self.dataSource.chatMessages
                        .sort { $0.sendAt ?? Date() > $1.sendAt ?? Date() }

                case .modified, .removed: break
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - Objc

private extension ChatRoomViewController {

    @objc func keyboardWillShow(notification: NSNotification) {
        if
            let endFrame = (
                notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
            )?.cgRectValue
        {
            guard endFrame.height >= Constants.accessoryHeight else { return }

            let top = endFrame.height
            let contentInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)

            tableView.contentInset = contentInset
            tableView.scrollIndicatorInsets = contentInset
            tableView.contentOffset = .init(x: 0, y: -top)
        }
    }

    @objc func keyboardWillHide() {
        tableView.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
    }
}

// MARK: - Delegate

extension ChatRoomViewController: KeyboardAccessoryViewDelegate {

    func didTappedSendButton(message: String) {
        keyboardAccessoryView.didSendText()
        viewModel.sendChatMessage(message: message)
    }
}

// MARK: - Protocol

extension ChatRoomViewController: NavigationBarConfiguration {

    var navigationTitle: String? {
        Resources.Strings.Navigation.Title.talk
    }
}
