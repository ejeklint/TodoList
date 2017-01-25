//
//  TodoController.swift
//  TodoList
//
//  Created by Per Ejeklint on 2017-01-25.
//
//

import Vapor
import VaporSQLite
import HTTP
import Foundation

class Task: NodeRepresentable {
    var id: Int!
    var title: String!
    
    convenience init?(node: Node) {
        self.init()
        
        guard let id = node["id"]?.int, let title = node["title"]?.string else {
                return nil
        }
        
        self.id = id
        self.title = title
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: ["id": self.id, "title": self.title])
    }
}

final class TaskController {
    
    func addRoutes(drop: Droplet) {
        drop.get("tasks", "all", handler: getAll)
        drop.post("tasks", "create", handler: create)
        drop.post("tasks", "delete", handler: delete)
    }
    
    func delete(_ req: Request) throws -> ResponseRepresentable {
        guard let id = req.data["id"]?.int else {
            throw Abort.badRequest
        }
        
        try drop.database?.driver.raw("DELETE FROM Tasks WHERE id = ?", [id])
        
        return try JSON(node: ["success": true])
    }
    
    func create(_ req: Request) throws -> ResponseRepresentable {
        guard let title = req.data["title"]?.string else {
            throw Abort.badRequest
        }
        
        try drop.database?.driver.raw("INSERT INTO Tasks(title) VALUES(?)", [title])
        
        return try JSON(node: ["success": true])
    }
    
    func getAll(_ req: Request) throws -> ResponseRepresentable {
        let result = try drop.database?.driver.raw("SELECT id, title from Tasks;")
        
        guard let nodes = result?.nodeArray else {
            return try JSON(node: [])
        }
        
        let tasks = nodes.flatMap(Task.init)
        
        return try JSON(node:tasks)
    }
}
