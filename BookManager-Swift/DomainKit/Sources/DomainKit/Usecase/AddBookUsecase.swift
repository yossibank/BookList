import APIKit
import Combine

public protocol AddBookUsecase {
    func addBook(
        name: String,
        image: String,
        price: Int?,
        purchaseDate: String
    ) -> AnyPublisher<BookEntity, APIError>
}

extension UsecaseImpl: AddBookUsecase where R == Repos.API.Book.Post, M == BookMapper {

    public func addBook(
        name: String,
        image: String,
        price: Int?,
        purchaseDate: String
    ) -> AnyPublisher<BookEntity, APIError> {
        toPublisher { promise in
            analytics.sendEvent()

            repository.request(
                useTestData: useTestData,
                parameters: .init(
                    name: name,
                    image: image,
                    price: price,
                    purchaseDate: purchaseDate
                ),
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
