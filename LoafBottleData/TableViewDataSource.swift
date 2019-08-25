import UIKit
import CoreData

protocol TableCell : UITableViewCell {
    static var identifier: Identifier<Self> { get }
    static var nib: UINib { get }
}

extension TableCell {
    static var nib: UINib {
        return UINib(nibName: self.identifier.rawValue, bundle: nil)
    }
}

protocol ManagedObjectTableCell : TableCell {
    associatedtype Object : ManagedObject
    var object: Object? { get set }
}

protocol TableViewDataSourceDelegate : AnyObject {
    associatedtype Object : ManagedObject
    associatedtype Cell : TableCell

    func configureCell(_ cell: Cell, for object: Object)
}

extension TableViewDataSourceDelegate where Cell : ManagedObjectTableCell, Cell.Object == Object {
    func configureCell(_ cell: Cell, for object: Object) {
        cell.object = object
    }
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
        table.registerCell(MerchTableCell.self)
        super.init()
        resultsController.delegate = self
        try! resultsController.performFetch()
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }

    func numberOfSections(in _: UITableView) -> Int {
        guard let sections = self.resultsController.sections else {
            fatalError("Fetch succeeded but no section data")
        }

        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection sectionIndex: Int) -> Int {
        guard let sections = self.resultsController.sections else {
            fatalError("Fetch succeeded but no section data")
        }

        return sections[sectionIndex].numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = self.resultsController.object(at: indexPath)
        let cell = self.tableView.dequeueCell(Cell.self, at: indexPath)
        self.delegate?.configureCell(cell, for: object)
        return cell
    }
}

private extension UITableView {

    func registerCell<Cell : TableCell>(_ kind: Cell.Type) {
        self.register(Cell.nib, forCellReuseIdentifier: Cell.identifier.rawValue)
    }

    func dequeueCell<Cell : TableCell>(_ kind: Cell.Type, at indexPath: IndexPath) -> Cell {
        guard let cell = self.dequeueReusableCell(withIdentifier: kind.identifier.rawValue, for: indexPath) as? Cell else {
            fatalError("Could not dequeue cell of correct type '\(kind)'")
        }
        return cell
    }
}
