import Combine
import CombineCocoa
import UIKit
import Utility

extension EditBookViewController: VCInjectable {
    typealias R = NoRouting
    typealias VM = EditBookViewModel
}

// MARK: - properties

final class EditBookViewController: UIViewController {
    var routing: NoRouting!
    var viewModel: VM!
    var keyboardNotifier: KeyboardNotifier = .init()

    private let mainStackView: UIStackView = .init(
        style: .verticalStyle,
        spacing: 32
    )

    private let bookImageView: UIImageView = .init(
        style: .bookImageStyle
    )

    private let buttonStackView: UIStackView = .init(
        style: .verticalStyle,
        spacing: 16
    )

    private let bookImageSelectButton: UIButton = .init(
        title: Resources.Strings.Book.selectImage,
        backgroundColor: .darkGray,
        style: .fontBoldStyle
    )

    private let takingPictureButton: UIButton = .init(
        title: Resources.Strings.Book.takePicture,
        backgroundColor: .darkGray,
        style: .fontBoldStyle
    )

    private let bookTitleStackView: UIStackView = .init(
        style: .verticalStyle,
        spacing: 4
    )

    private let bookTitleTextField: UITextField = .init(
        placeholder: Resources.Strings.Book.bookTitle,
        style: .borderBottomStyle
    )

    private let bookTitleValidationLabel: UILabel = .init(
        style: .validationStyle
    )

    private let bookPriceStackView: UIStackView = .init(
        style: .verticalStyle,
        spacing: 4
    )

    private let bookPriceTextField: UITextField = .init(
        placeholder: Resources.Strings.Book.price,
        style: .borderBottomStyle
    )

    private let bookPriceValidationLabel: UILabel = .init(
        style: .validationStyle
    )

    private let bookPurchaseDateStackView: UIStackView = .init(
        style: .verticalStyle,
        spacing: 4
    )

    private let bookPurchaseDateTextField: UITextField = .init(
        placeholder: Resources.Strings.Book.purchaseDate,
        style: .borderBottomStyle
    )

    private let bookPurchaseDateValidationLabel: UILabel = .init(
        style: .validationStyle
    )

    private let loadingIndicator: UIActivityIndicatorView = .init(
        style: .largeStyle
    )

    private lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar(
            frame: .init(
                x: 0,
                y: 0,
                width: view.frame.width,
                height: 35
            )
        )

        let spaceItem = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: self,
            action: nil
        )

        let doneItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: nil
        )

        doneItem.tapPublisher
            .sink { [weak self] in
                self?.bookPurchaseDateTextField.text = UIDatePicker
                    .purchaseDatePicker.date.toConvertString(
                        with: .yearToDayOfWeekJapanese
                    )
                self?.bookPurchaseDateTextField.endEditing(true)
            }
            .store(in: &cancellables)

        toolbar.setItems(
            [spaceItem, doneItem],
            animated: true
        )

        return toolbar
    }()

    private var isEnabled: Bool = false {
        didSet {
            navigationItem.rightBarButtonItem?.isEnabled = isEnabled
        }
    }

    private var cancellables: Set<AnyCancellable> = []
    private var successHandler: ((BookBusinessModel) -> Void)?

    static func createInstance(
        successHandler: ((BookBusinessModel) -> Void)?
    ) -> EditBookViewController {
        let instance = EditBookViewController()
        instance.successHandler = successHandler
        return instance
    }
}

// MARK: - override methods

extension EditBookViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStackView()
        setupView()
        setupLayout()
        setupTextField()
        setupEvent()
        setupInitialValue()
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

private extension EditBookViewController {

    func setupStackView() {
        let bookTitleStackViewList = [
            bookTitleTextField,
            bookTitleValidationLabel
        ]

        bookTitleStackViewList.forEach {
            bookTitleStackView.addArrangedSubview($0)
        }

        let bookPriceStackViewList = [
            bookPriceTextField,
            bookPriceValidationLabel
        ]

        bookPriceStackViewList.forEach {
            bookPriceStackView.addArrangedSubview($0)
        }

        let bookPurchaseDateStackViewList = [
            bookPurchaseDateTextField,
            bookPurchaseDateValidationLabel
        ]

        bookPurchaseDateStackViewList.forEach {
            bookPurchaseDateStackView.addArrangedSubview($0)
        }

        let buttonStackViewList = [
            bookImageSelectButton,
            takingPictureButton
        ]

        buttonStackViewList.forEach {
            buttonStackView.addArrangedSubview($0)
        }

        let stackViewList = [
            bookImageView,
            buttonStackView,
            bookTitleStackView,
            bookPriceStackView,
            bookPurchaseDateStackView
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
        bookImageView.layout {
            $0.heightConstant == 200
        }

        [bookImageSelectButton, takingPictureButton].forEach {
            $0.layout {
                $0.heightConstant == 30
            }
        }

        [bookTitleTextField, bookPriceTextField, bookPurchaseDateTextField].forEach {
            $0.layout {
                $0.heightConstant == 30
            }
        }

        [bookTitleValidationLabel, bookPriceValidationLabel, bookPurchaseDateValidationLabel].forEach {
            $0.layout {
                $0.heightConstant == 12
            }
        }

        mainStackView.layout {
            $0.centerY == view.centerYAnchor
            $0.leading.equal(to: view.leadingAnchor, offsetBy: 64)
            $0.trailing.equal(to: view.trailingAnchor, offsetBy: -64)
        }

        loadingIndicator.layout {
            $0.centerX == view.centerXAnchor
            $0.centerY == view.centerYAnchor
        }
    }

    func setupTextField() {
        [bookTitleTextField, bookPriceTextField, bookPurchaseDateTextField].forEach {
            $0?.delegate = self
        }

        bookPurchaseDateTextField.inputAccessoryView = toolbar
        bookPurchaseDateTextField.inputView = UIDatePicker.purchaseDatePicker
    }

    func setupEvent() {
        navigationItem.rightBarButtonItem?.tapPublisher
            .sink { [weak self] in
                self?.viewModel.editBook()
            }
            .store(in: &cancellables)

        bookImageSelectButton.tapPublisher
            .sink { [weak self] in
                let photoLibrary = UIImagePickerController.SourceType.photoLibrary

                if UIImagePickerController.isSourceTypeAvailable(photoLibrary) {
                    let picker = UIImagePickerController()
                    picker.sourceType = .photoLibrary
                    picker.delegate = self
                    self?.present(picker, animated: true)
                }
            }
            .store(in: &cancellables)

        takingPictureButton.tapPublisher
            .sink { [weak self] in
                let camera = UIImagePickerController.SourceType.camera

                if UIImagePickerController.isSourceTypeAvailable(camera) {
                    let picker = UIImagePickerController()
                    picker.sourceType = .camera
                    picker.delegate = self
                    self?.present(picker, animated: true)
                }
            }
            .store(in: &cancellables)
    }

    func setupInitialValue() {
        bookImageView.loadImage(with: .string(urlString: viewModel.bookImage))
        bookTitleTextField.text = viewModel.bookName
        bookPriceTextField.text = viewModel.bookPrice
        bookPurchaseDateTextField.text = Date.convertBookPurchaseDate(
            dateString: viewModel.bookPurchaseDate
        )

        // 画像をそのまま編集せずに完了ボタンを押した際にbase64に変換しておく
        viewModel.bookImage = bookImageView.image?.convertBase64String() ?? String.blank
    }

    func bindValue() {
        bookImageView.base64ImagePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.bookImage, on: viewModel)
            .store(in: &cancellables)

        bookTitleTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .assign(to: \.bookName, on: viewModel)
            .store(in: &cancellables)

        bookPriceTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .assign(to: \.bookPrice, on: viewModel)
            .store(in: &cancellables)

        bookPurchaseDateTextField.textDatePickerPublisher
            .receive(on: DispatchQueue.main)
            .compactMap {
                Date.toConvertDate(
                    $0, with: .yearToDayOfWeekJapanese
                )?.toConvertString(with: .yearToDayOfWeek)
            }
            .assign(to: \.bookPurchaseDate, on: viewModel)
            .store(in: &cancellables)
    }

    func bindViewModel() {
        viewModel.isEnabledButton
            .assign(to: \.isEnabled, on: self)
            .store(in: &cancellables)

        viewModel.$bookName
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .dropFirst()
            .map { _ in self.viewModel.bookNamelValidationText }
            .assign(to: \.text, on: bookTitleValidationLabel)
            .store(in: &cancellables)

        viewModel.$bookPrice
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .dropFirst()
            .map { _ in self.viewModel.bookPriceValidationText }
            .assign(to: \.text, on: bookPriceValidationLabel)
            .store(in: &cancellables)

        viewModel.$bookPurchaseDate
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .dropFirst()
            .map { _ in self.viewModel.bookPurchaseDateValidationText }
            .assign(to: \.text, on: bookPurchaseDateValidationLabel)
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

                    case let .done(entity):
                        let book = self.viewModel.mapBookEntityToBusinessModel(entity: entity)

                        self.loadingIndicator.stopAnimating()
                        self.successHandler?(book)

                        let okAction = UIAlertAction(
                            title: Resources.Strings.Alert.ok,
                            style: .default
                        ) { [weak self] _ in
                            self?.dismiss(animated: true)
                        }

                        self.showAlert(
                            title: Resources.Strings.Alert.successBookEdit,
                            actions: [okAction]
                        )

                    case let .failed(error):
                        self.loadingIndicator.stopAnimating()
                        self.showError(error: error)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Delegate

extension EditBookViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textFields = [bookTitleTextField, bookPriceTextField, bookPurchaseDateTextField]

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

extension EditBookViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
        _: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let image = info[.originalImage] as? UIImage {
            bookImageView.image = image

            NotificationCenter.default.post(
                name: .didSetImageIntoImageView,
                object: nil,
                userInfo: ["base64Image": image.convertBase64String()]
            )
        }
        dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        dismiss(animated: true)
    }
}

extension EditBookViewController: KeyboardDelegate {

    func keyboardPresent(_ keyboardFrame: CGRect) {
        let displayHeight = view.frame.height - keyboardFrame.height
        let bottomOffsetY = bookPurchaseDateStackView.convert(
            bookPurchaseDateTextField.frame, to: self.view
        ).maxY + 10 - displayHeight

        view.frame.origin.y == 0 ? (view.frame.origin.y -= bottomOffsetY) : ()
    }

    func keyboardDismiss() {
        view.frame.origin.y != 0 ? (view.frame.origin.y = 0) : ()
    }
}

// MARK: - Protocol

extension EditBookViewController: NavigationBarConfiguration {

    var navigationTitle: String? {
        Resources.Strings.Navigation.Title.bookEdit
    }

    var rightBarButton: [NavigationBarButton] {
        [.done]
    }
}
