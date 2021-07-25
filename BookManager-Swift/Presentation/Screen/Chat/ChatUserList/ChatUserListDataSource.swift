import Foundation
import UIKit

final class ChatUserListDataSource: NSObject {

    private weak var viewModel: ChatUserListViewModel!

    init(viewModel: ChatUserListViewModel) {
        super.init()
        self.viewModel = viewModel
    }
}

// MARK: - Delegate

extension ChatUserListDataSource: UITableViewDataSource {

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        viewModel.userList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ChatUserListTableViewCell.resourceName,
            for: indexPath
        )

        if
            let chatUserListCell = cell as? ChatUserListTableViewCell,
            let user = viewModel.userList.any(at: indexPath.row)
        {
            chatUserListCell.selectionStyle = .none
            chatUserListCell.setup(user: user)
        }

        return cell
    }
}
