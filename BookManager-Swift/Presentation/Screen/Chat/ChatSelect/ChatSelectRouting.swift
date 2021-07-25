import FirebaseKit
import UIKit

final class ChatSelectRouting: Routing {
    weak var viewController: UIViewController?
}

extension ChatSelectRouting {

    func showChatUserListScreen() {
        let chatUserListVC = Resources.ViewControllers.App.chatUserList()
        let navVC = RootNavigationController(rootViewController: chatUserListVC)
        navVC.setupNavigationBar(
            forVC: chatUserListVC,
            config: chatUserListVC as NavigationBarConfiguration
        )

        viewController?.present(navVC, animated: true)
    }

    func showChatRoomScreen(roomId: String, user: AccountEntity) {
        let chatRoomVC = Resources.ViewControllers.App.chatRoom(roomId: roomId, user: user)
        let navVC = viewController?.navigationController as? RootNavigationController

        navVC?.setupNavigationBar(
            forVC: chatRoomVC,
            config: chatRoomVC as NavigationBarConfiguration
        )

        navVC?.pushViewController(chatRoomVC, animated: true)
    }
}
