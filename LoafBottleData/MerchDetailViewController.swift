import UIKit
import CoreData

protocol MerchDetailCoordinator : AnyObject {
    func detailDidEndEditing()
}

class MerchDetailViewController : UIViewController, StoryboardInstantiable {
    enum Mode {
        case new(in: NSManagedObjectContext), update(Merch), cancelled
    }

    static let storyboardName: UIStoryboard.Name = "Main"

    static func fromStoryboard(mode: Mode) -> MerchDetailViewController {
        let controller = self.containingStoryboard.instantiate(MerchDetailViewController.self)
        controller.mode = mode
        return controller
    }

    var flowCoordinator: MerchDetailCoordinator?

    private(set) var mode = Mode.cancelled

    @IBOutlet private var nameField: UITextField!
    @IBOutlet private var unitField: UITextField!
    @IBOutlet private var numberOfUsesLabel: UILabel!
    @IBOutlet private var lastUsedLabel: UILabel!

    private var nameBinding: TextFieldBinding<Merch>?
    private var unitBinding: TextFieldBinding<Merch>?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))

        if case let .update(merch) = self.mode {
            self.nameBinding = TextFieldBinding(self.nameField, to: \.name, on: merch)
            self.unitBinding = TextFieldBinding(self.unitField, to: \.unit, on: merch)
            self.numberOfUsesLabel.text = "Number of purchases: \(merch.numberOfUses)"
            self.lastUsedLabel.text = "Last purchased: \(DateFormatter().string(from: merch.lastUsed))"
        }
        else if case .new(in: _) = self.mode {
            self.navigationItem.leftBarButtonItem =
                UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
            self.navigationItem.hidesBackButton = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        switch self.mode {
            case let .new(in: context):
                context.performAndSave {
                    self.createMerch(in: context)
                }
            case let .update(merch):
                guard let context = merch.managedObjectContext else { break }
                _ = context.saveOrRollback()
            case .cancelled:
                break
        }
    }

    @objc private func cancelTapped() {
        self.mode = .cancelled
        self.endEditing()
    }

    @objc private func doneTapped() {
        self.endEditing()
    }

    private func endEditing() {
        guard let coordinator = self.flowCoordinator else {
            fatalError("Missing coordination context")
        }
        coordinator.detailDidEndEditing()
    }

    private func createMerch(in context: NSManagedObjectContext) {
        let name = self.nameField.text!
        guard !(name.isEmpty) else { return }
        let unit = self.unitField.text ?? ""
        _ = Merch.create(in: context, name: name, unit: unit)
    }
}

private class TwoWayBinding<View : NSObject, Model : NSObject, Value> {
    typealias ModelKeyPath = ReferenceWritableKeyPath<Model, Value>
    typealias ViewKeyPath = ReferenceWritableKeyPath<View, Value>

    private let viewObservation: NSKeyValueObservation
    private let modelObservation: NSKeyValueObservation

    init(to view: View, via viewKeyPath: ViewKeyPath,
         on model: Model, at modelKeyPath: ModelKeyPath)
    {
        self.modelObservation = model.observe(modelKeyPath) { (_, change) in
            guard let newValue = change.newValue else { return }
            view[keyPath: viewKeyPath] = newValue
        }

        self.viewObservation = view.observe(viewKeyPath) { (_, change) in
            guard let newValue = change.newValue else { return }
            model[keyPath: modelKeyPath] = newValue
        }

        view[keyPath: viewKeyPath] = model[keyPath: modelKeyPath]
    }
}

private class TextFieldBinding<Model : NSObject> : TwoWayBinding<UITextField, Model, String>  {
    typealias BoundKeyPath = ReferenceWritableKeyPath<Model, String>

    init(_ textField: UITextField, to keyPath: BoundKeyPath, on object: Model) {
        super.init(to: textField, via: \.definitelyText,
                   on: object, at: keyPath)
    }
}

private extension UITextField {
    var definitelyText: String {
        get { return self.text! }
        set { self.text = newValue }
    }
}
