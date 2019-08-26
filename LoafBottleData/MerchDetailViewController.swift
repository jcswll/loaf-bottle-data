import UIKit
import CoreData

protocol MerchDetailCoordinator : AnyObject {
    func detailDidEndEditing()
}

class MerchDetailViewController : UIViewController, StoryboardInstantiable, BarButtonItemTarget {

    enum Mode {
        case uninitialized, new, update(Merch), cancelled
    }

    static let storyboardName: UIStoryboard.Name = "Main"

    static func fromStoryboard(mode: Mode, using context: NSManagedObjectContext) -> MerchDetailViewController {
        let controller = self.containingStoryboard.instantiate(MerchDetailViewController.self)
        controller.mode = mode
        controller.context = context
        return controller
    }

    var coordinator: MerchDetailCoordinator?

    @IBOutlet private var nameField: UITextField!
    @IBOutlet private var unitField: UITextField!
    @IBOutlet private var numberOfUsesLabel: UILabel!
    @IBOutlet private var lastUsedLabel: UILabel!

    private var mode: Mode = .uninitialized
    private var context: NSManagedObjectContext!

    private var nameBinding: TextFieldBinding<Merch>?
    private var unitBinding: TextFieldBinding<Merch>?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationItem.rightBarButtonItem = .cancelItem(target: self)

        if case let .update(merch) = self.mode {
            self.nameBinding = TextFieldBinding(self.nameField, to: \.name, on: merch)
            self.unitBinding = TextFieldBinding(self.unitField, to: \.unit, on: merch)
            self.numberOfUsesLabel.text = "Number of purchases: \(merch.numberOfUses)"
            self.lastUsedLabel.text = "Last purchased: \(DateFormatter.dateString(from: merch.lastUsed))"
        }
        else if case .new = self.mode {
            self.navigationItem.leftBarButtonItem = .doneItem(target: self)
            self.navigationItem.hidesBackButton = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.context.perform {
            switch self.mode {
                case .new:
                    self.createMerch(in: self.context)
                    fallthrough
                case .update(_):
                    let saveDidSucceed = self.context.saveOrRollback()
                    if !(saveDidSucceed) {
                        NSLog("Failed to save change")
                    }
                case .cancelled:
                    self.context.rollback()
                case .uninitialized:
                    assertionFailure("Mode was not set on creation")
            }
        }
    }

    @objc func onCancel() {
        self.mode = .cancelled
        self.endEditing()
    }

    @objc func onDone() {
        self.endEditing()
    }

    private func endEditing() {
        guard let coordinator = self.coordinator else {
            fatalError("Missing coordination context")
        }
        coordinator.detailDidEndEditing()
    }

    private func createMerch(in context: NSManagedObjectContext) {
        let name = self.nameField.text!
        let unit = self.unitField.text!
        guard name.hasElements else { return }

        _ = Merch.create(in: context, name: name, unit: unit)
    }
}

private class TextFieldBinding<O : NSObject> : NSObject, UITextFieldDelegate {
    typealias BoundKeyPath = ReferenceWritableKeyPath<O, String>

    private let observation: NSKeyValueObservation
    private let model: O
    private let keyPath: BoundKeyPath

    init(_ textField: UITextField, to keyPath: BoundKeyPath, on object: O) {
        self.observation = object.observe(keyPath) { (_, change) in
            guard let newValue = change.newValue else { return }
            textField.text = newValue
        }

        self.model = object
        self.keyPath = keyPath
        super.init()
        textField.text = model[keyPath: keyPath]
        textField.delegate = self
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.model[keyPath: self.keyPath] = textField.text!
    }
}
