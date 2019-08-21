import CoreData

typealias Unit = String

/** A shopping item. */
final class Merch : NSManagedObject {
    @NSManaged private(set) var name: String
    @NSManaged private(set) var unit: Unit
    @NSManaged private(set) var numUses: Int32
    @NSManaged private(set) var lastUsed: Date
}

extension Merch : ManagedObject {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [
            NSSortDescriptor(keyPath: \Merch.name, ascending: true),
            NSSortDescriptor(keyPath: \Merch.lastUsed, ascending: false),
        ]
    }
}
