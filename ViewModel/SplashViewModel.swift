import Foundation

class SplashViewModel {

    var onSplashFinished: (() -> Void)?

    func start() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.onSplashFinished?()
        }
    }
}
