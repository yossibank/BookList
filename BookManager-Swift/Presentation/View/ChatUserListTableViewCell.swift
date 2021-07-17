import UIKit

// temporary
import FirebaseKit

final class ChatUserListTableViewCell: UITableViewCell {

    private let stackView: UIStackView = .init(
        style: .horizontalStyle,
        spacing: 10
    )

    private let userIconImageView: UIImageView = .init(
        style: .userIconStyle
    )

    private let userNameLabel: UILabel = .init(
        style: .fontBoldStyle
    )

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupLayout()
    }
}

// MARK: - internal methods

extension ChatUserListTableViewCell {

    func setup(user: AccountEntity) {
        userNameLabel.text = user.name
        userIconImageView.loadImage(with: .string(urlString: user.imageUrl))
    }
}

// MARK: - private methods

private extension ChatUserListTableViewCell {

    func setupView() {
        backgroundColor = .white

        [userIconImageView, userNameLabel].forEach {
            stackView.addArrangedSubview($0)
        }

        contentView.addSubview(stackView)
    }

    func setupLayout() {
        stackView.layout {
            $0.centerY == centerYAnchor
            $0.leading == leadingAnchor + 20
        }

        userIconImageView.layout {
            $0.widthConstant == 60
            $0.heightConstant == 60
        }
    }
}
