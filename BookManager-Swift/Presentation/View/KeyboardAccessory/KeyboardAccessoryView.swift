import Combine
import UIKit

protocol KeyboardAccessoryViewDelegate: AnyObject {
    func didTappedSendButton(message: String)
}

final class KeyboardAccessoryView: UIView {

    @IBOutlet var sendTextView: UITextView! {
        didSet {
            sendTextView.text = .blank
            sendTextView.textContainerInset = .init(top: 8, left: 8, bottom: 4, right: 4)
            sendTextView.backgroundColor = Resources.Colors.sendTextColor
            sendTextView.layer.cornerRadius = 15.0
            sendTextView.layer.borderWidth = 1.0
            sendTextView.layer.borderColor = Resources.Colors.sendTextColor.cgColor
            sendTextView.sizeToFit()
            sendTextView.delegate = self
        }
    }

    @IBOutlet var sendButton: UIButton! {
        didSet {
            sendButton.isEnabled = false
            sendButton.imageView?.contentMode = .scaleAspectFill
            sendButton.contentVerticalAlignment = .fill
            sendButton.contentHorizontalAlignment = .fill
            sendButton.tapPublisher.sink { [weak self] in
                guard
                    let self = self,
                    let message = self.sendTextView.text
                else {
                    return
                }

                self.delegate?.didTappedSendButton(message: message)
            }
            .store(in: &cancellables)
        }
    }

    weak var delegate: KeyboardAccessoryViewDelegate?

    private var cancellables: Set<AnyCancellable> = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeLayout()
    }

    override var intrinsicContentSize: CGSize {
        .zero
    }

    private func initializeLayout() {
        guard
            let view = KeyboardAccessoryView.initialize(ownerOrNil: self)
        else {
            return
        }

        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)

        autoresizingMask = .flexibleHeight
    }

    func didSendText() {
        sendTextView.text = .blank
        sendButton.isEnabled = false
    }
}

extension KeyboardAccessoryView: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        sendButton.isEnabled = !textView.text.isEmpty
    }
}
