//
//  TodosTests.swift
//  TodosTests
//
//  Created by Mahmoud Aziz on 14/07/2022.
//

import XCTest
import ComposableArchitecture

@testable import Todos

class TodoTests: XCTestCase {
    func testCompletionTodo() {
        let store = TestStore(
            initialState: AppState(todos: [
                Todo(
                    description: "First",
                    isComplete: true,
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
                )
            ]),
            reducer: appReducer,
            environment: AppEnviroment(uuid: { UUID(uuidString: "DDDD-FFFF-HHHH-JJJJ-GGGFGFGFGFG")! } )
        )
        
        store.send(.todo(index: 0, action: .checkboxTapped)) {
            $0.todos[0].isComplete = false
            
        }
    }
    
    func testAddTodo() {
        let store = TestStore(
            initialState: AppState(),
            reducer: appReducer,
            environment: AppEnviroment(
                uuid: { UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")! }
            )
        )
        
        store.send(.addButtonTapped) {
                $0.todos = [
                    Todo(
                        description: "",
                        isComplete: false,
                        id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!
                    )
                ]
            }
    }
    
    func testTodoSorting() {
        let store = TestStore(
            initialState: AppState(
                todos: [
                    Todo(
                        description: "Milk",
                        isComplete: false, id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
                    ),
                    Todo(
                        description: "Eggs",
                        isComplete: false, id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
                    )  
                ]
            ),
            reducer: appReducer,
            environment: AppEnviroment(
                uuid: { fatalError("unimplemented") }
            )
        )
        
        store.send(.todo(index: 0, action: .checkboxTapped)) {
            $0.todos[0].isComplete = true
            $0.todos.swapAt(0, 1)
        }
        
    }
    
}
