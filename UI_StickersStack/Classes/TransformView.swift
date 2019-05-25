//
//  TransformView.swift
//  com.MingSun.Secretory
//
//  Created by Ming Sun on 3/29/19.
//

import UIKit

struct TransformViewState {
	let transform: CGAffineTransform
	let frame: CGRect
	let position: CGPoint

	init(with transform: CGAffineTransform, frame: CGRect, position: CGPoint) {
		self.transform = transform
		self.frame = frame
		self.position = position
	}
}

class TransformView: UIView {
	var savedState: TransformViewState!
	var animator: UIViewPropertyAnimator?
	var duration: TimeInterval = 0.75

	func saveCurrentState() {
		savedState = TransformViewState.init(with: transform, frame: frame, position: layer.position)
	}

	func startTransformAnimate(with transform: CGAffineTransform) {
		animator = UIViewPropertyAnimator.init(duration: duration, curve: .easeOut) {
			self.transform = transform
		}
		animator?.startAnimation()
	}

	func stopTransformAnimate() {
		animator?.stopAnimation(true)
	}

	func reset() {
		if !transform.isIdentity {
			transform = CGAffineTransform.identity
		}
		if layer.anchorPoint != CGPoint.init(x: 0.5, y: 0.5) {
			moveAnchorPointToCenter()
		}
	}

	/**
	Swing, anchor at view's top left
	- Parameters:
		degree: ranging from 0.00 - 1.00, will be scaled into 0 - 2pi
	- Returns: void
	**/
	func swing(_ degree: CGFloat) {
		moveAnchorPointToTopLeft()
		let rotation = -CGFloat(degree * CGFloat.pi)
		let rotTransform = CGAffineTransform.init(rotationAngle: rotation)
		if transform.isIdentity {
			transform = rotTransform
		} else {
			transform.concatenating(rotTransform)
		}
		saveCurrentState()
	}

	/**
	Swing, anchor at view's top left
	- Parameters:
		h: horizontal distance
		v: vertical distance
	- Returns: void
	**/
	func translate(h: CGFloat, v: CGFloat) {
		let posTransform = CGAffineTransform.init(translationX: h,
												  y: v)
		transform = posTransform
	}

	/**
	Swing, anchor at view's top left
	- Parameters:
		degree: ranging from 0.00 - 1.00, will be scaled into 0 - 1.0
	- Returns: void
	**/
	func scale(_ degree: CGFloat) {
		let sclTransform = CGAffineTransform.init(scaleX: CGFloat(1.0 - degree),
												  y: CGFloat(1.00 - degree))
		transform = sclTransform
	}

	func moveAnchorPointToTopLeft() {
		let origin = frame.origin
		layer.anchorPoint = CGPoint.init(x: 0, y: 0)
		layer.position = origin
	}

	func moveAnchorPointToCenter() {
		let center = CGPoint.init(x: (frame.minX + frame.maxX) / 2,
								  y: (frame.minY + frame.maxY) / 2)
		layer.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
		layer.position = center
	}
}
