import Fluent
import Vapor

extension TreeSnapshot.DTO {
    struct Created: Content {
        let id: UUID
        let creatorID: UUID
        let treeID: UUID
        let snapshotData: Tree.Snapshot
        let createdAt: Date

        init(_ snapshot: TreeSnapshot, _ db: Database) async throws {
            id = try snapshot.requireID()
            creatorID = try await snapshot.$creator.get(on: db).requireID()
            treeID = try await snapshot.$tree.get(on: db).requireID()
            snapshotData = snapshot.snapshotData
            createdAt = Date.now // TODO: Make sure this is correct
        }
    }
}
