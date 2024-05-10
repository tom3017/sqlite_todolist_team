//
//  TodoListDB.swift
//  SQLiteSimpleTodoList
//
//  Created by 박정민 on 5/7/24.
//


import Foundation
import SQLite3

protocol QueryModelProtocol{
    func itemDownloaded(items: [TodoLists])
    
}

class TodoListDB{
    var db: OpaquePointer?
    var todoLists: [TodoLists] = []
    var delegate: QueryModelProtocol!
    
    init(){
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appending(path: "TimeTodoListData.sqlite")
        // 주소 연산자라서 & 를 사용해서 db 를 찾음
        if sqlite3_open(fileURL.path(percentEncoded: true), &db) != SQLITE_OK{
            print("error opening database")
        }
        
        
        //Table 만들기
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS timetodo(sid INTEGER PRIMARY KEY AUTOINCREMENT, sitem TEXT)", nil,nil,nil) != SQLITE_OK{
            let errMsg = String(cString: sqlite3_errmsg(db))
            print("error creating table : \(errMsg)")
        }
    
    }
    
    func queryDB(){
        var stmt: OpaquePointer?
        let queryString = "SELECT * FROM timetodo"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errMsg = String(cString: sqlite3_errmsg(db))
            print("error creating table : \(errMsg)")
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = Int(sqlite3_column_int(stmt, 0))
            let todoItems = String(cString: sqlite3_column_text(stmt, 1))

            
            todoLists.append(TodoLists(id: Int32(id), items: todoItems))
            
        }
        
        delegate.itemDownloaded(items: todoLists)
        
    }
    
    func insertDB(todoItem: String) -> Bool{
        var stmt: OpaquePointer?
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        let queryString = "INSERT INTO timetodo (sitem) VALUES (?)"
        
        sqlite3_prepare(db, queryString, -1, &stmt, nil)
        
        sqlite3_bind_text(stmt, 1, todoItem, -1, SQLITE_TRANSIENT)

        
        if sqlite3_step(stmt) == SQLITE_DONE{
            return true
        } else {
            return false
        }
        
    }
    
    
    
    
    
    func deleteDB(id: Int32) -> Bool{
        var stmt: OpaquePointer?
//        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        let queryString = "DELETE FROM timetodo where sid = ?"
        
        sqlite3_prepare(db, queryString, -1, &stmt, nil)
        
        sqlite3_bind_int(stmt, 1, id)
        
        if sqlite3_step(stmt) == SQLITE_DONE{
            return true
        } else {
            return false
        }
        
    }

    
    
}


