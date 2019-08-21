import CoreData

protocol ManagedObject : NSManagedObject {
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
}

extension ManagedObject {
    static var entityName: String {
        return self.entity().name!
    }

    static var defaultSortDescriptors: [NSSortDescriptor] {
        return []
    }

    static var sortedFetchRequest: NSFetchRequest<Self> {
        let request = NSFetchRequest<Self>(entityName: self.entityName)
        request.sortDescriptors = self.defaultSortDescriptors
        return request
    }
}
