import UIKit

// temporary
import FirebaseKit

final class MyMessageTableViewCell: UITableViewCell {

    @IBOutlet var userMessageTextView: UITextView! {
        didSet {
            userMessageTextView.textContainerInset = .init(
                top: 8,
                left: 4,
                bottom: 4,
                right: 4
            )
            userMessageTextView.sizeToFit()
        }
    }

    @IBOutlet var sendTimeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        addSubview(
            MyMessageBalloonView(
                frame: CGRect(
                    x: UIScreen.main.bounds.width - 25,
                    y: 0,
                    width: 30,
                    height: 30
                )
            )
        )
    }

    func setup(chat: MessageEntity) {
        let sendAt = chat.sendAt?.toConvertString(
            with: .hourToMinitue
        )

        userMessageTextView.text = chat.message
        sendTimeLabel.text = sendAt
    }
}
