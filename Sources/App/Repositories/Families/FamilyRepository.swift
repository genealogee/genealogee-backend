import Fluent
import Vapor

enum FamilyRepositoryScope {
    case currentUser
    case user(UUID)
    case none
}

enum FamilyRepositoryRelation {
    case child(UUID)
    case parent(UUID)
    case any(UUID)
}

protocol FamilyRepository {
    var req: Request { get }
    var db: Database { get }

    init(req: Request, db: Database?)

    func using(_ db: Database) -> Self

    func scoped(by scope: FamilyRepositoryScope) throws -> QueryBuilder<Family>
    func byID(_ id: UUID) throws -> QueryBuilder<Family>

    func get(_ id: UUID) async throws -> Family
    func has(_ familyID: UUID, _ relation: FamilyRepositoryRelation) async throws -> Bool
}

struct FamilyRepositoryFactory {
    var make: ((Request) -> FamilyRepository)?
    mutating func use(_ make: @escaping ((Request) -> FamilyRepository)) {
        self.make = make
    }
}

extension Application {
    private struct FamilyRepositoryKey: StorageKey {
        typealias Value = FamilyRepositoryFactory
    }

    var families: FamilyRepositoryFactory {
        get {
            storage[FamilyRepositoryKey.self] ?? .init()
        }
        set {
            storage[FamilyRepositoryKey.self] = newValue
        }
    }
}

extension Request {
    var families: FamilyRepository {
        application.families.make!(self)
    }
}
