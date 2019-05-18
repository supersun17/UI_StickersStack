//
//  ElementsPool.swift
//  com.MingSun.Secretory
//
//  Created by Ming Sun on 5/1/19.
//

import UIKit

protocol PoolElementProtocol {
	func prepareForReuse()
}

class ElementsPool<T: PoolElementProtocol> {
	private var elementContainer: [T] = []
	private let factory: () -> T

	init(with factory: @escaping () -> T) {
		self.factory = factory
	}

	func draw() -> T {
		if !elementContainer.isEmpty {
			return elementContainer.removeLast()
		} else {
			return factory()
		}
	}

	func release(_ element: T) {
		element.prepareForReuse()
		elementContainer.append(element)
	}
}
