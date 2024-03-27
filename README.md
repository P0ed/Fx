# Fx
[![codecov](https://codecov.io/gh/P0ed/Fx/branch/master/graph/badge.svg?token=6exeUP7sRY)](https://codecov.io/gh/P0ed/Fx)

This is a Swift framework providing a number of functions and types that I miss in Swift standard library.


## Types:
#### `Signal<A>`
The Signal is a stream of values over time
#### `Property<A>` and `MutableProperty<A>`
The Property is a value + signal with changes
#### `Promise<A>`
The Promise is an async version of Result. Promises can be used instead of completion handlers to avoid nested closures.
#### `Monoid`
Any type that has empty value and can be comined.

## Operators:
#### `§` — Function application `⌥+6`
#### `•` — Function composition `⌥+8`
#### `∑` — Prefix sum operator `⌥+W` 


## Functions:
#### `id`
Identity function same as `{ $0 }`
#### `const`
A constant function. Takes a value and returns a function that returns that value no matter what it is fed.
#### `weakify`
```swift
let f = weakify(self) { $0.handleEvent }
```
equals to
```swift
let f = { [weak self] in
	guard let self = self else { return }
	self.handleEvent($0)
}
```
#### `curry`
Currying takes a function of >1 parameter and returns a function of one parameter which returns a function of one parameter, and so on. That is, given `(A, B) -> C`, currying returns `A -> B -> C`.


## Integration
__⛔️ Carthage support is deprecated starting v3.0.0__. 
Install using Swift Package Manager
