# BankDemoApp

BankDemoApp is an iOS application built with Swift, UIKit, and Combine.  
The project implements a remote-data-driven user list with clear separation between UI rendering, business flow, and data access.

The codebase is intentionally small, but it is structured in a way that reflects how this kind of feature would usually evolve in a product codebase: networking is isolated, API response models do not leak into the UI, and the ViewController stays focused on UIKit rendering instead of request orchestration.

## Project Overview

BankDemoApp fetches user data from a remote API and presents it in a `UITableView`.

The project is organized around three layers: Presentation, Domain, and Data. Each layer has a focused responsibility, which keeps the feature easier to adjust when UI requirements change, API contracts evolve, or the data source needs to be replaced.

The current implementation focuses on:

- Keeping UIKit code separate from data-fetching logic
- Using a UseCase to represent the user-list loading flow
- Defining repository contracts in the Domain layer
- Mapping API DTOs into Domain entities before exposing data to the app
- Using Combine to coordinate loading, error, and data updates

This structure avoids placing networking, decoding, and UI state transitions directly inside the ViewController.

## Features

### User List Presentation

The app renders user data in a `UITableView`.  
The table view receives cell view models that are already prepared for display, so the ViewController only needs to bind output data and update the UI.

This keeps formatting decisions out of the cell configuration path and makes the list easier to adjust when the display requirement changes.

### Remote Data Integration

User data is loaded from a public REST API using `URLSession` with Combine.  
The raw response is decoded into DTOs in the Data layer, then converted into Domain entities before reaching the ViewModel.

This keeps the API response shape isolated from the rest of the app, so changes in the remote contract can be handled close to the integration boundary.

### Loading and Error State Handling

Loading and error states are handled as part of the ViewModel output.  
The ViewController subscribes to these outputs instead of owning request state directly.

All UI-facing streams are delivered on the main thread before being consumed by UIKit.

### Replaceable Data Source

The feature depends on a repository protocol rather than a concrete implementation.  
In practice, this makes it possible to replace the remote repository with a mock, cache-backed, or local data source without changing the ViewModel or UseCase.

## Why Clean Architecture & Combine

This project uses Clean Architecture because even a small data-driven feature benefits from clear ownership boundaries.

In a UIKit app, ViewControllers can easily accumulate networking, decoding, state handling, and UI rendering responsibilities. Separating the feature into Presentation, Domain, and Data keeps those responsibilities explicit and reduces coupling between UI code and API details.

Combine is used to model the asynchronous nature of the feature. The ViewModel exposes state as streams, including user data, loading state, and error state. This keeps the binding between ViewModel and ViewController predictable while preserving UIKit as the UI framework.

The main benefits are:

- ViewModels can be tested with repository mocks
- API response changes are handled in the Data layer
- Domain entities stay independent from API DTOs
- Data source implementations can be replaced through dependency injection
- UI state updates are centralized in the ViewModel output

## Trade-offs & Design Decisions

Clean Architecture introduces extra layers, which can feel heavy for a small feature like a simple user list. There is more indirection compared with placing the API call directly in the ViewController, and the project needs additional types such as UseCase, Repository protocol, DTO, and Domain entity.

That cost is intentional here.

The purpose of this structure is not to optimize for the fewest files, but to keep responsibilities stable as the feature changes. For example, if the API response changes, the update should stay in the Data layer. If the UI display format changes, the update should stay in Presentation. If the data source changes from remote API to mock or cache, the UseCase and ViewModel should not need to know.

In a team setting, this also makes ownership clearer. UI changes, API integration changes, and business-flow changes can be reviewed independently without repeatedly touching the same ViewController. As the feature grows, that separation helps keep code review smaller and reduces regression risk.

For a small feature, this is a trade-off between simplicity and long-term maintainability. In this project, the trade-off is reasonable because the architecture demonstrates how the same feature could scale without rewriting the core flow.

## Architecture

The project follows a simplified Clean Architecture structure:

```text
Presentation -> Domain <- Data
```

The dependency direction points inward.  
Presentation depends on Domain contracts, and Data implements Domain-defined abstractions.

### Presentation Layer

The Presentation layer owns UIKit rendering and user-facing state.

Responsibilities:

- Render the user list with `UITableView`
- Bind ViewModel outputs to UI updates
- Trigger loading through ViewModel input
- Convert Domain entities into cell-level presentation models
- Keep UI updates on the main thread

Key files:

```text
Presentation/UserViewController.swift
Presentation/UserViewModel.swift
Presentation/UserCellViewModel.swift
```

### Domain Layer

The Domain layer defines the app-level contract for the user-list feature.

Responsibilities:

- Define the `User` entity used by the app
- Define repository protocols
- Define the UseCase for fetching users
- Keep business-facing flow independent from networking and DTO details

Key files:

```text
Domain/User.swift
Domain/UserRepository.swift
Domain/FetchUsersUseCase.swift
```

### Data Layer

The Data layer owns API integration and external data transformation.

Responsibilities:

- Perform the remote request
- Decode JSON into DTOs
- Map DTOs into Domain entities
- Provide the concrete repository implementation

Key files:

```text
Data/UserDTO.swift
Data/UserRepositoryImpl.swift
```

## Combine Data Flow

The ViewModel uses an Input / Output interface:

```swift
struct Input {
    let loadTrigger: AnyPublisher<Void, Never>
}

struct Output {
    let users: AnyPublisher<[UserCellViewModel], Never>
    let isLoading: AnyPublisher<Bool, Never>
    let error: AnyPublisher<String?, Never>
}
```

Data flow:

```text
ViewController
    -> UserViewModel.Input
    -> FetchUsersUseCase
    -> UserRepository
    -> UserRepositoryImpl
    -> URLSession dataTaskPublisher
    -> UserDTO
    -> User
    -> UserCellViewModel
    -> UITableView
```

The ViewModel coordinates request triggering, loading state, error handling, and Domain-to-Presentation mapping.  
The ViewController remains passive and only reacts to output changes.

This keeps Combine subscription handling close to the UI boundary while keeping networking and decoding details out of the ViewController.

## Folder Structure

```text
BankDemoApp
├── BankDemoApp
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── ViewController.swift
│   ├── Info.plist
│   └── Assets.xcassets
│
├── Presentation
│   ├── UserViewController.swift
│   ├── UserViewModel.swift
│   └── UserCellViewModel.swift
│
├── Domain
│   ├── User.swift
│   ├── UserRepository.swift
│   └── FetchUsersUseCase.swift
│
├── Data
│   ├── UserDTO.swift
│   └── UserRepositoryImpl.swift
│
├── BankDemoAppTests
└── BankDemoAppUITests
```

## API

The project uses JSONPlaceholder as a public fake REST API for stable sample data:

```text
https://jsonplaceholder.typicode.com/users
```

The API response is treated as an external contract and is isolated from the app through DTO mapping.

## Technical Notes

- Repository abstraction is defined in the Domain layer.
- Concrete repository implementation lives in the Data layer.
- API DTOs are not exposed to Presentation or Domain.
- ViewModel outputs are delivered on the main thread before UIKit consumes them.
- `SceneDelegate` acts as the composition root and wires dependencies together.

## Future Improvements

The current implementation focuses on architecture and data flow. Practical next steps include:

- Add ViewModel unit tests for loading, success, and failure states
- Add a mock repository for deterministic tests
- Add visible loading and error UI
- Validate HTTP status codes before decoding
- Extract API endpoint configuration
- Introduce an API client abstraction if more endpoints are added

## Future Improvements

- Introduce pagination for handling larger datasets
- Add local caching to support offline scenarios
- Add unit tests for UseCase and ViewModel layers
- Evaluate async/await as an alternative to Combine in future iterations
