import UIKit

class SplashViewController: UIViewController {

    private let viewModel = SplashViewModel()

    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "SplashIcon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 24
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.27, green: 0.58, blue: 1.0, alpha: 1.0)
        setupLayout()
        bindViewModel()
    }

    private func setupLayout() {
        view.addSubview(logoImageView)
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }

    private func bindViewModel() {
        viewModel.onSplashFinished = { [weak self] in
            self?.goToHome()
        }
        viewModel.start()
    }

    private func goToHome() {
        let welcomeVC = WelcomeViewController()
        let navVC = UINavigationController(rootViewController: welcomeVC)

        if let windowScene = view.window?.windowScene,
           let window = windowScene.windows.first {
            window.rootViewController = navVC
            UIView.transition(with: window,
                              duration: 0.4,
                              options: .transitionCrossDissolve,
                              animations: nil)
        }
    }
}
