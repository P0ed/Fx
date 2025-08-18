# Fx
[![codecov](https://codecov.io/gh/P0ed/Fx/branch/master/graph/badge.svg?token=6exeUP7sRY)](https://codecov.io/gh/P0ed/Fx)

A Swift library providing functional programming utilities, reactive programming primitives, and asynchronous operations support.

## Overview

Fx is a lightweight, zero-dependency Swift library that brings functional programming concepts and reactive programming patterns to Swift ecosystem. It provides a comprehensive set of utilities for:

- **Functional Programming**: Higher-order functions, currying, composition, and more
- **Reactive Programming**: Signals for event streams and reactive data flow
- **Asynchronous Operations**: Promise-based async operations with modern Swift concurrency support
- **Utility Extensions**: Convenient extensions for common Swift types

## Features

### Functional Programming Utilities
- **Core Functions**: `id`, `const`, `curry`, `flip`, `compose`
- **Function Combinators**: Transform and combine functions with ease
- **Utility Functions**: `with`, `modify`, `transform` for cleaner code

### Reactive Programming
- **Signal**: Type-safe event streams with operators like `map`, `filter`, `merge`
- **Property**: Observable properties with automatic change notifications
- **Command**: Reactive command pattern implementation
- **Disposables**: Automatic resource management

### Asynchronous Operations
- **Promise**: Modern promise implementation with Swift concurrency support
- **Result Integration**: Seamless integration with Swift's Result type
- **Async/Await Support**: Bridge between callback-based and async/await patterns

### Extensions & Utilities
- **Optional Extensions**: Enhanced optional handling
- **Collection Extensions**: Functional operations on sequences
- **Timer Extensions**: Reactive timer utilities
- **KVO Extensions**: Simplified Key-Value Observing

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
.package(url: "https://github.com/P0ed/Fx.git", from: "4.0.0")
```

## Requirements

- iOS 14.0+ / macOS 12.0+ / watchOS 8.0+ / tvOS 14.0+
- Swift 6.1+
- Xcode 16.0+

## Key Features

### Reactive Programming

#### `Signal<A>` - Reactive Streams
```swift
let numbers = Signal<Int> { sink in
    // Emit values over time
    return timer.observe(sink)
}

let doubled = numbers
    .filter { $0 > 0 }
    .map { $0 * 2 }
    .throttled(0.1)
```

#### `Property<A>` & `MutableProperty<A>` - Reactive State
```swift
final class Model {
    // Exposes readonly observable state
    @MutableProperty
    private(set) var count = 0
}

// Automatic UI updates
let isEven: Property<Bool> = $count.map { $0 % 2 == 0 }
isEven.observe { isEven in
    button.isEnabled = isEven
}
```

### Functional Programming

#### Essential Functions
```swift
// Function composition
let nonEmpty = elements.filter(where: (!) • \.isEmpty • \.name)

// Currying for partial application
let add = curry(+)
let inc = add(1)
[1, 2, 3].map(inc) // [2, 3, 4]

// Mutation without introducing a variable in current scope
let newArray = modify(array) { $0.append(item) }
```

#### Operators
- `§` — Function application `⌥+6`
- `•` — Function composition `⌥+8`  
- `∑` — Monoid sum operator `⌥+W`

#### Sendable & Concurrency Support
```swift
// Thread-safe signals
let signal = Signal<String>(sendable: generator)

// Async/await integration  
let result = try await promise.get()
```

## Core Types

### Reactive Types
- **`Signal<A>`** - Stream of values over time with operators like `map`, `filter`, `merge`, `combineLatest`
- **`Property<A>`** - Current value + change notifications, perfect for UI binding
- **`MutableProperty<A>`** - Mutable reactive property with property wrapper support

### Functional Types
- **`Result<A, Error>`** - Enhanced with functional operators
- **`Monoid`** - Types that can be combined (strings, arrays, etc.)
- **`IO<A>`** - Controlled side effects
- **`Atomic<A>`** - Thread-safe value container

### Utility Types
- **`Disposable`** - Resource cleanup and subscription management
- **`Weak<A>`** - Weak reference wrapper
- **`Bag<A>`** - Efficient collection for callbacks

### From Promises to Async/Await
```swift
// Old Promise-based approach
func fetchData() -> Promise<Data> { ... }

// Modern async/await (recommended)
func fetchData() async throws -> Data { ... }

// Bridge when needed
let promise = Promise.async { try await fetchData() }

// And backwards
let data = try await promise.get()
```
