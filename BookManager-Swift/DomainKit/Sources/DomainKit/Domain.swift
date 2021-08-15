import APIKit

public struct EmptyRepository {}

public struct Domain {

    public struct Usecase {

        public struct Account {

            public static func Signup(
                useTestData: Bool = false
            ) -> UsecaseImpl<Repos.API.Account.Signup, UserMapper> {
                .init(
                    repository: Repos.API.Account.Signup(),
                    mapper: UserMapper(),
                    useTestData: useTestData
                )
            }

            public static func Login(
                useTestData: Bool = false
            ) -> UsecaseImpl<Repos.API.Account.Login, UserMapper> {
                .init(
                    repository: Repos.API.Account.Login(),
                    mapper: UserMapper(),
                    useTestData: useTestData
                )
            }

            public static func Logout(
                useTestData: Bool = false
            ) -> UsecaseImpl<Repos.API.Account.Logout, NoMapper> {
                .init(
                    repository: Repos.API.Account.Logout(),
                    mapper: NoMapper(),
                    useTestData: useTestData
                )
            }
        }

        public struct Book {

            public static func FetchBookList(
                useTestData: Bool = false
            ) -> UsecaseImpl<Repos.API.Book.Get, BookListMapper> {
                .init(
                    repository: Repos.API.Book.Get(),
                    mapper: BookListMapper(),
                    useTestData: useTestData
                )
            }

            public static func AddBook(
                useTestData: Bool = false
            ) -> UsecaseImpl<Repos.API.Book.Post, BookMapper> {
                .init(
                    repository: Repos.API.Book.Post(),
                    mapper: BookMapper(),
                    useTestData: useTestData
                )
            }

            public static func EditBook(
                useTestData: Bool = false
            ) -> UsecaseImpl<Repos.API.Book.Put, BookMapper> {
                .init(
                    repository: Repos.API.Book.Put(),
                    mapper: BookMapper(),
                    useTestData: useTestData
                )
            }
        }
    }

    public struct Local {

        public struct Token {

            public static func hasAccessToken() -> Bool {
                let token = Repos.Local.Token.Get().request()
                return token != nil
            }
        }
    }
}
