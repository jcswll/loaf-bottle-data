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
            let context = container.viewContext

            //!!!: Only for development
            context.performThenSave {
                container.deleteAllObjects(ofType: Merch.self)
                _ = Merch.makeDummies(inContext: context)
            }
            ///!!!: /development

            let rootViewController = RootViewController.fromStoryBoard(managedObjectContent: context)
            self.window?.rootViewController = rootViewController
            self.window?.makeKeyAndVisible()
        }

        return true
    }
}
