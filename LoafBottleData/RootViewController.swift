import UIKit
import CoreData

class RootViewController : UIViewController, StoryboardInstantiable {

    static func fromStoryBoard(managedObjectContent: NSManagedObjectContext) -> RootViewController {
        let controller = self.containingStoryboard.instantiate(RootViewController.self)
        controller.managedObjectContext = managedObjectContent
        return controller
    }

    static var storyboardName: UIStoryboard.Name = "Main"

    private(set) var managedObjectContext: NSManagedObjectContext!

    override func viewDidLoad() {
        let navRoot = MerchTableViewController(managedObjectContext: self.managedObjectContext)
        let navigation = UINavigationController(rootViewController: navRoot)
        self.addFullSizeChild(navigation)
    }
}

private extension UIViewController {
    func addFullSizeChild(_ viewController: UIViewController) {
        viewController.willMove(toParent: self)
        self.addChild(viewController)
        self.view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
}
