import UIKit
import CoreData

class RootCoordinator : UIViewController, StoryboardInstantiable {

    private enum State {
        case mainTable
        case creating
        case editing
    }

    static func fromStoryBoard(managedObjectContent: NSManagedObjectContext) -> RootCoordinator {
        let coordinator = self.containingStoryboard.instantiate(RootCoordinator.self)
        coordinator.managedObjectContext = managedObjectContent
//        coordinator.prepareDevelopmentDB()    //!!!: For dev only
        return coordinator
    }

    static var storyboardName: UIStoryboard.Name = "Main"

    private(set) var managedObjectContext: NSManagedObjectContext!

    private var navigation: UINavigationController!

    private var state: State = .mainTable

    override func viewDidLoad() {
        let tableController = MerchTableViewController(managedObjectContext: self.managedObjectContext)
        tableController.coordinator = self
        self.navigation = UINavigationController(rootViewController: tableController)
        self.navigation.embedWithin(self)
    }
}

extension RootCoordinator : UINavigationControllerDelegate {
    func navigationController(_: UINavigationController, didShow viewController: UIViewController, animated _: Bool) {
        if viewController is MerchTableViewController {
            self.state = .mainTable
        }
    }
}

extension RootCoordinator : MerchTableCoordinator {
    func userDidTapAdd() {
        self.state = .creating
        let controller = MerchDetailViewController.fromStoryboard(mode: .new(in: self.managedObjectContext))
        let navigation = UINavigationController(rootViewController: controller)
        controller.flowCoordinator = self
        self.present(navigation, animated: true)
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

extension RootCoordinator : MerchDetailCoordinator {
    func detailDidEndEditing() {
        if self.state == .creating {
            self.dismiss(animated: true)
        }

        self.state = .mainTable
    }
}

private extension RootCoordinator {
    func prepareDevelopmentDB() {
        let context = self.managedObjectContext!
        context.performAndSave {
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
