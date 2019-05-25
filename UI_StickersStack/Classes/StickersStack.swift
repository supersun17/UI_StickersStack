//
//  StickersStack.swift
//  com.MingSun.Secretory
//
//  Created by Ming Sun on 3/28/19.
//

import UIKit

public protocol StickersStackDataSource: AnyObject {
	func numberOfStickers() -> Int
	func contentViewForSticker(at index: Int) -> UIView
}

public class StickersStack: UIView, ContentsMappable {
	public weak var dataSource: StickersStackDataSource?

	public typealias StickerOffset = (h: CGFloat, v: CGFloat)
	public var stickerOffset: StickerOffset = (h: CGFloat(10), v: CGFloat(10))
	var stickerSize: CGSize {
		let stackSize = bounds
		let defaultSize = (w: stackSize.width - CGFloat(maxVisibleStickers) * stickerOffset.h * 2,
						   h: stackSize.height - CGFloat(maxVisibleStickers) * stickerOffset.v)
		return CGSize.init(width: defaultSize.w, height: defaultSize.h)
	}
	public var stickerSwipeBoundry: CGFloat = 0.75
	public var stickerAniamtionDuration: TimeInterval = 0.75
	public var stickerReformAnimationDuration: TimeInterval = 0.3

	/**
	stickers array is used as a stack, consider it: [bottom,.....,top]
	**/
	private let stickersPool = ElementsPool<Sticker>(with: { return Sticker() })
	private var stickers: [Sticker] = []
	var contentsMapping: [Int] = []
	public var maxVisibleStickers: Int = 5

	public override func layoutSubviews() {
		super.layoutSubviews()

		redoStickers()
	}
}

// ******** StickerPresentation related ********
extension StickersStack: StickerBehaviorDelegate {
	public func reloadStack() {
		guard let newCount = dataSource?.numberOfStickers(), newCount != 0 else { return }
		rebuildContents(with: newCount)
		rebuildContent()
	}

	public func addNewSticker() {
		appendContent(stickers.count)
		var newSticker: Sticker!
		if stickers.count >= maxVisibleStickers {
			newSticker = stickers.removeFirst()
			newSticker.prepareForReuse()
			setupSticker(newSticker, at: getContentsCount() - 1)
		} else {
			newSticker = addSticker(at: getContentsCount() - 1)
		}
		addNewVisibleStickerToTop(newSticker)
		redoStickers()
	}

	private func rebuildContent() {
		removeAll()
		let endIndex = getContentsCount() - 1
		let startIndex = endIndex - min(getContentsCount(), maxVisibleStickers) + 1
		for i in startIndex...endIndex {
			let sticker = addSticker(at: i)
			addNewVisibleStickerToTop(sticker)
		}
		redoStickers()
	}

	func addSticker(at i: Int) -> Sticker {
		let sticker = stickersPool.draw()
		setupSticker(sticker, at: i)
		return sticker
	}

	private func setupSticker(_ sticker: Sticker, at i: Int) {
		sticker.duration = stickerAniamtionDuration
		sticker.delegate = self
		addSubview(sticker)
		sticker.frame = getNewStickerRect()
		if let contentView = dataSource?.contentViewForSticker(at: getContent(at: i)) {
			sticker.attachContentView(contentView)
		}
	}

	private func getNewStickerRect() -> CGRect {
		let size = stickerSize
		let minX = (bounds.width - size.width) / 2
		let minY = bounds.height - size.height

		return CGRect.init(x: minX, y: minY, width: size.width, height: size.height)
	}

	func addNewVisibleStickerToTop(_ sticker: Sticker) {
		stickers.append(sticker)
		bringSubview(toFront: sticker)
	}

	func newVisibleStickerAddedToBack(_ sticker: Sticker) {
		stickers.insert(sticker, at: 0)
		sendSubview(toBack: sticker)
	}

	func removeSticker(at i: Int) {
		let startIndex = getContentsCount() - stickers.count
		let sticker = stickers.remove(at: i)
		stickersPool.release(sticker)
		removeContent(at: startIndex + i)
		let next = getContentsCount() - 1 - stickers.count
		if next >= 0 {
			let sticker = addSticker(at: next)
			newVisibleStickerAddedToBack(sticker)
		} else {
			redoTransform()
		}
	}

	func removeAll() {
		for (i,s) in stickers.enumerated().reversed() {
			stickers.remove(at: i)
			stickersPool.release(s)
		}
	}

	func boundryCheckThreshold() -> CGRect {
		return CGRect.init(x: frame.width * stickerSwipeBoundry / 2,
						   y: frame.height * stickerSwipeBoundry / 2,
						   width: frame.width * stickerSwipeBoundry,
						   height: frame.height * stickerSwipeBoundry)
	}

	func sitckerDidMoveOutOfBoundry(_ sticker: Sticker) {
		for (i,s) in stickers.enumerated() {
			if s === sticker {
				removeSticker(at: i)
				break
			}
		}
	}
}

// ******** Animation related ********
extension StickersStack {
	func redoStickers() {
		redoFrame()
		redoTransform()
	}

	private func redoFrame() {
		for s in stickers {
			if !s.isBeingDragged {
				s.reset()
				s.frame = getNewStickerRect()
			}
		}
	}

	private func redoTransform() {
		for (i,s) in stickers.enumerated() {
			if !s.isBeingDragged {
				s.swing(CGFloat(stickers.count - 1 - i) / 100)
			}
		}
	}
}
