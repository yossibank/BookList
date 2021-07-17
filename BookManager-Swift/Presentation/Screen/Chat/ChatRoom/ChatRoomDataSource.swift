import UIKit

// temporary
import FirebaseKit

final class ChatRoomDataSource: NSObject {
    var chatMessages: [MessageEntity] = []
    weak var viewModel: ChatRoomViewModel?

    init(viewModel: ChatRoomViewModel) {
        self.viewModel = viewModel
        super.init()
    }
}

extension ChatRoomDataSource: UITableViewDataSource {

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        chatMessages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chatMessage = chatMessages[indexPath.row]

        let myMessageCell = tableView.dequeueReusableCell(
            withIdentifier: MyMessageTableViewCell.resourceName,
            for: indexPath
        )

        let otherMessageCell = tableView.dequeueReusableCell(
            withIdentifier: OtherMessageTableViewCell.resourceName,
            for: indexPath
        )

        if chatMessage.id == viewModel?.currentUserId {
            if let cell = myMessageCell as? MyMessageTableViewCell {
                cell.transform = .init(scaleX: 1, y: -1)
                cell.setup(chat: chatMessage)
                return cell
            }
        } else {
            if let cell = otherMessageCell as? OtherMessageTableViewCell {
                cell.transform = .init(scaleX: 1, y: -1)
                cell.setup(chat: chatMessage)
                return cell
            }
        }

        return UITableViewCell()
    }
}
