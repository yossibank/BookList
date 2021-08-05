import Combine
import CombineCocoa
import UIKit

extension AccountViewController: VCInjectable {
    typealias R = AccountRouting
    typealias VM = AccountViewModel
}

// MARK: - properties

final class AccountViewController: UIViewController {

    var routing: R! { didSet { routing.viewController = self } }
    var viewModel: VM!

    private let logoutButton: UIButton = .init(
        title: Resources.Strings.Account.logout,
        backgroundColor: .darkGray,
        style: .fontBoldStyle
    )

    private let chatButton: UIButton = .init(
        title: Resources.Strings.Account.startChat,
        backgroundColor: .purple,
        style: .fontBoldStyle
    )

    private let loadingIndicator: UIActivityIndicatorView = .init(
        style: .largeStyle
    )

    private var cancellables: Set<AnyCancellable> = []
}

// MARK: - override methods

extension AccountViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupEvent()
        bindViewModel()
    }
}

// MARK: - private methods

private extension AccountViewController {

    func setupView() {
        view.backgroundColor = .white

        [logoutButton, chatButton, loadingIndicator].forEach {
            view.addSubview($0)
        }
    }

    func setupLayout() {
        logoutButton.layout {
            $0.centerX == view.centerXAnchor
            $0.centerY == view.centerYAnchor
            $0.widthConstant == 250
            $0.heightConstant == 50
        }

        chatButton.layout {
            $0.centerX == view.centerXAnchor
            $0.top.equal(to: logoutButton.bottomAnchor, offsetBy: 20)
            $0.widthConstant == 250
            $0.heightConstant == 50
        }

        loadingIndicator.layout {
            $0.centerX == view.centerXAnchor
            $0.centerY == view.centerYAnchor
        }
    }

    func setupEvent() {
        logoutButton.tapPublisher
            .sink { [weak self] in
                self?.viewModel.logout()
            }
            .store(in: &cancellables)

        chatButton.tapPublisher
            .sink { [weak self] in
                self?.routing.showChatSelectScreen()
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
                        self?.routing.showLoginScreen()

                    case let .failed(error):
                        self?.loadingIndicator.stopAnimating()
                        self?.showError(error: error)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: Protocol

extension AccountViewController: NavigationBarConfiguration {

    var navigationTitle: String? {
        Resources.Strings.Navigation.Title.account
    }
}
