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
        self.navigation.delegate = self
    }
}

extension RootCoordinator : UINavigationControllerDelegate {
    func navigationController(_: UINavigationController, willShow viewController: UIViewController, animated _: Bool) {
        if viewController is MerchTableViewController && self.state != .mainTable {
            self.state = .mainTable
        }
    }
}

extension RootCoordinator : MerchTableCoordinator {
    func userDidTapAdd() {
        self.state = .creating
        let controller = MerchDetailViewController.fromStoryboard(mode: .create, using: self.managedObjectContext)
        let navigation = UINavigationController(rootViewController: controller)
        controller.coordinator = self
        self.present(navigation, animated: true)
    }

    func userDidSelectObject(_ object: Merch) {
        self.state = .editing
        let controller = MerchDetailViewController.fromStoryboard(mode: .update(object), using: self.managedObjectContext)
        controller.coordinator = self
        self.navigation.pushViewController(controller, animated: true)
    }
}

extension RootCoordinator : MerchDetailCoordinator {
    func detailDidEndEditing() {
        guard self.state != .mainTable else { return }

        if self.state == .creating {
            self.dismiss(animated: true)
        }
        else if self.state == .editing {
            self.navigation.popViewController(animated: true)
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
