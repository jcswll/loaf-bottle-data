import UIKit
import CoreData

extension UIApplication {
    typealias LaunchOptions = [LaunchOptionsKey : Any]
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private var persistentContainer: NSPersistentContainer!

    func application(_: UIApplication, didFinishLaunchingWithOptions _: UIApplication.LaunchOptions?) -> Bool {

        NSPersistentContainer.withLBSContainer { (container) in
            self.persistentContainer = container
            let rootCoordinator = RootCoordinator.fromStoryBoard(managedObjectContent: container.viewContext)
            self.window?.rootViewController = rootCoordinator
            self.window?.makeKeyAndVisible()
        }

        return true
    }
}
