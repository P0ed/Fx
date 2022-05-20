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
```swift
User.logIn(username, password).flatMap { user in
    Posts.fetchPosts(user)
}.onSuccess { posts in
    // do something with the user's posts
}.onFailure { error in
    // either logging in or fetching posts failed
}
```

##### Callbacks
You can be informed of the result of a Promise by registering callbacks: `onComplete`, `onSuccess` and `onFailure`. The order in which the callbacks are executed upon completion of the promise is not guaranteed, but it is guaranteed that the callbacks are executed serially. It is not safe to add a new callback from within a callback of the same promise.

##### Providing promises
A Promise is designed to be read-only, except for the site where the Promise is created. This is achieved via an initialiser on Promise that takes a closure, the completion scope, in which you can complete the Promise. The completion scope has one parameter that is also a closure which is invoked to set the result in the Promise.

```swift
let promise = Promise<Int> { resolve in
	resolve(.success(42))
}
```
or
```swift
let (promise, resolve) = Promise<Int>.pending()
resolve(.success(42))
```

##### Default Threading Model
A lot of the methods on Promise accept an optional execution context and a block, e.g. onSuccess, map, recover and many more. The block is executed (when the promise is completed) in the given execution context, which in practice is a GCD queue. When the context is not explicitly provided, the following rules will be followed to determine the execution context that is used:

* if the method is called from the main thread, the block is executed on the main queue
* if the method is not called from the main thread, the block is executed on a global queue

##### Custom execution contexts
The default threading behavior can be overridden by providing explicit execution contexts. You can choose from any of the built-in contexts or easily create your own.


## Operators:
#### `§` — Function application `⌥+6`
#### `•` — Function composition `⌥+8`


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
