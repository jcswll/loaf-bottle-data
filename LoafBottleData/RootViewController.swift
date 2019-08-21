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
        viewController.view.constrainEqualSizeWithSuperview()
        viewController.didMove(toParent: self)
    }
}

private extension UIView {
    func constrainEqualSizeWithSuperview() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([
            self.equalSuperviewConstraint(for: .top),
            self.equalSuperviewConstraint(for: .trailing),
            self.equalSuperviewConstraint(for: .bottom),
            self.equalSuperviewConstraint(for: .leading),
        ])
    }

    private func equalSuperviewConstraint(for attribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint {
        guard let superview = self.superview else {
            fatalError("Must have a superview to add constraints")
        }
        return NSLayoutConstraint.equal(for: attribute, from: superview, to: self)
    }
}

private extension NSLayoutConstraint {
    static func equal(for attribute: Attribute, from: UIView, to: UIView) -> NSLayoutConstraint {
        return self.init(item: from,
                         attribute: attribute,
                         relatedBy: .equal,
                         toItem: to,
                         attribute: attribute,
                         multiplier: 1.0,
                         constant: 0.0)
    }
}
