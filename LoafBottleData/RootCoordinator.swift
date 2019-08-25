import UIKit
import CoreData

class RootCoordinator : UIViewController, StoryboardInstantiable {

    static func fromStoryBoard(managedObjectContent: NSManagedObjectContext) -> RootCoordinator {
        let coordinator = self.containingStoryboard.instantiate(RootCoordinator.self)
        coordinator.managedObjectContext = managedObjectContent
        coordinator.prepareDevelopmentDB()    //!!!: For dev only
        return coordinator
    }

    static var storyboardName: UIStoryboard.Name = "Main"

    private(set) var managedObjectContext: NSManagedObjectContext!

    override func viewDidLoad() {
        let tableController = MerchTableViewController(managedObjectContext: self.managedObjectContext)
        tableController.coordinator = self
        let navigation = UINavigationController(rootViewController: tableController)
        navigation.embedWithin(self)
    }
}

extension RootCoordinator : MerchTableCoordinator {
    func userDidTapAdd() {
        self.managedObjectContext.performThenSave {
            _ = Merch.create(in: self.managedObjectContext, name: "Beeswax")
        }
    }

    func userDidSelectObject(_ object: Merch) {
        let alert = UIAlertController.init(
            title: "No edits for you",
            message: "Editing functionality isn't implemented just yet.",
            preferredStyle: .alert
        )

        let okay = UIAlertAction(title: "Aw, shucks", style: .default)

        alert.addAction(okay)

        self.present(alert, animated: true)
    }
}

private extension RootCoordinator {
    func prepareDevelopmentDB() {
        let context = self.managedObjectContext!
        context.performThenSave {
            context.deleteAllObjects(ofType: Merch.self)
            _ = Merch.makeDummies(inContext: context)
        }
    }
}

private extension UIViewController {
    func embedWithin(_ parent: UIViewController) {
        self.willMove(toParent: parent)
        parent.addChild(self)
        parent.view.addSubview(self.view)
        self.didMove(toParent: parent)
    }
}
