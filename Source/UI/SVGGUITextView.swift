import SwiftUI
#if os(OSX)
import AppKit
#else
import UIKit
#endif

#if os(OSX)
import AppKit
public typealias MColor = NSColor
public typealias MView = NSView
public typealias MRepresentable = NSViewRepresentable
public typealias MHostingController = NSHostingController
public typealias MFont = NSFont
#else
public typealias MColor = UIColor
public typealias MView = UIView
public typealias MRepresentable = UIViewRepresentable
public typealias MHostingController = UIHostingController
public typealias MFont = UIFont
#endif

public struct SVGGUITextView: View {
	@ObservedObject var model: SVGText

	public var body: some View {

		switch getLabelColor(model: model) {
		case _ as SVGLinearGradient, _ as SVGRadialGradient:
			let size = getLabelSize(model: model)
			StrokeTextLabel(model: model)
				.lineLimit(1)
				.alignmentGuide(.leading) { d in d[model.textAnchor] }
				.alignmentGuide(VerticalAlignment.top) { _ in size.height }
				.offset(x: -(model.stroke?.width ?? 0) / 2, y: (model.stroke?.width ?? 0) / 2)
				.position(x: 0, y: 0) // just to specify that positioning is global, actual coords are in transform
				.transformEffect(model.transform)
				.frame(alignment: .topLeading)
				.frame(minWidth: size.width, minHeight: size.height)
		case _ as SVGColor:
			if model.stroke?.width != nil {
				let size = getLabelSize(model: model)
				StrokeTextLabel(model: model)
					.lineLimit(1)
					.alignmentGuide(.leading) { d in d[model.textAnchor] }
					.alignmentGuide(VerticalAlignment.top) { _ in size.height }
					.offset(x: -(model.stroke?.width ?? 0) / 2, y: (model.stroke?.width ?? 0) / 2)
					.position(x: 0, y: 0) // just to specify that positioning is global, actual coords are in transform
					.transformEffect(model.transform)
					.frame(alignment: .topLeading)
					.frame(minWidth: size.width, minHeight: size.height)
			} else {
				if let fontSize = model.font?.size {
					let font = Font.custom(getFontName(model: model), size: fontSize)
					Text(model.text)
						.font(font)
						.lineLimit(1)
						.alignmentGuide(.leading) { d in d[model.textAnchor] }
						.alignmentGuide(VerticalAlignment.top) { d in d[VerticalAlignment.firstTextBaseline] }
						.apply(paint: model.fill)
						.position(x: 0, y: 0) // just to specify that positioning is global, actual coords
						.transformEffect(model.transform)
						.frame(alignment: .topLeading)
				} else {
					Text("")
				}
			}
		default:
			Text("")
		}
	}
}

#if os(OSX)
// You need this class because strokeLabel should be in top left corner,
// otherwise it will be moving by Y axis with window
class FlippedView: MView {
	override var isFlipped: Bool {
			return true
	}
}
#endif

private struct StrokeTextLabel: MRepresentable {

	@ObservedObject var model: SVGText

#if os(iOS)
	typealias UIViewType = MView

	func makeUIView(context: Context) -> MView {
		return getStrokeLabel()
	}

	func updateUIView(_ uiView: MView, context: Context) {
	}
#else
	func makeNSView(context: Context) -> MView {
		return getStrokeLabel()
	}

	func updateNSView(_ NSView: MView, context: Context) {
	}
#endif

	private func getStrokeLabel() -> MView {
		let strokeColor = model.stroke?.fill
		let fillColor = model.fill
#if os(OSX)
		let resultView = FlippedView()
#else
		let resultView = MView()
#endif

		// We use two switches because we need to put fill at first,
		// and then put above it stroke
		switch fillColor {
		case nil:
			break
		case let color as SVGColor:
			resultView.addSubview(createOneColorFillLabel(model: model, fillColor: color.toSwiftUI()))
		case let linearGradient as SVGLinearGradient:
			resultView.addSubview(createFillGradientLabel(model: model, gradient: linearGradient))
		case let radialGradient as SVGRadialGradient:
			resultView.addSubview(createRadialGradientFillLabel(model: model, gradient: radialGradient))
		default:
			break
		}

		switch strokeColor {
		case nil:
			break
		case let color as SVGColor:
			resultView.addSubview(createOneColorStrokeLabel(model: model, strokeColor: color.toSwiftUI()))
		case let linearGradient as SVGLinearGradient:
			resultView.addSubview(createGradientStrokeLabel(model: model, gradient: linearGradient))
		case let radialGradient as SVGRadialGradient:
			resultView.addSubview(createRadialGradientStrokeLabel(model: model, gradient: radialGradient))
		default:
			break
		}
		return resultView
	}

	private func createOneColorStrokeLabel(model: SVGText, strokeColor: Color) -> MView {
		guard let stroke = model.stroke else {
			return MView()
		}
		let attributedString = getStrokeAttributedString(model: model, strokeColor: strokeColor)
		var size = attributedString.boundingRect(with: .zero, options: [], context: nil)
		size = CGRect(x: 0, y: 0, width: size.width + stroke.width, height: size.height + stroke.width)
		let resultView = MView(frame: size)
#if os(OSX)
		let strokeTextLayer = getStrokeTextLayer(size: size, attributedString: attributedString)
		strokeTextLayer.bounds = getStrokeBounds(size: size, stroke: stroke)

		resultView.wantsLayer = true
		resultView.layer?.addSublayer(strokeTextLayer)
#else
		let strokeLabel = UILabel(frame: .zero)
		strokeLabel.attributedText = attributedString
		strokeLabel.frame = size
		strokeLabel.bounds = getStrokeBounds(size: size, stroke: stroke)

		resultView.addSubview(strokeLabel)
#endif
		return resultView
	}

	private func createOneColorFillLabel(model: SVGText, fillColor: Color) -> MView {
		let attributedString = getFillAttributedString(model: model, fillColor: fillColor)
		var size = attributedString.boundingRect(with: .zero, options: [], context: nil)
#if os(OSX)
		let strokeTextLayer = getStrokeTextLayer(size: size, attributedString: attributedString)

		let resultView = MView(frame: size)
		resultView.wantsLayer = true
		resultView.layer = strokeTextLayer
#else
		let strokeLabel = UILabel(frame: .zero)
		strokeLabel.attributedText = attributedString
		strokeLabel.textColor = UIColor(fillColor)

		size = CGRect(x: 0, y: 0, width: size.width, height: size.height)
		strokeLabel.frame = size

		let resultView = UIView(frame: size)

		resultView.addSubview(strokeLabel)
#endif
		return resultView
	}

	private func createGradientStrokeLabel(model: SVGText, gradient: SVGLinearGradient) -> MView {
		guard let stroke = model.stroke else {
			return MView()
		}
		let attributedString = getStrokeAttributedString(model: model, strokeColor: .black)
		var size = attributedString.boundingRect(with: .zero, options: [], context: nil)
		size = CGRect(x: 0, y: 0, width: size.width + stroke.width, height: size.height + stroke.width)
		let gradientLayer = getLinearGradientLayer(size: size, gradient: gradient)
		let resultView = MView(frame: size)

#if os(OSX)
		let strokeTextLayer = getStrokeTextLayer(size: size, attributedString: attributedString)
		strokeTextLayer.bounds = getStrokeBounds(size: size, stroke: stroke)

		gradientLayer.mask = strokeTextLayer
		resultView.wantsLayer = true
		resultView.layer = gradientLayer
#else
		let strokeLabel = UILabel(frame: .zero)
		strokeLabel.attributedText = attributedString

		strokeLabel.frame = size
		strokeLabel.bounds = getStrokeBounds(size: size, stroke: stroke)

		resultView.layer.addSublayer(gradientLayer)
		resultView.addSubview(strokeLabel)
		resultView.layer.mask = strokeLabel.layer
#endif
		return resultView
	}

	private func createFillGradientLabel(model: SVGText, gradient: SVGLinearGradient) -> MView {
		guard let fontSize = model.font?.size, let font = MFont(name: getFontName(model: model), size: fontSize)  else {
			return MView()
		}
#if os(OSX)
		let attributedString = getFillAttributedString(model: model, fillColor: .black)
		let size = attributedString.boundingRect(with: .zero, options: [], context: nil)
		let strokeTextLayer = getStrokeTextLayer(size: size, attributedString: attributedString)
		let gradientLayer = getLinearGradientLayer(size: size, gradient: gradient)

		let resultView = MView(frame: size)
		gradientLayer.mask = strokeTextLayer
		resultView.wantsLayer = true
		resultView.layer = gradientLayer
#else
		let label =  UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
		label.text = model.text
		label.font = font
		label.sizeToFit()
		let size = label.frame
		let resultView = MView(frame: size)

		resultView.addSubview(label)

		let gradientLayer = getLinearGradientLayer(size: size, gradient: gradient)
		resultView.layer.addSublayer(gradientLayer)
		resultView.layer.mask = label.layer
#endif
		return resultView
	}

	private func createRadialGradientStrokeLabel(model: SVGText, gradient: SVGRadialGradient) -> MView {
		guard let stroke = model.stroke else {
			return MView()
		}

		let attributedString = getStrokeAttributedString(model: model, strokeColor: .black)
		var size = attributedString.boundingRect(with: .zero, options: [], context: nil)
		size = CGRect(x: 0,
					  y: 0,
					  width: size.width + stroke.width,
					  height: size.height + stroke.width)
		let strokeTextLayer = getStrokeTextLayer(size: size, attributedString: attributedString)

		let gradientSize = CGRect(x: model.transform.tx,
								  y: model.transform.ty - size.height,
								  width: size.width,
								  height: size.height)

		let gradientView = MHostingController(rootView: RadialGradientView(gradient: gradient, size: gradientSize))
		gradientView.view.frame = size
		let resultView = MView(frame: size)

#if os(OSX)
		guard gradientView.view.layer != nil else { return resultView }
		gradientView.view.layer?.mask = strokeTextLayer
		resultView.addSubview(gradientView.view)
#else
		gradientView.view.layer.mask = strokeTextLayer
		resultView.layer.addSublayer(gradientView.view.layer)

#endif
		return resultView
	}

	private func createRadialGradientFillLabel(model: SVGText, gradient: SVGRadialGradient) -> MView {

		let attributedString = getFillAttributedString(model: model, fillColor: .black)
		let size = attributedString.boundingRect(with: .zero, options: [], context: nil)
		let strokeTextLayer = getStrokeTextLayer(size: size, attributedString: attributedString)
		// We make gradientSize like this because SVGRadialGradient method toSwiftUI uses global position of view
		let gradientSize = CGRect(x: model.transform.tx,
								  y: model.transform.ty - size.height,
								  width: size.width,
								  height: size.height)

		let gradientView = MHostingController(rootView: RadialGradientView(gradient: gradient, size: gradientSize))
		gradientView.view.frame = size
		let resultView = MView(frame: size)
#if os(OSX)
		guard gradientView.view.layer != nil else {return resultView}
		gradientView.view.layer?.mask = strokeTextLayer
#else
		gradientView.view.layer.mask = strokeTextLayer
#endif
		resultView.addSubview(gradientView.view)

		return resultView
	}

	private struct LinearGradientCoordinates {
		let x1: CGFloat
		let y1: CGFloat
		let x2: CGFloat
		let y2: CGFloat
		let stops: [CGFloat]
	}

	private func getLinearGradientCoordinates(rect: CGRect, gradient: SVGLinearGradient) -> LinearGradientCoordinates {
		let stops = gradient.stops.map { stop in
			stop.offset
		}
		let x1 = gradient.userSpace ? (gradient.x1 - rect.minX) / rect.size.width: gradient.x1
		let y1 = gradient.userSpace ? (gradient.y1 - rect.minY) / rect.size.height: gradient.y1
		let x2 = gradient.userSpace ? (gradient.x2 - rect.minX) / rect.size.width: gradient.x2
		let y2 = gradient.userSpace ? (gradient.y2 - rect.minY) / rect.size.height: gradient.y2
		return LinearGradientCoordinates(x1: x1, y1: y1, x2: x2, y2: y2, stops: stops)
	}

	private func getGradientLoactions(stops: [CGFloat]) -> [NSNumber] {
		var locations: [NSNumber] = []
		for stop in stops {
			locations.append(stop as NSNumber)
		}
		return locations
	}

	private struct RadialGradientView: View {
		let gradient: SVGRadialGradient
		let size: CGRect
		init(gradient: SVGRadialGradient, size: CGRect) {
			self.gradient = gradient
			self.size = size
		}

		var body: some View {
			let minimum = min(size.width, size.height)
			let width = size.width
			let height = size.height
			let userSpace = gradient.userSpace
			gradient.toSwiftUI(rect: size)
				.scaleEffect(CGSize(width: userSpace ? 1: width/minimum,
									height: userSpace ? 1: height/minimum))
		}
	}

	private func getGradientColors(gradient: SVGGradient) -> [MColor] {
		var NSColorArr: [MColor] = []
		_ = gradient.stops.map { stop in
			NSColorArr.append(MColor(stop.color.toSwiftUI()))
		}
		return NSColorArr
	}

	private func getLinearGradientLayer(size: CGRect, gradient: SVGLinearGradient) -> CAGradientLayer {
		let gradientLayer = CAGradientLayer()
		gradientLayer.frame = size
		let gradientColors = getGradientColors(gradient: gradient)
		gradientLayer.colors = [gradientColors[0].cgColor, gradientColors[1].cgColor]
		let gradientCoordinates = getLinearGradientCoordinates(rect: size, gradient: gradient)
		gradientLayer.locations = getGradientLoactions(stops: gradientCoordinates.stops)
		gradientLayer.startPoint = CGPoint(x: gradientCoordinates.x1, y: gradientCoordinates.y1)
		gradientLayer.endPoint = CGPoint(x: gradientCoordinates.x2, y: gradientCoordinates.y2)
		return gradientLayer
	}

}

private func getLabelColor (model: SVGText) -> SVGPaint {
	if let strokeColor = model.stroke?.fill {
		return strokeColor
	} else if let fillColor = model.fill {
		return fillColor
	}
	return SVGPaint()
}

// We need this method because you cant get height of view in any other way
private func getLabelSize(model: SVGText) -> CGRect {
	if let width = model.stroke?.width {
		let attributedString = getStrokeAttributedString(model: model, strokeColor: .black)
		var size = attributedString.boundingRect(with: .zero, options: [], context: nil)
		size = CGRect(x: 0, y: 0, width: size.width + width, height: size.height + width)

		return size
	} else {
		let attributedString = getFillAttributedString(model: model, fillColor: .black)
		let size = attributedString.boundingRect(with: .zero, options: [], context: nil)

		return size
	}
}

private func getStrokeAttributedString(model: SVGText, strokeColor: Color) -> NSAttributedString {
	guard let stroke = model.stroke, let font = MFont(name: getFontName(model: model),
													  size: model.font!.size) else {
		return NSMutableAttributedString()
	}

	let strokeTextAttributes = [
		NSAttributedString.Key.strokeColor: MColor(strokeColor),
		NSAttributedString.Key.foregroundColor: MColor.clear,
		// you need this conversion because NSAttributedString.Key.strokeWidth is percent of font size
		NSAttributedString.Key.strokeWidth: stroke.width / font.pointSize * 100,
		NSAttributedString.Key.font: MFont(name: getFontName(model: model),
											size: font.pointSize) ?? .systemFont(ofSize: font.pointSize)
	] as [NSAttributedString.Key: Any]

	let attributedString = NSAttributedString(string: model.text,
											  attributes: strokeTextAttributes as [NSAttributedString.Key: Any]?)
	return attributedString
}

private func getFillAttributedString(model: SVGText, fillColor: Color) -> NSAttributedString {
	guard let font =  model.font else {
		return NSMutableAttributedString()
	}
#if os(OSX)
	let strokeTextAttributes = [
		NSAttributedString.Key.font: NSFont(name: getFontName(model: model), size: font.size) ?? .systemFont(ofSize: 15),
		NSAttributedString.Key.foregroundColor: NSColor(fillColor)
	] as [NSAttributedString.Key: Any]

#else
	let strokeTextAttributes = [
		NSAttributedString.Key.font: UIFont(name: getFontName(model: model), size: font.size) ?? .systemFont(ofSize: 15),
		NSAttributedString.Key.foregroundColor: UIColor(fillColor)
	] as [NSAttributedString.Key: Any]
#endif
	let attributedString = NSAttributedString(string: model.text,
											  attributes: strokeTextAttributes as [NSAttributedString.Key: Any]?)
	return attributedString
}

private func getFontName(model: SVGText) -> String {
	let separator = ","
	let fontString = model.font?.name
	let fonts = fontString?.components(separatedBy: separator)
	return fonts?[0] ?? ""
}

private func getStrokeBounds(size: CGRect, stroke: SVGStroke) -> CGRect {
#if os(OSX)
	return CGRect(x: -stroke.width,
		   y: stroke.width,
		   width: size.width + stroke.width,
		   height: size.height + stroke.width)
#else
	return CGRect(x: stroke.width,
		   y: stroke.width,
		   width: size.width + stroke.width,
		   height: size.height + stroke.width)
#endif
}

private func getStrokeTextLayer(size: CGRect, attributedString: NSAttributedString) -> CATextLayer {
	let strokeTextLayer = CATextLayer()
	strokeTextLayer.string = attributedString
	strokeTextLayer.frame = size
	return strokeTextLayer
}
