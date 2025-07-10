import UIKit

/// Briše fizičku datoteku baze prije nego je otvorena
func deleteDatabaseFileIfExists() {
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let dbURL = urls[0].appendingPathComponent("MBankApp.sqlite")
    
    // Obriši i dodatne SQLite datoteke (WAL i SHM ako postoje)
    let walURL = dbURL.appendingPathExtension("-wal")
    let shmURL = dbURL.appendingPathExtension("-shm")
    
    do {
        if FileManager.default.fileExists(atPath: dbURL.path) {
            try FileManager.default.removeItem(at: dbURL)
            print("✅ Baza obrisana: \(dbURL.lastPathComponent)")
        }
        if FileManager.default.fileExists(atPath: walURL.path) {
            try FileManager.default.removeItem(at: walURL)
            print("🧹 WAL obrisan")
        }
        if FileManager.default.fileExists(atPath: shmURL.path) {
            try FileManager.default.removeItem(at: shmURL)
            print("🧹 SHM obrisan")
        }
    } catch {
        print("❌ Ne mogu obrisati bazu: \(error)")
    }
}


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        // ⛔️ Reset baze PRIJE nego se učita išta drugo
//        deleteDatabaseFileIfExists()

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        // 👇 Pokreće SplashViewController
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }
}

