import Vapor

struct PersonController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let person = routes.grouped("person")
        person.post("create", use: create)

        let certainPerson = person.grouped(":personID")
        certainPerson.get(use: byID)
        certainPerson.delete(use: delete)

        routes.get("people", use: all)
    }

    func create(req: Request) async throws -> Person.Created {
        try Person.Create.validate(content: req)

        let data = try await Person.Create.decodeRequest(req)

        return try await .init(
            req.peopleService.create(from: data),
            req.db
        )
    }

    func delete(req: Request) async throws -> HTTPStatus {
        let personID = try req.parameters.require("personID", as: UUID.self)

        try await req.peopleService.delete(personID)

        return .ok
    }

    func byID(req: Request) async throws -> Person.DTO.Send {
        let personID = try req.parameters.require("personID", as: UUID.self)

        return try await .init(req.people.get(personID))
    }

    // MARK: - Connections (currently unavailable)

    func partner(req: Request) async throws -> Family.DTO.Send {
        let personID = try req.parameters.require("personID", as: UUID.self)
        let partnerID = try req.parameters.require("partnerID", as: UUID.self)

        return try await .init(
            req.peopleService.addRelative(personID: personID, .partner(partnerID)),
            on: req.db
        )
    }

    func child(req: Request) async throws -> Family.DTO.Send {
        let personID = try req.parameters.require("personID", as: UUID.self)
        let childID = try req.parameters.require("childID", as: UUID.self)

        return try await .init(
            req.peopleService.addRelative(personID: personID, .child(childID)),
            on: req.db
        )
    }

    // MARK: - Development

    func all(req: Request) async throws -> [Person] {
        guard req.application.environment == .development else {
            throw Abort(.notFound)
        }

        return try await req
            .people
            .scoped(by: .currentUser)
            .with(\.$family)
            .with(\.$parentFamily)
            .all()
    }
}
