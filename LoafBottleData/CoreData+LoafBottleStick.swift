import CoreData

extension NSPersistentContainer {

    static func withLBSContainer(_ completion: @escaping (NSPersistentContainer) -> Void) {

        let container = NSPersistentContainer(name: "LoafBottleData")
        container.loadPersistentStores { (_, error) in
            guard error == nil else {
                fatalError("Failed to load store: \(error!)")
            }

            DispatchQueue.main.async {
                completion(container)
            }
        }
    }

    func deleteAllObjects<O : ManagedObject>(ofType type: O.Type) {
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: O.fetchRequest())
        try! self.persistentStoreCoordinator.execute(deleteRequest, with: self.viewContext)
    }
}

extension NSManagedObjectContext {

    func saveOrRollback() -> Bool {

        do { try self.save() }
        catch {
            self.rollback()
            return false
        }

        return true
    }

    func performThenSave(_ executeChanges: @escaping () -> Void) {

        self.perform {
            executeChanges()
            _ = self.saveOrRollback()
        }
    }
}
