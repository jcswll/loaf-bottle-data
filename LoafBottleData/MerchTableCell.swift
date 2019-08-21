import UIKit

final class MerchTableCell : UITableViewCell, TableCell {
    static let identifier: Identifier<MerchTableCell> = "MerchTableCell"

    @IBOutlet var nameLabel: UILabel!

    var merch: Merch? = nil {
        didSet {
            if let merch = self.merch {
                self.configure(using: merch)
            }
        }
    }

    private func configure(using merch: Merch) {
        self.nameLabel.text = merch.name
    }
}
