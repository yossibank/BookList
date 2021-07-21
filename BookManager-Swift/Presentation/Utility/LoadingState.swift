enum LoadingState<T: Equatable, E: Error & Equatable>: Equatable {
    case standby
    case loading
    case failed(E)
    case done(T)
    case finished
}
