import UIKit

protocol StoryboardInstantiable : UIViewController {
    static var storyboardIdentifier: String { get }
    static var storyboardName: UIStoryboard.Name { get }
}

extension StoryboardInstantiable {
    static var containingStoryboard: UIStoryboard {
        return UIStoryboard(name: self.storyboardName, bundle: nil)
    }

    static var storyboardIdentifier: String {
        return String(describing: self)
    }
}

extension UIStoryboard {
    typealias Name = String

    func instantiate<VC : StoryboardInstantiable>(_ viewController: VC.Type) -> VC {
        guard let controller = self.instantiateViewController(withIdentifier: viewController.storyboardIdentifier) as? VC else {
            fatalError("Storyboard '\(self)' has no VC for identifier '\(viewController.storyboardIdentifier)'")
        }
        return controller
    }
}
