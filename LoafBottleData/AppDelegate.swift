import UIKit
import CoreData

extension UIApplicationDelegate {
    typealias LaunchOptions = [UIApplication.LaunchOptionsKey : Any]
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private var persistentContainer: NSPersistentContainer!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions options: LaunchOptions?) -> Bool {

        NSPersistentContainer.withLBSContainer { (container) in
            self.persistentContainer = container
            let rootCoordinator = RootCoordinator.fromStoryBoard(managedObjectContent: container.viewContext)
            self.window?.rootViewController = rootCoordinator
            self.window?.makeKeyAndVisible()
        }

        return true
    }
}
