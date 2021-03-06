import UIKit

final class MerchTableCell : UITableViewCell, ManagedObjectTableCell {
    static let identifier: Identifier<MerchTableCell> = "MerchTableCell"

    @IBOutlet var nameLabel: UILabel!

    var object: Merch? = nil {
        didSet {
            if let merch = self.object {
                self.configure(using: merch)
            }
        }
    }

    private func configure(using merch: Merch) {
        self.nameLabel.text = merch.name
    }
}
