import CoreData

typealias Unit = String

/** A shopping item. */
final class Merch : NSManagedObject {
    @NSManaged var name: String
    @NSManaged var unit: Unit
    @NSManaged private(set) var numberOfUses: Int32
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

/** Dummy instances of `Merch` for use in various tests. */
extension Merch {
    /** List of names to be used for test `Merch` creation. */
    static var dummyNames: [String] = ["Broccoli", "Bananas", "Carrots",
                                       "Apples", "Quince", "Eggs"]

    /** A list of test `Merch`es created with the `dummyNames`. */
    static func makeDummies(inContext context: NSManagedObjectContext) -> [Merch] {

        let uses: [Int32] = [3, 2, 1, 6, 5, 4]
        let dates = uses.map { (_) in Date.random() }
        let info = zip(self.dummyNames, zip(uses, dates))

        return info.map {
            let merch = Merch(context: context)

            merch.name = $0.0
            merch.unit = "Each"
            merch.numberOfUses = $0.1.0
            merch.lastUsed = $0.1.1

            return merch
        }
    }

    static func create(in context: NSManagedObjectContext, name: String, unit: String = "each") -> Merch {

        let merch = Merch(context: context)

        merch.name = name
        merch.unit = unit
        merch.numberOfUses = 0
        merch.lastUsed = Date()

        return merch
    }
}

private extension Date {
    static func random() -> Date {
        let interval = TimeInterval.random(in: 0..<(86400 * 365 * 18))
        return Date(timeIntervalSinceReferenceDate: interval)
    }
}
