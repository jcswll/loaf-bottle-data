import UIKit
import CoreData

final class MerchTableViewController : UITableViewController, TableViewDataSourceDelegate {

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
    }

    private func setUpTableView() {
        let fetchRequest = Merch.sortedFetchRequest
        fetchRequest.fetchBatchSize = 20
        fetchRequest.returnsObjectsAsFaults = false
        let controller = MerchFetchController(batchSize: 20, context: self.managedObjectContext)
        self.tableDataSource = TableDataSource(table: self.tableView, resultsController: controller, delegate: self)
    }

    func configureCell(_ cell: MerchTableCell, for object: Merch) {

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
