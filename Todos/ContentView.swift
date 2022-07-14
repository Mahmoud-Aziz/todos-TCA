//
//  ContentView.swift
//  Todos
//
//  Created by Mahmoud Aziz on 14/07/2022.
//

import SwiftUI
import ComposableArchitecture

struct Todo: Equatable, Identifiable {
    var description = ""
    var isComplete = false
    let id: UUID
}

enum TodoAction: Equatable {
    case checkboxTapped
    case textFieldChanged(String)
}

struct TodoEnviroment {
    
}

let todoReducer = Reducer<Todo, TodoAction, TodoEnviroment> { state, action, enviroment in
    switch action {
    case .checkboxTapped:
        state.isComplete.toggle()
        return .none
    case .textFieldChanged(let text):
        state.description = text
        return .none
    }
}

struct AppState: Equatable {
    var todos: [Todo] = []
}

enum AppAction: Equatable {
    case todo(index: Int, action: TodoAction)
    case addButtonTapped
    case todoDelayCompleted
}

struct AppEnviroment {
    var uuid: () -> UUID
    
}

let appReducer = Reducer<AppState, AppAction, AppEnviroment>.combine(
    todoReducer.forEach(
        state: \AppState.todos,
        action: /AppAction.todo(index:action:),
        environment: { _ in TodoEnviroment() }
    ),
    Reducer { state, action, enviroment in
        switch action {
        case .addButtonTapped:
            state.todos.insert(Todo(id: enviroment.uuid()), at: 0)
            return .none
            
        case .todo(index: _, action: .checkboxTapped):
            struct CancelDelayId: Hashable {}
            return Effect(value: AppAction.todoDelayCompleted)
                   .delay(for: 1, scheduler: DispatchQueue.main)
                   .eraseToEffect()
                   .cancellable(id: CancelDelayId(), cancelInFlight: true)
            
        case .todo(index: let index, action: let action):
            return .none
            
        case .todoDelayCompleted:
                state.todos = state.todos.enumerated().sorted { lhs, rhs in
                    (!lhs.element.isComplete && rhs.element.isComplete)
                    || lhs.offset < rhs.offset
                }.map(\.element)
            return .none
            }
        }
    )

struct ContentView: View {
    let store: Store<AppState, AppAction>
    
    var body: some View {
        NavigationView {
            WithViewStore(store) { viewStore in
                List {
                    ForEachStore(
                        store.scope(state: \.todos,action: AppAction.todo(index:action:)
                                   ),
                        content: TodoView.init(store: )
                    )
                }
                .navigationTitle("Todos")
                .navigationBarItems(trailing: Button("Add") {
                    viewStore.send(.addButtonTapped)
                } )
            }
        }
    }
}

struct TodoView: View {
    let store: Store<Todo, TodoAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                Button(action: { viewStore.send(.checkboxTapped) }) {
                    Image(systemName: viewStore.isComplete ? "checkmark.square" : "square")
                }
                .buttonStyle(PlainButtonStyle())
                
                TextField(
                    "untitled todo",
                    text: viewStore.binding(
                        get:  \.description ,
                        send: TodoAction.textFieldChanged
                    )
                )
            }
            .foregroundColor(viewStore.isComplete ? .gray : nil)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
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
                            isComplete: true,
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
