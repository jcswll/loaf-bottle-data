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

    func performAndSave(_ executeChanges: @escaping () -> Void) {

        self.perform {
            executeChanges()
            _ = self.saveOrRollback()
        }
    }

    func deleteAllObjects<O : ManagedObject>(ofType type: O.Type) {
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: O.fetchRequest())
        do { try self.persistentStoreCoordinator!.execute(deleteRequest, with: self) }
        catch { NSLog("Delete request for '\(O.self)' failed: \(error)") }
    }
}
