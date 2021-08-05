import Combine
import DomainKit
import Foundation
import Utility

final class EditBookViewModel: ViewModel {

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

    private let book: BookBusinessModel
    private let usecase: EditBookUsecase

    private var isFavorite: Bool?
    private var cancellables: Set<AnyCancellable> = []

    init(
        book: BookBusinessModel,
        usecase: EditBookUsecase = Domain.Usecase.Book.EditBook()
    ) {
        self.book = book
        self.usecase = usecase
        self.setInitialValue()
    }
}

// MARK: - internal methods

extension EditBookViewModel {

    func editBook() {
        state = .loading

        usecase.updateBook(
            id: book.id,
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

    func mapBookEntityToBusinessModel(
        entity: BookEntity
    ) -> BookBusinessModel {
        BookBusinessModel(
            id: entity.id,
            name: entity.name,
            image: entity.image,
            price: entity.price,
            purchaseDate: entity.purchaseDate,
            isFavorite: isFavorite ?? false
        )
    }
}

// MARK: - private methods

private extension EditBookViewModel {

    func setInitialValue() {
        bookName = book.name
        bookPrice = book.price?.description ?? String.blank
        bookPurchaseDate = book.purchaseDate ?? String.blank
        bookImage = book.image ?? String.blank
        isFavorite = book.isFavorite
    }

    func isValidate() -> Bool {
        let results = [
            BookTitleValidator.validate(bookName).isValid,
            BookPriceValidator.validate(bookPrice).isValid,
            BookPurchaseDateValidator.validate(bookPurchaseDate).isValid
        ]
        return results.allSatisfy { $0 }
    }
}
