import Fluent
import Vapor

extension DatabasePersonRepository {
    func get(_ id: UUID) async throws -> Person {
        let query = try scoped(by: .currentUser)
            .filter(\.$id == id)

        guard let result = try await query.first() else {
            throw Abort(.notFound, reason: "Person with ID '\(id)' does not exist")
        }

        return result
    }

    func get(_ ids: [UUID]) async throws -> [Person] {
        let result = try await scoped(by: .currentUser)
            .filter(\.$id ~~ ids)
            .all()

        if result.count != ids.count {
            let difference = try? ids.difference(from: result.map { try $0.requireID() })

            var message: String

            if let difference = difference {
                message = "Not all people were found: \(difference)"
            } else {
                message = "Not all people were found. Could not calculate the difference."
            }

            req.logger.warning(.init(stringLiteral: message))
        }

        return result
    }
}
