import UIKit

final class ChatSelectDataSource: NSObject {

    weak var viewModel: ChatSelectViewModel!

    init(viewModel: ChatSelectViewModel) {
        super.init()
        self.viewModel = viewModel
    }
}

extension ChatSelectDataSource: UITableViewDataSource {

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        viewModel.roomList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ChatSelectTableViewCell.resourceName,
            for: indexPath
        )

        if let chatSelectCell = cell as? ChatSelectTableViewCell {
            if let room = viewModel.roomList.any(at: indexPath.row) {
                chatSelectCell.setup(room: room)
            }
        }

        return cell
    }
}
