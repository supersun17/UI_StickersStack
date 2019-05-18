//
//  Behavior.swift
//  UI-StickersStack
//
//  Created by Ming Sun on 5/12/19.
//  Copyright © 2019 Ming Sun. All rights reserved.
//

import Foundation

protocol ContentsMappable: AnyObject {
	var contentsMapping: [Int] { get set }
}

extension ContentsMappable {
	func rebuildContents(with size: Int) {
		contentsMapping.removeAll()
		for i in 0..<size {
			contentsMapping.append(i)
		}
	}
	func getContentsCount() -> Int {
		return contentsMapping.count
	}
	func getContent(at i: Int) -> Int {
		return contentsMapping[i]
	}
	func removeContent(at i: Int) {
		contentsMapping.remove(at: i)
	}
	func insertContent(at i: Int, _ contentIndex: Int) {
		contentsMapping.insert(contentIndex, at: i)
	}
}
