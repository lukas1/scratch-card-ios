import SwiftUI

@propertyWrapper
struct RequiredEnvironment<Value>: DynamicProperty {
    @Environment private var value: Value?

    init(_ keyPath: KeyPath<EnvironmentValues, Value?>) {
        _value = Environment(keyPath)
    }

    var wrappedValue: Value {
        guard let value else {
            preconditionFailure("Required environment value not provided: \(Value.self)")
        }
        return value
    }
}
