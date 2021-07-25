import Combine
import DomainKit
import Utility

final class BookListViewModel: ViewModel {

    typealias State = LoadingState<[BookEntity], APPError>

    var bookList: [BookBusinessModel] {
        mapBookEntityToBusinessModel(entity: bookListEntity)
    }

    @Published private(set) var state: State = .standby

    private let usecase: BookListUsecase

    private var pageRequest: Int = 1
    private var bookListEntity: [BookEntity] = []
    private var cancellables: Set<AnyCancellable> = []

    init(usecase: BookListUsecase = Domain.Usecase.Book.FetchBookList()) {
        self.usecase = usecase
    }
}

// MARK: - internal methods

extension BookListViewModel {

    func fetchBookList(isAdditional: Bool) {
        state = .loading

        if !isAdditional {
            bookListEntity = []
            pageRequest = 1
        }

        usecase
            .fetchBookList(pageRequest: pageRequest)
            .sink { [weak self] completion in
                switch completion {
                    case let .failure(error):
                        self?.state = .failed(.init(error: error))

                    case .finished:
                        self?.pageRequest += 1
                }
            } receiveValue: { [weak self] state in
                guard let self = self else { return }
                self.bookListEntity.append(contentsOf: state)
                self.state = .done(state)
            }
            .store(in: &cancellables)
    }

    func saveFavoriteBook(book: BookBusinessModel) {
        BookFileManager.setData(
            path: String(book.id),
            data: book.json
        )
    }

    func removeFavoriteBook(book: BookBusinessModel) {
        BookFileManager.removeData(
            path: String(book.id)
        )
    }

    func isFavoriteBook(id: Int) -> Bool {
        BookFileManager.isContainPath(path: String(id))
    }
}

// MARK: - private methods

private extension BookListViewModel {

    func mapBookEntityToBusinessModel(entity: [BookEntity]) -> [BookBusinessModel] {
        let bookList = entity.map { book in
            BookBusinessModel(
                id: book.id,
                name: book.name,
                image: book.image,
                price: book.price,
                purchaseDate: book.purchaseDate,
                isFavorite: isFavoriteBook(id: book.id)
            )
        }

        return bookList
    }
}
