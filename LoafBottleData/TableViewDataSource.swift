import UIKit
import CoreData

protocol TableCell : UITableViewCell {
    static var identifier: Identifier<Self> { get }
}

protocol TableViewDataSourceDelegate : AnyObject {
    associatedtype Object : ManagedObject
    associatedtype Cell : TableCell

    func configureCell(_ cell: Cell, for object: Object)
}

class TableDataSource<Delegate : TableViewDataSourceDelegate> : NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    typealias Object = Delegate.Object
    typealias FetchedResultsController = NSFetchedResultsController<Object>
    typealias Cell = Delegate.Cell

    private let tableView: UITableView
    private let resultsController: FetchedResultsController
    private weak var delegate: Delegate?

    required init(table: UITableView, resultsController: FetchedResultsController, delegate: Delegate) {
        self.tableView = table
        self.resultsController = resultsController
        self.delegate = delegate
        super.init()
        resultsController.delegate = self
        try! resultsController.performFetch()
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = self.resultsController.sections?[section] else { return 0 }
        return section.numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = self.resultsController.object(at: indexPath)
        let cell = self.tableView.dequeueCell(Cell.self, at: indexPath)
        self.delegate?.configureCell(cell, for: object)
        return cell
    }
}

private extension UITableView {
    func dequeueCell<Cell : TableCell>(_ kind: Cell.Type, at indexPath: IndexPath) -> Cell {
        guard let cell = self.dequeueReusableCell(withIdentifier: kind.identifier.rawValue, for: indexPath) as? Cell else {
            fatalError("Could not dequeue cell of correct type '\(kind)'")
        }
        return cell
    }
}