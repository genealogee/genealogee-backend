import Fluent
import Vapor

struct DatabasePersonRepository: PersonRepository {
    let req: Request
    var db: Database

    init(req: Request, db: Database? = nil) {
        self.req = req
        self.db = db ?? req.db
    }
}
