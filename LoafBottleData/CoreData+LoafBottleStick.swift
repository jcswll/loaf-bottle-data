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
