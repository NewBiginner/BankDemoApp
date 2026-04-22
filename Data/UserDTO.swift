import Foundation

struct UserDTO: Decodable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let address: AddressDTO
    let phone: String
    let website: String
    let company: CompanyDTO
}

struct AddressDTO: Decodable {
    let street: String
    let suite: String
    let city: String
    let zipcode: String
    let geo: GeoDTO
}

struct GeoDTO: Decodable {
    let lat: String
    let lng: String
}

struct CompanyDTO: Decodable {
    let name: String
    let catchPhrase: String
    let bs: String
}

extension UserDTO {
    func toDomain() -> User {
        User(
            id: id,
            name: name,
            email: email,
            city: address.city
        )
    }
}
