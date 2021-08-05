import Combine
import DomainKit
import Foundation
import Utility

final class AddBookViewModel: ViewModel {

    typealias State = LoadingState<BookEntity, APPError>

    @Published var bookImage = String.blank
    @Published var bookName = String.blank
    @Published var bookPrice = String.blank
    @Published var bookPurchaseDate = String.blank
    @Published private(set) var state: State = .standby

    var bookNamelValidationText: String? {
        BookTitleValidator.validate(bookName).errorDescription
    }

    var bookPriceValidationText: String? {
        BookPriceValidator.validate(bookPrice).errorDescription
    }

    var bookPurchaseDateValidationText: String? {
        BookPurchaseDateValidator.validate(bookPurchaseDate).errorDescription
    }

    private(set) lazy var isEnabledButton = Publishers
        .CombineLatest3($bookName, $bookPrice, $bookPurchaseDate)
        .receive(on: DispatchQueue.main)
        .map { _ in self.isValidate() }
        .eraseToAnyPublisher()

    private let usecase: AddBookUsecase

    private var cancellables: Set<AnyCancellable> = []

    init(usecase: AddBookUsecase = Domain.Usecase.Book.AddBook()) {
        self.usecase = usecase
    }
}

// MARK: - internal methods

extension AddBookViewModel {

    func addBook() {
        state = .loading

        usecase.addBook(
            name: bookName,
            image: bookImage,
            price: Int(bookPrice),
            purchaseDate: bookPurchaseDate
        )
        .sink { [weak self] completion in
            switch completion {
                case let .failure(error):
                    Logger.debug(message: error.localizedDescription)
                    self?.state = .failed(.init(error: error))

                case .finished:
                    Logger.debug(message: "finished")
            }
        } receiveValue: { [weak self] state in
            self?.state = .done(state)
        }
        .store(in: &cancellables)
    }
}

// MARK: - private methods

extension AddBookViewModel {

    func isValidate() -> Bool {
        let results = [
            BookTitleValidator.validate(bookName).isValid,
            BookPriceValidator.validate(bookPrice).isValid,
            BookPurchaseDateValidator.validate(bookPurchaseDate).isValid
        ]
        return results.allSatisfy { $0 }
    }
}
