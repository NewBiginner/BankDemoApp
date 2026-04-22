//
//  UserRepositoryImpl.swift
//  BankDemoApp
//
//  Created by David on 2026/4/22.
//

import Foundation
import Combine

final class UserRepositoryImpl: UserRepository {

    func fetchUsers() -> AnyPublisher<[User], Error> {
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")!

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [UserDTO].self, decoder: JSONDecoder())
            .map { $0.map { $0.toDomain() } }
            .eraseToAnyPublisher()
    }
}
