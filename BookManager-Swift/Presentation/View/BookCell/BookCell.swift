import Combine
import CombineCocoa
import UIKit

enum DisplayType {
    case bookList
    case wishList
}

// MARK: - properties

final class BookCell: UITableViewCell {
    var favoriteHandler: VoidBlock?

    private let mainStackView: UIStackView = .init(
        style: .horizontalStyle,
        spacing: 32
    )

    private let bookImageView: UIImageView = .init(
        style: .bookListImageStyle
    )

    private let bookInfoStackView: UIStackView = .init(
        style: .verticalStyle,
        spacing: 0
    )

    private let bookTitleLabel: UILabel = .init(
        text: String.blank,
        style: .largeFontBoldStyle
    )

    private let bookPriceLabel: UILabel = .init(
        text: String.blank,
        style: .fontNormalStyle
    )

    private let bookPurchaseLabel: UILabel = .init(
        text: String.blank,
        style: .fontNormalStyle
    )

    private let favoriteButton: UIButton = .init(
        image: Resources.Images.App.favorite
    )

    private var isBookFavorite: Bool = false {
        didSet {
            let image = isBookFavorite
                ? Resources.Images.App.favorite
                : Resources.Images.App.nonFavorite

            favoriteButton.setImage(image, for: .normal)
        }
    }

    private var cancellables: Set<AnyCancellable> = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupLayout()
        setupEvent()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupLayout()
        setupEvent()
    }
}

// MARK: - internal methods

extension BookCell {

    func setup(book: BookBusinessModel, type: DisplayType) {
        switch type {
            case .bookList:
                favoriteButton.isHidden = false
                accessoryType = .none

            case .wishList:
                favoriteButton.isHidden = true
                accessoryType = .disclosureIndicator
        }

        isBookFavorite = book.isFavorite
        bookTitleLabel.text = book.name
        bookPriceLabel.text = String.toTaxText(book.price)
        bookPurchaseLabel.text = Date.convertBookPurchaseDate(dateString: book.purchaseDate)
        bookImageView.loadImage(with: .string(urlString: book.image))
    }
}

// MARK: - private methods

private extension BookCell {

    func setupView() {
        backgroundColor = .white

        let bookStackViewList = [
            bookTitleLabel,
            bookPriceLabel,
            bookPurchaseLabel
        ]

        bookStackViewList.forEach {
            bookInfoStackView.addArrangedSubview($0)
        }

        let mainStackViewList = [
            bookImageView,
            bookInfoStackView
        ]

        mainStackViewList.forEach {
            mainStackView.addArrangedSubview($0)
        }

        contentView.addSubview(favoriteButton)
        contentView.addSubview(mainStackView)
    }

    func setupLayout() {
        mainStackView.layout {
            $0.centerY == centerYAnchor
            $0.leading.equal(to: leadingAnchor, offsetBy: 16)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -64)
        }

        favoriteButton.layout {
            $0.centerY == centerYAnchor
            $0.trailing.equal(to: trailingAnchor, offsetBy: -16)
            $0.widthConstant == 40
            $0.heightConstant == 40
        }

        bookImageView.layout {
            $0.widthConstant == 120
            $0.heightConstant == 120
        }

        [bookTitleLabel, bookPriceLabel, bookPurchaseLabel].forEach {
            $0.layout {
                $0.heightConstant == 40
            }
        }
    }

    func setupEvent() {
        favoriteButton.tapPublisher
            .sink { [weak self] in
                self?.favoriteHandler?()
            }
            .store(in: &cancellables)
    }
}
