import UIKit
import CoreData

protocol MerchDetailCoordinator : AnyObject {
    func detailDidEndEditing()
    func detailSaveDidFail()
}

class MerchDetailViewController : UIViewController, StoryboardInstantiable, BarButtonItemTarget {

    typealias Editor = ManagedObjectEditor<Merch>

    private enum State {
        case uninitialized, active(Editor), cancelled(Editor), finished
    }

    static let storyboardName: UIStoryboard.Name = "Main"

    static func fromStoryboard(using editor: Editor) -> MerchDetailViewController {
        let controller = self.containingStoryboard.instantiate(MerchDetailViewController.self)
        controller.state = .active(editor)
        return controller
    }

    var coordinator: MerchDetailCoordinator?

    @IBOutlet private var nameField: UITextField!
    @IBOutlet private var unitField: UITextField!
    @IBOutlet private var numberOfUsesLabel: UILabel!
    @IBOutlet private var lastUsedLabel: UILabel!

    private var state: State = .uninitialized

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard case let .active(editor) = self.state else {
            fatalError("Must have an editor on being displayed")
        }

        self.navigationItem.rightBarButtonItem = .cancelItem(target: self)

        switch editor.mode {
            case let .updating(merch):
                self.nameField.text = merch.name
                self.unitField.text = merch.unit
                self.numberOfUsesLabel.text = "Number of purchases: \(merch.numberOfUses)"
                self.lastUsedLabel.text = "Last purchased: \(DateFormatter.dateString(from: merch.lastUsed))"
            case .creating:
                self.navigationItem.leftBarButtonItem = .doneItem(target: self)
                self.navigationItem.hidesBackButton = true
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.endEditing()
    }

    @objc func onCancel() {
        guard case let .active(editor) = self.state else { return }
        self.state = .cancelled(editor)
        self.endEditing()
    }

    @objc func onDone() {
        self.endEditing()
    }

    private func endEditing() {
        let coordinator = self.coordinator !! "Must have coordination context"

        switch self.state {
            case .uninitialized:
                fatalError("Never set state before displaying")
            case let .active(editor):
                self.finalizeEditing(using: editor)
            case let .cancelled(editor):
                self.handleCancellation(using: editor)
            case .finished:
                return
        }

        self.state = .finished

        coordinator.detailDidEndEditing()
    }

    private func finalizeEditing(using editor: Editor) {

        let name = self.nameField.text!
        let unit = self.unitField.text!
        guard name.hasElements else { return }

        editor.edit(saving: true) { (merch) in
            merch.name = name
            merch.unit = unit
        }
    }

    private func handleCancellation(using editor: Editor) {
        editor.cancel()
    }
}
