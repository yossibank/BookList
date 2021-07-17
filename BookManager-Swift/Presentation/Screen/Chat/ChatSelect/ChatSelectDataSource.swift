import UIKit

// temporary
import FirebaseKit

final class ChatSelectDataSource: NSObject {
    var roomList: [RoomEntity] = []
}

extension ChatSelectDataSource: UITableViewDataSource {

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        roomList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ChatSelectTableViewCell.resourceName,
            for: indexPath
        )

        if let chatSelectCell = cell as? ChatSelectTableViewCell {
            if let room = roomList.any(at: indexPath.row) {
                chatSelectCell.setup(room: room)
            }
        }

        return cell
    }
}
