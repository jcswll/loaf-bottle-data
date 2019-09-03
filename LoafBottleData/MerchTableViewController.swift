import UIKit
import CoreData

protocol MerchTableCoordinator : AnyObject {
    func userDidTapAdd()
    func userDidSelectObject(_ object: Merch)
}

final class MerchTableViewController : UITableViewController, TableViewDataSourceDelegate, BarButtonItemTarget {

    typealias Cell = MerchTableCell
    typealias Object = Cell.Object

    weak var coordinator: MerchTableCoordinator? = nil
    private let fetchResultsController: MerchFetchResultsController
    private var tableDataSource: TableDataSource<MerchTableViewController>!

    init(fetchResultsController: MerchFetchResultsController) {
        self.fetchResultsController = fetchResultsController
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("This is stupid")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpTableView()
        self.setUpNavBar()
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let merch = self.tableDataSource.object(at: indexPath)
        guard let coordinator = self.coordinator else {
            assertionFailure("Need coordinator to allow the user to edit items")
            return
        }

        coordinator.userDidSelectObject(merch)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }

    private func setUpTableView() {
        self.tableDataSource = TableDataSource(table: self.tableView,
                                               resultsController: self.fetchResultsController,
                                               delegate: self)
    }

    private func setUpNavBar() {
        self.navigationItem.rightBarButtonItem = .addItem(target: self)
        self.navigationItem.title = "Merch"
    }

    @objc func onAdd() {
        guard let coordinator = self.coordinator else {
            assertionFailure("Need coordinator to allow the user to add items")
            return
        }

        coordinator.userDidTapAdd()
    }
}
