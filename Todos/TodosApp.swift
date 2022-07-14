//
//  TodosApp.swift
//  Todos
//
//  Created by Mahmoud Aziz on 14/07/2022.
//

import SwiftUI
import ComposableArchitecture

@main
struct TodosApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: Store(
                    initialState: AppState(
                    todos: [
                Todo(
                    description: "First",
                    isComplete: false,
                    id: UUID()
                ),
                Todo(
                    description: "Second",
                    isComplete: false,
                    id: UUID()
                ),
                Todo(
                    description: "Third",
                    isComplete: false,
                    id: UUID()
                )
            ]
          ),
          reducer: appReducer,
                    environment: AppEnviroment(uuid: UUID.init)))
        }
    }
}
