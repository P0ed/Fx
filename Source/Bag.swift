//
//  Bag.swift
//  ReactiveCocoa
//
//  Created by Justin Spahr-Summers on 2014-07-10.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

/// A uniquely identifying token for removing a value that was inserted into a
/// Bag.
public final class RemovalToken {
	fileprivate var identifier: UInt?

	fileprivate init(identifier: UInt) {
		self.identifier = identifier
	}
}

/// An unordered, non-unique collection of values of type `Element`.
public struct Bag<Element> {
	fileprivate var elements: [BagElement<Element>] = []
	fileprivate var currentIdentifier: UInt = 0

	public init() {
	}

	/// Inserts the given value in the collection, and returns a token that can
	/// later be passed to removeValueForToken().
	public mutating func insert(_ value: Element) -> RemovalToken {
		let (nextIdentifier, overflow) = UInt.addWithOverflow(currentIdentifier, 1)
		if overflow {
			reindex()
		}

		let token = RemovalToken(identifier: currentIdentifier)
		let element = BagElement(value: value, identifier: currentIdentifier, token: token)

		elements.append(element)
		currentIdentifier = nextIdentifier

		return token
	}

	/// Removes a value, given the token returned from insert().
	///
	/// If the value has already been removed, nothing happens.
	public mutating func removeValueForToken(_ token: RemovalToken) {
		if let identifier = token.identifier {
			// Removal is more likely for recent objects than old ones.
			for i in elements.indices.reversed() {
				if elements[i].identifier == identifier {
					elements.remove(at: i)
					token.identifier = nil
					break
				}
			}
		}
	}

	/// In the event of an identifier overflow (highly, highly unlikely), this
	/// will reset all current identifiers to reclaim a contiguous set of
	/// available identifiers for the future.
	fileprivate mutating func reindex() {
		for i in elements.indices {
			currentIdentifier = UInt(i)

			elements[i].identifier = currentIdentifier
			elements[i].token.identifier = currentIdentifier
		}
	}
}

extension Bag: Collection {
	/// Returns the position immediately after the given index.
	///
	/// - Parameter i: A valid index of the collection. `i` must be less than
	///   `endIndex`.
	/// - Returns: The index value immediately after `i`.
	public func index(after i: Int) -> Int {
		return elements.index(after: i)
	}

	public typealias Index = Array<Element>.Index

	public var startIndex: Index {
		return elements.startIndex
	}

	public var endIndex: Index {
		return elements.endIndex
	}

	public subscript(index: Index) -> Element {
		return elements[index].value
	}
}

private struct BagElement<Value> {
	let value: Value
	var identifier: UInt
	let token: RemovalToken
}

extension BagElement: CustomStringConvertible {
	var description: String {
		return "BagElement(\(value))"
	}
}
