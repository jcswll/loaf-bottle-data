import UIKit
import CoreData

protocol MerchDetailCoordinator : AnyObject {
    func detailDidEndEditing()
}

class MerchDetailViewController : UIViewController, StoryboardInstantiable, BarButtonItemTarget {

    enum Mode {
        case create, update(Merch)
    }

    private enum State {
        case uninitialized, active(Mode), cancelled, finished
    }

    static let storyboardName: UIStoryboard.Name = "Main"

    static func fromStoryboard(mode: Mode, using context: NSManagedObjectContext) -> MerchDetailViewController {
        let controller = self.containingStoryboard.instantiate(MerchDetailViewController.self)
        controller.state = .active(mode)
        controller.context = context
        return controller
    }

    var coordinator: MerchDetailCoordinator?

    @IBOutlet private var nameField: UITextField!
    @IBOutlet private var unitField: UITextField!
    @IBOutlet private var numberOfUsesLabel: UILabel!
    @IBOutlet private var lastUsedLabel: UILabel!

    private var state: State = .uninitialized
    private var context: NSManagedObjectContext!

    private var nameBinding: TextFieldBinding<Merch>?
    private var unitBinding: TextFieldBinding<Merch>?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard case let .active(mode) = self.state else {
            fatalError("Must have an activity to perform on being displayed")
        }

        self.navigationItem.rightBarButtonItem = .cancelItem(target: self)

        if case let .update(merch) = mode {
            self.nameBinding = TextFieldBinding(self.nameField, to: \.name, on: merch)
            self.unitBinding = TextFieldBinding(self.unitField, to: \.unit, on: merch)
            self.numberOfUsesLabel.text = "Number of purchases: \(merch.numberOfUses)"
            self.lastUsedLabel.text = "Last purchased: \(DateFormatter.dateString(from: merch.lastUsed))"
        }
        else if case .create = mode {
            self.navigationItem.leftBarButtonItem = .doneItem(target: self)
            self.navigationItem.hidesBackButton = true
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.endEditing()
    }

    @objc func onCancel() {
        self.state = .cancelled
        self.endEditing()
    }

    @objc func onDone() {
        self.endEditing()
    }

    private func endEditing() {
        guard let coordinator = self.coordinator else {
            fatalError("Missing coordination context")
        }

        switch self.state {
            case .uninitialized:
                fatalError("Never set state before displaying")
            case let .active(mode):
                self.finalizeActivity(for: mode)
            case .cancelled:
                self.handleCancellation()
            case .finished:
                return
        }

        coordinator.detailDidEndEditing()
    }

    private func finalizeActivity(for mode: Mode) {
        self.context.perform {
            if case .create = mode {
                self.createMerch(in: self.context)
            }

            let saveDidSucceed = self.context.saveOrRollback()
            if !(saveDidSucceed) {
                NSLog("Failed to save change")
            }
        }

        self.state = .finished
    }

    private func createMerch(in context: NSManagedObjectContext) {
        let name = self.nameField.text!
        let unit = self.unitField.text!
        guard name.hasElements else { return }

        _ = Merch.create(in: context, name: name, unit: unit)
    }

    private func handleCancellation() {
        self.context.perform {
            self.context.rollback()
        }

        self.state = .finished
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
