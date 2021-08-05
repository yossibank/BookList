import Combine
import CombineCocoa
import UIKit
import Utility

extension SignupViewController: VCInjectable {
    typealias R = SignupRouting
    typealias VM = SignupViewModel
}

// MARK: - properties

final class SignupViewController: UIViewController {

    var routing: R! { didSet { routing.viewController = self } }
    var viewModel: VM!
    var keyboardNotifier: KeyboardNotifier = .init()

    private let mainStackView: UIStackView = .init(
        style: .verticalStyle,
        spacing: 32
    )

    private let userIconImageView: UIImageView = .init(
        style: .iconStyle
    )

    private let userIconSelectButton: UIButton = .init(
        title: Resources.Strings.Account.selectIconImage,
        backgroundColor: .black,
        style: .fontBoldStyle
    )

    private let userNameStackView: UIStackView = .init(
        style: .verticalStyle,
        spacing: 4
    )

    private let userNameTextField: UITextField = .init(
        placeholder: Resources.Strings.Account.nickName,
        keyboardType: .default,
        style: .borderBottomStyle
    )

    private let userNameValidationLabel: UILabel = .init(
        style: .validationStyle
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

    private let passwordConfirmationStackView: UIStackView = .init(
        style: .verticalStyle,
        spacing: 4
    )

    private let passwordConfirmationTextField: UITextField = .init(
        placeholder: Resources.Strings.General.passwordConfirmation,
        style: .securePassword
    )

    private let passwordConfirmationValidationLabel: UILabel = .init(
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
            signupButton.alpha = isEnabled ? 1.0 : 0.5
            signupButton.isEnabled = isEnabled
        }
    }

    private var isSecureCheck: Bool = false {
        didSet {
            let image = isSecureCheck
                ? Resources.Images.App.check
                : Resources.Images.App.nonCheck

            secureButton.setImage(image, for: .normal)

            [passwordTextField, passwordConfirmationTextField].forEach {
                $0?.isSecureTextEntry = !isSecureCheck
            }
        }
    }
}

// MARK: - override methods

extension SignupViewController {

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

private extension SignupViewController {

    func setupStackView() {
        let userNameStackViewList = [
            userNameTextField,
            userNameValidationLabel
        ]

        userNameStackViewList.forEach {
            userNameStackView.addArrangedSubview($0)
        }

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

        let passwordConfirmationStackViewList = [
            passwordConfirmationTextField,
            passwordConfirmationValidationLabel
        ]

        passwordConfirmationStackViewList.forEach {
            passwordConfirmationStackView.addArrangedSubview($0)
        }

        let secureStackViewList = [
            secureButton,
            secureLabel
        ]

        secureStackViewList.forEach {
            secureStackView.addArrangedSubview($0)
        }

        let buttonStackViewList = [
            signupButton,
            loginButton
        ]

        buttonStackViewList.forEach {
            buttonStackView.addArrangedSubview($0)
        }

        let stackViewList = [
            userNameStackView,
            emailStackView,
            passwordStackView,
            passwordConfirmationStackView,
            secureStackView,
            buttonStackView
        ]

        stackViewList.forEach {
            mainStackView.addArrangedSubview($0)
        }
    }

    func setupView() {
        view.backgroundColor = .white

        let viewList = [
            userIconImageView,
            userIconSelectButton,
            mainStackView,
            loadingIndicator
        ]

        viewList.forEach {
            view.addSubview($0)
        }
    }

    func setupLayout() {
        userIconImageView.layout {
            $0.bottom.equal(to: mainStackView.topAnchor, offsetBy: -10)
            $0.leading.equal(to: mainStackView.leadingAnchor, offsetBy: 20)
            $0.widthConstant == 70
            $0.heightConstant == 70
        }

        userIconSelectButton.layout {
            $0.centerY == userIconImageView.centerYAnchor
            $0.leading.equal(to: userIconImageView.trailingAnchor, offsetBy: 20)
            $0.widthConstant == 140
            $0.heightConstant == 30
        }

        let stackViews = [
            userNameStackView,
            emailStackView,
            passwordStackView,
            passwordConfirmationStackView
        ]

        stackViews.forEach {
            $0.layout {
                $0.heightConstant == 40
            }
        }

        let textFields = [
            userNameTextField,
            emailTextField,
            passwordTextField,
            passwordConfirmationTextField
        ]

        textFields.forEach {
            $0.layout {
                $0.heightConstant == 25
            }
        }

        secureButton.layout {
            $0.widthConstant == 15
            $0.heightConstant == 15
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
        let textFields = [
            userNameTextField,
            emailTextField,
            passwordTextField,
            passwordConfirmationTextField
        ]

        textFields.forEach { $0.delegate = self }
    }

    func setupEvent() {
        userIconSelectButton.tapPublisher
            .sink { [weak self] in
                let photoLibrary = UIImagePickerController.SourceType.photoLibrary

                if UIImagePickerController.isSourceTypeAvailable(photoLibrary) {
                    let picker = UIImagePickerController()
                    picker.sourceType = .photoLibrary
                    picker.allowsEditing = true
                    picker.delegate = self
                    self?.present(picker, animated: true)
                }
            }
            .store(in: &cancellables)

        secureButton.tapPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                self.isSecureCheck = !self.isSecureCheck
            }
            .store(in: &cancellables)

        loginButton.tapPublisher
            .sink { [weak self] in
                self?.routing.showLoginScreen()
            }
            .store(in: &cancellables)

        signupButton.tapPublisher
            .sink { [weak self] in
                self?.viewModel.signup()
            }
            .store(in: &cancellables)
    }

    func bindValue() {
        userNameTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .removeDuplicates()
            .assign(to: \.userName, on: viewModel)
            .store(in: &cancellables)

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

        passwordConfirmationTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .removeDuplicates()
            .assign(to: \.passwordConfirmation, on: viewModel)
            .store(in: &cancellables)
    }

    func bindViewModel() {
        viewModel.isEnabledButton
            .assign(to: \.isEnabled, on: self)
            .store(in: &cancellables)

        viewModel.$userName
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .dropFirst()
            .map { _ in self.viewModel.userNameValidationText }
            .assign(to: \.text, on: userNameValidationLabel)
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

        viewModel.$passwordConfirmation
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .dropFirst()
            .map { _ in self.viewModel.passwordConfirmationValidationText }
            .assign(to: \.text, on: passwordConfirmationValidationLabel)
            .store(in: &cancellables)

        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }

                switch state {
                    case .standby:
                        self.loadingIndicator.stopAnimating()

                    case .loading:
                        self.loadingIndicator.startAnimating()

                    case .finished:
                        self.loadingIndicator.stopAnimating()

                    case .done:
                        self.loadingIndicator.stopAnimating()

                        let okAction: UIAlertAction = .init(
                            title: Resources.Strings.Alert.ok,
                            style: .default
                        ) { [weak self] _ in
                            self?.routing.showRootScreen()
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.showAlert(
                                title: Resources.Strings.Alert.successSignup,
                                actions: [okAction]
                            )
                        }

                    case let .failed(error):
                        self.loadingIndicator.stopAnimating()
                        self.showError(error: error)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Delegate

extension SignupViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textFields = [
            userNameTextField,
            emailTextField,
            passwordTextField,
            passwordConfirmationTextField
        ]

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

extension SignupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
        _: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let image = info[.editedImage] as? UIImage {
            userIconImageView.image = image
        } else if let originalImage = info[.originalImage] as? UIImage {
            userIconImageView.image = originalImage
        }

        if let data = self.userIconImageView.image?.jpegData(compressionQuality: 0.6) {
            self.viewModel.saveUserIconImage(uploadImage: data)
        }

        routing.dismiss()
    }

    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        routing.dismiss()
    }
}

extension SignupViewController: KeyboardDelegate {

    func keyboardPresent(_ keyboardFrame: CGRect) {
        let displayHeight = view.frame.height - keyboardFrame.height
        let bottomOffsetY = buttonStackView.convert(
            signupButton.frame, to: self.view
        ).maxY + 10 - displayHeight

        view.frame.origin.y == 0 ? (view.frame.origin.y -= bottomOffsetY) : ()
    }

    func keyboardDismiss() {
        view.frame.origin.y != 0 ? (view.frame.origin.y = 0) : ()
    }
}
