//
//  FetchUsersUseCase.swift
//  BankDemoApp
//
//  Created by David on 2026/4/22.
//
import Combine

protocol FetchUsersUseCase {
    func execute() -> AnyPublisher<[User], Error>
}

final class FetchUsersUseCaseImpl: FetchUsersUseCase {

    private let repository: UserRepository

    init(repository: UserRepository) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<[User], Error> {
        repository.fetchUsers()
    }
}
