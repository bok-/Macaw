import Swift_CAAnimation_Closure

class AnimationProducer {

	let sceneLayer: CALayer
	let animationCache: AnimationCache

	required init(layer: CALayer, animationCache: AnimationCache) {
		self.sceneLayer = layer
		self.animationCache = animationCache
		animationCache.sceneLayer = layer

	}

	public func addAnimation(animation: Animatable) {

		switch animation.type {
		case .Unknown:
			return
		case .AffineTransformation:
			addTransformAnimation(animation, sceneLayer: sceneLayer, animationCache: animationCache, completion: {
				if let next = animation.next {
					self.addAnimation(next)
				}
			})

		case .Opacity:
			addOpacityAnimation(animation, sceneLayer: sceneLayer, animationCache: animationCache, completion: {
				if let next = animation.next {
					self.addAnimation(next)
				}
			})
		case .Sequence:
			addAnimationSequence(animation)
		case .Combine:
			addCombineAnimation(animation)
		case .Empty:
			executeCompletion(animation)
		}
	}
	private func addAnimationSequence(animationSequnce: Animatable) {
		guard let sequence = animationSequnce as? AnimationSequence else {
			return
		}

		// Connecting animations
		for i in 0..<(sequence.animations.count - 1) {
			let animation = sequence.animations[i]
			animation.next = sequence.animations[i + 1]
		}

		// Completion
		if let completion = sequence.completion {
			let completionAnimation = EmptyAnimation(completion: completion)

			if let next = sequence.next {
				completionAnimation.next = next
			}

			sequence.animations.last?.next = completionAnimation
		} else {
			if let next = sequence.next {
				sequence.animations.last?.next = next
			}
		}

		// Launching
		if let firstAnimation = sequence.animations.first {

			self.addAnimation(firstAnimation)
		}
	}

	private func addCombineAnimation(combineAnimation: Animatable) {
		guard let combine = combineAnimation as? CombineAnimation else {
			return
		}

		// Looking for longest animation
		var longestAnimation: Animatable?
		combine.animations.forEach { animation in
			guard let longest = longestAnimation else {
				longestAnimation = animation
				return
			}

			if longest.getDuration() < animation.getDuration() {
				longestAnimation = animation
			}
		}

		// Attaching completion empty animation and potential next animation
		if let completion = combine.completion {
			let completionAnimation = EmptyAnimation(completion: completion)
			if let next = combine.next {
				completionAnimation.next = next
			}

			longestAnimation?.next = completionAnimation

		} else {
			if let next = combine.next {
				longestAnimation?.next = next
			}

		}

		combine.removeFunc = {
			combine.animations.forEach { animation in
				animation.removeFunc?()
			}
		}

		// Launching
		combine.animations.forEach { animation in
			self.addAnimation(animation)
		}
	}

	private func executeCompletion(emptyAnimation: Animatable) {
		emptyAnimation.completion?()
	}
}
