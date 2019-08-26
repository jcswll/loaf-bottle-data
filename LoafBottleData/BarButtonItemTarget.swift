import UIKit

@objc protocol BarButtonItemTarget : NSObjectProtocol {
    @objc optional func onAdd()
    @objc optional func onCancel()
    @objc optional func onDone()
}

extension UIBarButtonItem {

    static func addItem(target: BarButtonItemTarget) -> UIBarButtonItem {
        let action = #selector(BarButtonItemTarget.onAdd)
        precondition(target.responds(to: action))
        return UIBarButtonItem(barButtonSystemItem: .add, target: target, action: action)
    }

    static func cancelItem(target: BarButtonItemTarget) -> UIBarButtonItem {
        let action = #selector(BarButtonItemTarget.onCancel)
        precondition(target.responds(to: action))
        return UIBarButtonItem(barButtonSystemItem: .cancel, target: target, action: action)
    }

    static func doneItem(target: BarButtonItemTarget) -> UIBarButtonItem {
        let action = #selector(BarButtonItemTarget.onDone)
        precondition(target.responds(to: action))
        return UIBarButtonItem(barButtonSystemItem: .done, target: target, action: action)
    }
}
