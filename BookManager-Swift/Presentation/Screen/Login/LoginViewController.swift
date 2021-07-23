import Combine
import CombineCocoa
import UIKit
import Utility

extension LoginViewController: VCInjectable {
    typealias R = LoginRouting
    typealias VM = LoginViewModel
}

// MARK: - properties

final class LoginViewController: UIViewController {
    var routing: R! { didSet { routing.viewController = self } }
    var viewModel: VM!
    var keyboardNotifier: KeyboardNotifier = .init()

    private let mainStackView: UIStackView = .init(
        style: .verticalStyle,
        spacing: 32
    )

    private let emailStackView: UIStackView = .init(
        style: .verticalStyle,
        spacing: 4
    )

    private let emailTextField: UITextField = .init(
        placeholder: Resources.Strings.General.mailAddress,
        keyboardType: .emailAddress,
        style: .borderBottomStyle
    )

    private let emailValidationLabel: UILabel = .init(
        style: .validationStyle
    )

    private let passwordStackView: UIStackView = .init(
        style: .verticalStyle,
        spacing: 4
    )

    private let passwordTextField: UITextField = .init(
        placeholder: Resources.Strings.General.password,
        style: .securePassword
    )

    private let passwordValidationLabel: UILabel = .init(
        style: .validationStyle
    )

    private let secureStackView: UIStackView = .init(
        style: .horizontalStyle,
        spacing: 8
    )

    private let secureButton: UIButton = .init(
        image: Resources.Images.App.nonCheck
    )

    private let secureLabel: UILabel = .init(
        text: Resources.Strings.Account.showPassword,
        style:  .fontBoldStyle
    )

    private let buttonStackView: UIStackView = .init(
        style: .verticalStyle,
        spacing: 16
    )

    private let loginButton: UIButton = .init(
        title: Resources.Strings.Account.login,
        backgroundColor: .systemGreen,
        style: .fontBoldStyle
    )

    private let signupButton: UIButton = .init(
        title: Resources.Strings.Account.createAccount,
        backgroundColor: .systemBlue,
        style: .fontBoldStyle
    )

    private let loadingIndicator: UIActivityIndicatorView = .init(
        style: .largeStyle
    )

    private var cancellables: Set<AnyCancellable> = []

    private var isEnabled: Bool = false {
        didSet {
            loginButton.alpha = isEnabled ? 1.0 : 0.5
            loginButton.isEnabled = isEnabled
        }
    }

    private var isSecureCheck: Bool = false {
        didSet {
            let image = isSecureCheck
                ? Resources.Images.App.check
                : Resources.Images.App.nonCheck

            secureButton.setImage(image, for: .normal)

            passwordTextField.isSecureTextEntry = !isSecureCheck
        }
    }
}

// MARK: - override methods

extension LoginViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStackView()
        setupView()
        setupLayout()
        setupTextField()
        setupEvent()
        bindValue()
        bindViewModel()
        listenerKeyboard(keyboardNotifier: keyboardNotifier)
    }

    override func touchesBegan(
        _: Set<UITouch>,
        with _: UIEvent?
    ) {
        view.endEditing(true)
    }
}

// MARK: - private methods

private extension LoginViewController {

    func setupStackView() {
        let emailStackViewList = [
            emailTextField,
            emailValidationLabel
        ]

        emailStackViewList.forEach {
            emailStackView.addArrangedSubview($0)
        }

        let passwordStackViewList = [
            passwordTextField,
            passwordValidationLabel
        ]

        passwordStackViewList.forEach {
            passwordStackView.addArrangedSubview($0)
        }

        let secureStackViewList = [
            secureButton,
            secureLabel
        ]

        secureStackViewList.forEach {
            secureStackView.addArrangedSubview($0)
        }

        let buttonStackViewList = [
            loginButton,
            signupButton
        ]

        buttonStackViewList.forEach {
            buttonStackView.addArrangedSubview($0)
        }

        let stackViewList = [
            emailStackView,
            passwordStackView,
            secureStackView,
            buttonStackView
        ]

        stackViewList.forEach {
            mainStackView.addArrangedSubview($0)
        }
    }

    func setupView() {
        view.backgroundColor = .white
        view.addSubview(mainStackView)
        view.addSubview(loadingIndicator)
    }

    func setupLayout() {
        secureButton.layout {
            $0.widthConstant == 15
            $0.heightConstant == 15
        }

        [emailValidationLabel, passwordValidationLabel].forEach {
            $0.layout {
                $0.heightConstant == 12
            }
        }

        [emailTextField, passwordTextField].forEach {
            $0.layout {
                $0.heightConstant == 30
            }
        }

        [loginButton, signupButton].forEach {
            $0.layout {
                $0.heightConstant == 40
            }
        }

        mainStackView.layout {
            $0.centerY == view.centerYAnchor
            $0.leading.equal(to: view.leadingAnchor, offsetBy: 48)
            $0.trailing.equal(to: view.trailingAnchor, offsetBy: -48)
        }

        loadingIndicator.layout {
            $0.centerX == view.centerXAnchor
            $0.centerY == view.centerYAnchor
        }
    }

    func setupTextField() {
        [emailTextField, passwordTextField].forEach {
            $0?.delegate = self
        }

        emailTextField.text = "kamiyama000@gmail.com"
        passwordTextField.text = "kamiyama"
    }

    func setupEvent() {
        secureButton.tapPublisher
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.isSecureCheck = !self.isSecureCheck
            }
            .store(in: &cancellables)

        signupButton.tapPublisher
            .sink { [weak self] _ in
                self?.routing.showSignupScreen()
            }
            .store(in: &cancellables)

        loginButton.tapPublisher
            .sink { [weak self] _ in
                self?.viewModel.login()
            }
            .store(in: &cancellables)
    }

    func bindValue() {
        emailTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .removeDuplicates()
            .assign(to: \.email, on: viewModel)
            .store(in: &cancellables)

        passwordTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .removeDuplicates()
            .assign(to: \.password, on: viewModel)
            .store(in: &cancellables)
    }

    func bindViewModel() {
        viewModel.isEnabledButton
            .assign(to: \.isEnabled, on: self)
            .store(in: &cancellables)

        viewModel.$email
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .dropFirst()
            .map { _ in self.viewModel.emailValidationText }
            .assign(to: \.text, on: emailValidationLabel)
            .store(in: &cancellables)

        viewModel.$password
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .dropFirst()
            .map { _ in self.viewModel.passwordValidationText }
            .assign(to: \.text, on: passwordValidationLabel)
            .store(in: &cancellables)

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
                        self?.routing.showRootScreen()

                    case let .failed(error):
                        self?.loadingIndicator.stopAnimating()
                        self?.showError(error: error)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Delegate

extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textFields = [emailTextField, passwordTextField]

        guard
            let currentTextFieldIndex = textFields.firstIndex(of: textField)
        else {
            return false
        }

        if currentTextFieldIndex + 1 == textFields.endIndex {
            textField.resignFirstResponder()
        } else {
            textFields[currentTextFieldIndex + 1].becomeFirstResponder()
        }

        return true
    }
}

extension LoginViewController: KeyboardDelegate {

    func keyboardPresent(_ keyboardFrame: CGRect) {
        let displayHeight = view.frame.height - keyboardFrame.height
        let bottomOffsetY = buttonStackView.convert(
            loginButton.frame, to: self.view
        ).maxY + 10 - displayHeight

        view.frame.origin.y == 0 ? (view.frame.origin.y -= bottomOffsetY) : ()
    }

    func keyboardDismiss() {
        view.frame.origin.y != 0 ? (view.frame.origin.y = 0) : ()
    }
}
