import UIKit
import CoreData

protocol MerchTableCoordinator : AnyObject {
    func userDidTapAdd()
    func userDidSelectObject(_ object: Merch)
}

final class MerchTableViewController : UITableViewController, TableViewDataSourceDelegate {

    typealias Cell = MerchTableCell
    typealias Object = Cell.Object

    weak var coordinator: MerchTableCoordinator? = nil
    let managedObjectContext: NSManagedObjectContext
    private var tableDataSource: TableDataSource<MerchTableViewController>!

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
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
        let resultsController = MerchFetchController(batchSize: 20, context: self.managedObjectContext)
        self.tableDataSource = TableDataSource(table: self.tableView, resultsController: resultsController, delegate: self)
    }

    private func setUpNavBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMerch))
        self.navigationItem.setRightBarButton(addButton, animated: false)
    }

    @objc private func addMerch() {
        guard let coordinator = self.coordinator else {
            assertionFailure("Need coordinator to allow the user to add items")
            return
        }

        coordinator.userDidTapAdd()
    }
}

private final class MerchFetchController : NSFetchedResultsController<Merch> {
    init(batchSize: Int, context: NSManagedObjectContext) {
        let request = Merch.sortedFetchRequest
        request.fetchBatchSize = batchSize
        request.returnsObjectsAsFaults = false
        super.init(fetchRequest: request,
                   managedObjectContext: context,
                   sectionNameKeyPath: nil,
                   cacheName: nil)
    }
}
