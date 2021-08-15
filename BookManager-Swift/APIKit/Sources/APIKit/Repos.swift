public struct Repos {

    public struct API {

        public struct Account {
            public typealias Signup = Repository<SignupRequest>
            public typealias Login = Repository<LoginRequest>
            public typealias Logout = Repository<LogoutRequest>
        }

        public struct Book {
            public typealias Get = Repository<BookListRequest>
            public typealias Post = Repository<AddBookRequest>
            public typealias Put = Repository<EditBookRequest>
        }
    }

    public struct Local {

        public struct File {
            public typealias GetBook = Repository<GetSomeDataRequest>
            public typealias SetBook = Repository<SetSomeDataRequest>
        }

        public struct Token {
            public typealias Get = Repository<GetAccessTokenRequest>
        }

        public struct Onboarding {
            public typealias GetIsFinished = Repository<GetOnboardingFinishedRequest>
            public typealias SetIsFinished = Repository<SetOnboardingFinishedRequest>
        }
    }
}

public extension Repos {

    struct Result<T: DataStructure>: DataStructure {
        public var status: Int
        public var result: T
    }
}
