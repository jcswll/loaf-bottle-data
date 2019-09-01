import CoreData

class ManagedObjectEditor<Object : ManagedObject> {

    enum Activity {
        case create(in: NSManagedObjectContext), update(Object)
    }

    enum Mode {
        case creating, updating(Object)

        fileprivate init(for activity: Activity) {
            switch activity {
                case .create(in: _):
                    self = .creating
                case let .update(object):
                    self = .updating(object)
            }
        }
    }

    private(set) var mode: Mode
    private let context: NSManagedObjectContext

    init(activity: Activity) {
        self.mode = Mode(for: activity)
        switch activity {
            case let .create(context):
                self.context = context
            case let .update(object):
                self.context = object.managedObjectContext !! "Object must have a context for editing"
        }
    }

    func edit(saving: Bool, _ performEdits: @escaping (Object) -> Void) {
        self.context.perform {
            let object = self.produceObject()
            performEdits(object)

            if saving {
                _ = self.save()
            }
        }
    }

    func save() -> Bool {
        return self.context.saveOrRollback()
    }

    func cancel() {
        self.context.rollback()
    }

    private func produceObject() -> Object {
        switch self.mode {
            case .creating:
                let object = Object(context: self.context)
                self.mode = .updating(object)
                return object
            case let .updating(updatingObject):
                return updatingObject
        }
    }
}
