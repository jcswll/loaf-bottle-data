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
        table.registerCell(Cell.self)
        super.init()
        resultsController.delegate = self
        try! resultsController.performFetch()
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }

    func object(at indexPath: IndexPath) -> Object {
        return self.resultsController.object(at: indexPath)
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

    func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
        return true
    }

    func tableView(_: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let object = self.resultsController.object(at: indexPath)
        object.delete()
    }

    //MARK:- NSFetchedResultsControllerDelegate

    func controllerWillChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }

    func controller(_: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange object: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?)
    {
        guard object is Object else { fatalError("Wrong object type in change") }
        guard let change = FetchedResultsChange(type, oldIndexPath: indexPath, newIndexPath: newIndexPath) else {
            fatalError("Missing required index path(s) for change of type '\(type)'")
        }

        self.tableView.performChange(change)
    }

    func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
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

    func performChange(_ change: FetchedResultsChange) {
        switch change {
            case let .delete(from: indexPath):
                self.deleteRows(at: [indexPath], with: .automatic)
            case let .insert(at: indexPath):
                self.insertRows(at: [indexPath], with: .automatic)
            case let .move(from: oldIndexPath, to: newIndexPath):
                self.moveRow(at: oldIndexPath, to: newIndexPath)
            case let .update(at: indexPath):
                self.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

private enum FetchedResultsChange {
    case delete(from: IndexPath)
    case insert(at: IndexPath)
    case move(from: IndexPath, to: IndexPath)
    case update(at: IndexPath)
}

private extension FetchedResultsChange {
    init?(_ type: NSFetchedResultsChangeType, oldIndexPath: IndexPath?, newIndexPath: IndexPath?) {
        switch type {
            case .delete:
                guard let indexPath = oldIndexPath else { return nil }
                self = .delete(from: indexPath)
            case .insert:
                guard let indexPath = newIndexPath else { return nil }
                self = .insert(at: indexPath)
            case .move:
                guard let oldIndexPath = oldIndexPath, let newIndexPath = newIndexPath else { return nil }
                self = .move(from: oldIndexPath, to: newIndexPath)
            case .update:
                guard let indexPath = oldIndexPath else { return nil }
                self = .update(at: indexPath)
            @unknown default:
                return nil
        }
    }
}
