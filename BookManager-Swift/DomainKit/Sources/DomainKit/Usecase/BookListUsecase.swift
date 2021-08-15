import APIKit
import Combine

public protocol BookListUsecase {
    func fetchBookList(
        pageRequest: Int
    ) -> AnyPublisher<[BookEntity], APIError>
}

extension UsecaseImpl: BookListUsecase where R == Repos.API.Book.Get, M == BookListMapper {

    public func fetchBookList(
        pageRequest: Int
    ) -> AnyPublisher<[BookEntity], APIError> {
        toPublisher { promise in
            analytics.sendEvent()

            repository.request(
                useTestData: useTestData,
                parameters: .init(limit: 20, page: pageRequest),
                pathComponent: .init()
            ) { result in
                switch result {
                    case let .success(response):
                        let entity = mapper.convert(response: response)
                        promise(.success(entity))

                    case let .failure(error):
                        promise(.failure(error))
                }
            }
        }
    }
}
