import UIKit

typealias VoidBlock = () -> Void

protocol VCInjectable: UIViewController {
    associatedtype R: Routing
    associatedtype VM: ViewModel

    var routing: R! { get set }
    var viewModel: VM! { get set }

    func inject(
        routing: R,
        viewModel: VM
    )
}

extension VCInjectable {

    func inject(
        routing: R,
        viewModel: VM
    ) {
        self.routing = routing
        self.viewModel = viewModel
    }
}

extension VCInjectable where R == NoRouting {

    func inject(viewModel: VM) {
        routing = R()
        self.viewModel = viewModel
    }
}

extension VCInjectable where VM == NoViewModel {

    func inject(routing: R) {
        self.routing = routing
        viewModel = VM()
    }
}

extension VCInjectable where R == NoRouting, VM == NoViewModel {

    func inject() {
        routing = R()
        viewModel = VM()
    }
}
