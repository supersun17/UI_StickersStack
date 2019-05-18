//
//  Stiker.swift
//  com.MingSun.Secretory
//
//  Created by Ming Sun on 3/27/19.
//

import UIKit

protocol StickerBehaviorDelegate: AnyObject {
	func boundryCheckThreshold() -> CGRect
	func sitckerDidMoveOutOfBoundry(_ sticker: Sticker)
}

class Sticker: TransformView {
	weak var contentView: UIView?
	weak var delegate: StickerBehaviorDelegate?
	var isBeingDragged: Bool = false
	var isExpended: Bool = false

	override init(frame: CGRect) {
		super.init(frame: frame)

		customeInit()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		customeInit()
	}

	private func customeInit() {
		setupGesture()
		layer.borderColor = UIColor.black.cgColor
		layer.borderWidth = 1
	}

	func attachContentView(_ contentView: UIView) {
		self.contentView = contentView
		addSubview(contentView)
		bringSubview(toFront: contentView)

		contentView.translatesAutoresizingMaskIntoConstraints = false
		let views = ["contentView" : contentView]
		var allConstraints: [NSLayoutConstraint] = []
		let constraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options: [], metrics: nil, views: views)
		let constraintsV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[contentView]|", options: [], metrics: nil, views: views)
		allConstraints.append(contentsOf: constraintsH)
		allConstraints.append(contentsOf: constraintsV)
		NSLayoutConstraint.activate(allConstraints)
	}

	func toggleExpending() {
		if isExpended {
			frame = savedState.frame
			transform = savedState.transform
		} else {
			saveCurrentState()
			transform = CGAffineTransform.identity
			frame = UIScreen.main.bounds
		}
	}
}

extension Sticker: UIGestureRecognizerDelegate {
	func setupGesture() {
		let pan = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan))
		pan.delegate = self
		addGestureRecognizer(pan)
	}

	@objc func handlePan(_ pan: UIPanGestureRecognizer) {
		switch pan.state {
		case .began:
			stopTransformAnimate()
			isBeingDragged = true
			break
		case .changed:
			let translation = pan.translation(in: superview)
			transform = CGAffineTransform.init(translationX: translation.x, y: translation.y)
			break
		case .ended:
			isBeingDragged = false
			if boundryCheck() {
				startTransformAnimate(with: savedState.transform)
			} else {
				delegate?.sitckerDidMoveOutOfBoundry(self)
			}
			break
		default:
			isBeingDragged = false
			break
		}
	}

	func boundryCheck() -> Bool {
		var center = CGPoint.init(x: (frame.minX + frame.maxX) / 2,
								  y: (frame.minY + frame.maxY) / 2)
		guard let boundryCheckThreshold = delegate?.boundryCheckThreshold() else { return true }
		center = convert(center, to: superview)
		return boundryCheckThreshold.contains(center)
	}
}

extension Sticker: PoolElementProtocol {
	func prepareForReuse() {
		contentView?.removeFromSuperview()
		reset()
		removeFromSuperview()
	}
}
