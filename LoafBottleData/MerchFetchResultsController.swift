import CoreData

final class MerchFetchResultsController : NSFetchedResultsController<Merch> {
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
