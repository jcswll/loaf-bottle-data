import UIKit

@objc protocol BarButtonItemTarget {
    func onCancel()
    func onDone()
}

extension UIBarButtonItem {
    static func doneItem(target: BarButtonItemTarget) -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .done, target: target, action: #selector(BarButtonItemTarget.onDone))
    }

    static func cancelItem(target: BarButtonItemTarget) -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .cancel, target: target, action: #selector(BarButtonItemTarget.onCancel))
    }
}
