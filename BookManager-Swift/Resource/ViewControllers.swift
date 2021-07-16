import UIKit

extension Resources {

    static var ViewControllers: ViewController {
        ViewController()
    }

    struct ViewController {

        var App: AppControllers {
            AppControllers()
        }

        struct AppControllers {

            func signup() -> SignupViewController {
                let vc = SignupViewController()
                vc.inject(routing: SignupRouting(), viewModel: SignupViewModel())
                return vc
            }

            func login() -> LoginViewController {
                let vc = LoginViewController()
                vc.inject(routing: LoginRouting(), viewModel: LoginViewModel())
                return vc
            }

            func account() -> AccountViewController {
                let vc = AccountViewController()
                vc.inject(routing: AccountRouting(), viewModel: AccountViewModel())
                return vc
            }

            func bookList() -> BookListViewController {
                let vc = BookListViewController()
                vc.inject(routing: BookListRouting(), viewModel: BookListViewModel())
                return vc
            }

            func addBook(successHandler: VoidBlock?) -> AddBookViewController {
                let vc = AddBookViewController.createInstance(successHandler: successHandler)
                vc.inject(routing: NoRouting(), viewModel: AddBookViewModel())
                return vc
            }

            func editBook(
                book: BookBusinessModel,
                successHandler: ((BookBusinessModel) -> Void)?
            ) -> EditBookViewController {
                let vc = EditBookViewController.createInstance(successHandler: successHandler)
                vc.inject(routing: NoRouting(), viewModel: EditBookViewModel(book: book))
                return vc
            }

            func wishList() -> WishListViewController {
                let vc = WishListViewController()
                vc.inject(routing: WishListRouting(), viewModel: WishListViewModel())
                return vc
            }

            func chatSelect() -> ChatSelectViewController {
                let vc = ChatSelectViewController()
                vc.inject(routing: ChatSelectRouting(), viewModel: ChatSelectViewModel())
                return vc
            }

            func chatUserList() -> ChatUserListViewController {
                let vc = ChatUserListViewController()
                vc.inject(routing: NoRouting(), viewModel: ChatUserListViewModel())
                return vc
            }

            func chatRoom(roomId: String, user: User) -> ChatRoomViewController {
                let vc = ChatRoomViewController()
                vc.inject(
                    routing: NoRouting(),
                    viewModel: ChatRoomViewModel(roomId: roomId, user: user)
                )
                return vc
            }
        }
    }
}
