import UIKit

// temporary
import FirebaseKit

final class ChatSelectTableViewCell: UITableViewCell {

    private let mainStackView: UIStackView = .init(
        style: .horizontalStyle,
        spacing: 20
    )

    private let userInfoStackView: UIStackView = .init(
        style: .verticalStyle
    )

    private let userIconImageView: UIImageView = .init(
        style: .userIconStyle
    )

    private let userNameLabel: UILabel = .init(
        style: .fontBoldStyle
    )

    private let lastMessageLabel: UILabel = .init(
        textColor: .lightGray,
        style: .smallFontBoldStyle
    )

    private let sendTimeLabel: UILabel = .init(
        style: .smallFontNormalStyle
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

extension ChatSelectTableViewCell {

    func setup(room: RoomEntity) {
        let partnerUser = room.users.filter {
            $0.email != FirebaseAuthManager.currentUser?.email
        }.first

        let lastMessageSendAt = room.lastMessageSendAt?.toConvertString(
            with: .hourToMinitue
        )

        guard let user = partnerUser else { return }

        userIconImageView.loadImage(with: .string(urlString: user.imageUrl))
        userNameLabel.text = user.name
        lastMessageLabel.text = room.lastMessage
        sendTimeLabel.text = lastMessageSendAt
    }
}

// MARK: - private methods

private extension ChatSelectTableViewCell {

    func setupView() {
        backgroundColor = .white

        [userNameLabel, lastMessageLabel].forEach {
            userInfoStackView.addArrangedSubview($0)
        }

        [userIconImageView, userInfoStackView].forEach {
            mainStackView.addArrangedSubview($0)
        }

        contentView.addSubview(mainStackView)
        contentView.addSubview(sendTimeLabel)
    }

    func setupLayout() {
        mainStackView.layout {
            $0.centerY == centerYAnchor
            $0.leading == leadingAnchor + 20
        }

        userIconImageView.layout {
            $0.widthConstant == 60
            $0.heightConstant == 60
        }

        sendTimeLabel.layout {
            $0.top == topAnchor + 10
            $0.trailing == trailingAnchor - 10
        }
    }
}
