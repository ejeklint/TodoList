import Vapor
import VaporSQLite

let drop = Droplet()

try drop.addProvider(VaporSQLite.Provider.self)

let taskController = TaskController()
taskController.addRoutes(drop: drop)

drop.run()
