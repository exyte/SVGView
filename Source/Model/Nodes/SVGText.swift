import SwiftUI

public class SVGText: SVGNode, ObservableObject {

	@Published public var text: String
	@Published public var font: SVGFont?
	@Published public var fill: SVGPaint?
	@Published public var stroke: SVGStroke?
	@Published public var textAnchor: HorizontalAlignment = .leading

	public init(text: String, font: SVGFont? = nil, fill: SVGPaint? = SVGColor.black, stroke: SVGStroke? = nil, textAnchor: HorizontalAlignment = .leading, transform: CGAffineTransform = .identity, opaque: Bool = true, opacity: Double = 1, clip: SVGUserSpaceNode? = nil, mask: SVGNode? = nil) {
		self.text = text
		self.font = font
		self.fill = fill
		self.stroke = stroke
		self.textAnchor = textAnchor
		super.init(transform: transform, opaque: opaque, opacity: opacity, clip: clip, mask: mask)
	}

	override func serialize(_ serializer: Serializer) {
		serializer.add("text", text).add("font", font).add("textAnchor", textAnchor)
		fill?.serialize(key: "fill", serializer: serializer)
		serializer.add("stroke", stroke)
		super.serialize(serializer)
	}

	public func contentView() -> some View {
		SVGGUITextView(model: self)
	}
}

struct SVGTextView: View {

	@ObservedObject var model: SVGText

	public var body: some View {
		if let stroke = model.stroke, let fill = model.fill {
			ZStack {
				// TODO: just a temporary fix, should be replaced with a better solution
				let hw = stroke.width / 2
				filledText(fill: stroke.fill).offset(x: hw, y: hw)
				filledText(fill: stroke.fill).offset(x: -hw, y: -hw)
				filledText(fill: stroke.fill).offset(x: -hw, y: hw)
				filledText(fill: stroke.fill).offset(x: hw, y: -hw)
				filledText(fill: fill)
			}
		} else {
			filledText(fill: model.fill)
		}
	}

	private func filledText(fill: SVGPaint?) -> some View {
		Text(model.text)
			.font(model.font?.toSwiftUI())
			.lineLimit(1)
			.alignmentGuide(.leading) { d in d[model.textAnchor] }
			.alignmentGuide(VerticalAlignment.top) { d in d[VerticalAlignment.firstTextBaseline] }
			.position(x: 0, y: 0) // just to specify that positioning is global, actual coords are in transform
			.apply(paint: fill)
			.transformEffect(model.transform)
			.frame(alignment: .topLeading)
	}
}

#if os(OSX)
import AppKit

struct SVGGUITextView: View {
	@ObservedObject var model: SVGText

	var body: some View {

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
				Text(model.text)
					.font(model.font?.toSwiftUI())
					.lineLimit(1)
					.alignmentGuide(.leading) { d in d[model.textAnchor] }
					.alignmentGuide(VerticalAlignment.top) { d in d[VerticalAlignment.firstTextBaseline] }
					.apply(paint: model.fill)
					.position(x: 0, y: 0) // just to specify that positioning is global, actual coords
					.transformEffect(model.transform)
					.frame(alignment: .topLeading)
					.minimumScaleFactor(0.3)
			}
		default:
			Text("")
		}
	}
}

// You need this class because strokeLabel should be in top left corner, otherwise it will be moving by Y axis with window
class FlippedView: NSView {
	override var isFlipped: Bool {
		get {
			return true
		}
	}
}

struct StrokeTextLabel: NSViewRepresentable {
	@ObservedObject var model: SVGText

	func makeNSView(context: Context) -> NSView {
		return getStrokeLabel()
	}

	func updateNSView(_ NSView: NSView, context: Context) {
	}

	private func getStrokeLabel() -> NSView {
		let strokeColor = model.stroke?.fill
		let fillColor = model.fill
		let resultView = FlippedView()

		//we use two switches because we need to put fill at first, and then put above it stroke
		switch fillColor {
		case nil:
			break
		case let color as SVGColor:
			resultView.addSubview(createOneColorFillLabel(model: model, kitColor: color.toSwiftUI()))
		case let linearGradient as SVGLinearGradient:
			resultView.addSubview(createFilledGradientLabel(model: model, gradient: linearGradient))
		case let radialGradient as SVGRadialGradient :
			break
			//TODO: add radialGradientCase
		default:
			break
		}

		switch strokeColor {
		case nil:
			break
		case let color as SVGColor:
			resultView.addSubview(createOneColorStrokeLabel(model: model, kitColor: color.toSwiftUI()))
		case let linearGradient as SVGLinearGradient:
			resultView.addSubview(createGradientStrokeLabel(model: model, gradient: linearGradient))
		case let radialGradient as SVGRadialGradient :
			break
			//TODO: add radialGradientCase
		default:
			break
		}
		return resultView
	}

	private func createOneColorStrokeLabel(model: SVGText, kitColor: Color) -> NSView {
		guard let stroke = model.stroke, let font = model.font else {
			return NSView()
		}
		let strokeTextAttributes = [
			NSAttributedString.Key.strokeColor : NSColor(kitColor),
			NSAttributedString.Key.strokeWidth : stroke.width / font.size * 100, // you need this conversion because NSAttributedString.Key.strokeWidth is percent of font size
			NSAttributedString.Key.font : NSFont(name: getLabelFont(model: model), size: font.size) ?? .systemFont(ofSize: 15)
		] as [NSAttributedString.Key : Any]

		let strokeTextLayer = CATextLayer()
		let attributedString = NSAttributedString(string: model.text,
												  attributes: strokeTextAttributes as [NSAttributedString.Key : Any]?)
		strokeTextLayer.string = attributedString
		var size =  attributedString.boundingRect(with: .zero, options: [], context: nil)
		size = CGRect(x: 0, y: 0, width: size.width + stroke.width, height: size.height + stroke.width)
		strokeTextLayer.frame = size

		let resultView = NSView(frame: size)
		strokeTextLayer.bounds = CGRect(x: -stroke.width, y: stroke.width, width: size.width + stroke.width, height: size.height + stroke.width)
		resultView.wantsLayer = true
		resultView.layer?.addSublayer(strokeTextLayer)

		return resultView
	}

	private func createOneColorFillLabel(model: SVGText, kitColor: Color) -> NSView {
		guard let font = model.font else {
			return NSView()
		}
		let strokeTextAttributes = [
			NSAttributedString.Key.font : NSFont(name: getLabelFont(model: model), size: font.size) ?? .systemFont(ofSize: 15),
			NSAttributedString.Key.foregroundColor: NSColor(kitColor)
		] as [NSAttributedString.Key : Any]

		let attributedString = NSAttributedString(string: model.text,
												  attributes: strokeTextAttributes as [NSAttributedString.Key : Any]?)
		let strokeTextLayer = CATextLayer()
		strokeTextLayer.string = attributedString
		let size = attributedString.boundingRect(with: .zero, options: [], context: nil)
		strokeTextLayer.frame = size

		let resultView = NSView(frame: size )
		resultView.wantsLayer = true
		resultView.layer = strokeTextLayer

		return resultView
	}

	private func createGradientStrokeLabel(model: SVGText, gradient: SVGLinearGradient) -> NSView {
		guard let stroke = model.stroke, let fontSize = model.font?.size else {
			return NSView()
		}
		let strokeTextAttributes = [
			NSAttributedString.Key.strokeColor : NSColor.black,
			NSAttributedString.Key.foregroundColor : NSColor.clear,
			NSAttributedString.Key.strokeWidth : stroke.width / fontSize * 100, // you need this conversion because NSAttributedString.Key.strokeWidth is percent of font size
			NSAttributedString.Key.font : NSFont(name: getLabelFont(model: model), size: fontSize) ?? .systemFont(ofSize: fontSize)
		] as [NSAttributedString.Key : Any]

		let strokeTextLayer = CATextLayer()
		let attributedString = NSAttributedString(string: model.text,
												  attributes: strokeTextAttributes as [NSAttributedString.Key : Any]?)
		strokeTextLayer.string = attributedString

		var size = attributedString.boundingRect(with: .zero, options: [], context: nil)

		size = CGRect(x: 0, y: 0, width: size.width + stroke.width , height: size.height + stroke.width)
		strokeTextLayer.frame = size
		strokeTextLayer.bounds = CGRect(x: -stroke.width, y: stroke.width, width: size.width + stroke.width, height: size.height + stroke.width)

		let gradientLayer = CAGradientLayer()
		gradientLayer.frame = size
		let gradientColors = getGradientColors(gradient: gradient)
		gradientLayer.colors = [gradientColors[0].cgColor, gradientColors[1].cgColor]
		let gradientCoordinates = getLinearGradientCoordinates(rect: size , gradient: gradient)
		gradientLayer.locations = getGradientLoactions(stops: gradientCoordinates.stops)
		gradientLayer.startPoint = CGPoint(x: gradientCoordinates.0 , y: gradientCoordinates.1)
		gradientLayer.endPoint = CGPoint(x: gradientCoordinates.2, y: gradientCoordinates.3)

		let resultView = NSView(frame: size)
		gradientLayer.mask = strokeTextLayer
		resultView.wantsLayer = true
		resultView.layer = gradientLayer

		return resultView
	}

	private func createFilledGradientLabel(model: SVGText, gradient: SVGLinearGradient) -> NSView {
		guard let fontSize = model.font?.size else {
			return NSView()
		}
		let strokeTextAttributes = [
			NSAttributedString.Key.foregroundColor : NSColor.black,
			NSAttributedString.Key.font : NSFont(name: getLabelFont(model: model), size: fontSize) ?? .systemFont(ofSize: fontSize)
		] as [NSAttributedString.Key : Any]

		let strokeTextLayer = CATextLayer()
		let attributedString = NSAttributedString(string: model.text,
												  attributes: strokeTextAttributes as [NSAttributedString.Key : Any]?)
		strokeTextLayer.string = attributedString

		let size = attributedString.boundingRect(with: .zero, options: [], context: nil)

		strokeTextLayer.frame = size

		let gradientLayer = CAGradientLayer()
		gradientLayer.frame = size
		let gradientColors = getGradientColors(gradient: gradient)
		gradientLayer.colors = [gradientColors[0].cgColor, gradientColors[1].cgColor]
		let gradientCoordinates = getLinearGradientCoordinates(rect: size , gradient: gradient)
		gradientLayer.locations = getGradientLoactions(stops: gradientCoordinates.stops)
		gradientLayer.startPoint = CGPoint(x: gradientCoordinates.0 , y: gradientCoordinates.1)
		gradientLayer.endPoint = CGPoint(x: gradientCoordinates.2, y: gradientCoordinates.3)

		let resultView = NSView(frame: size)
		gradientLayer.mask = strokeTextLayer
		resultView.wantsLayer = true
		resultView.layer = gradientLayer

		return resultView
	}

	private func getGradientColors(gradient: SVGGradient) -> [NSColor] {
		var NSColorArr: [NSColor] = []
		_ = gradient.stops.map { stop in
			NSColorArr.append(NSColor(stop.color.toSwiftUI()))
		}
		return NSColorArr
	}

}

//need this method because you cant get height of view in any other way
private func getLabelSize(model: SVGText) -> CGRect {
	guard let fontSize = model.font?.size else {
		return CGRect.zero
	}
	if let width = model.stroke?.width {
		let strokeTextAttributes = [
			NSAttributedString.Key.strokeColor : NSColor.red,
			NSAttributedString.Key.foregroundColor : NSColor.clear,
			NSAttributedString.Key.strokeWidth : width / fontSize * 100, // you need this conversion because NSAttributedString.Key.strokeWidth is percent of font size
			NSAttributedString.Key.font : NSFont(name: getLabelFont(model: model), size: fontSize) ?? .systemFont(ofSize: fontSize)
		] as [NSAttributedString.Key : Any]

		let attributedString = NSAttributedString(string: model.text,
												  attributes: strokeTextAttributes as [NSAttributedString.Key : Any]?)
		var size = attributedString.boundingRect(with: .zero, options: [], context: nil)
		size = CGRect(x: 0, y: 0, width: size.width + width, height: size.height + width)
		return size
	} else {
		let strokeTextAttributes = [
			NSAttributedString.Key.foregroundColor : NSColor.black,
			NSAttributedString.Key.font : NSFont(name: getLabelFont(model: model), size: fontSize) ?? .systemFont(ofSize: fontSize)
		] as [NSAttributedString.Key : Any]

		let strokeTextLayer = CATextLayer()
		let attributedString = NSAttributedString(string: model.text,
												  attributes: strokeTextAttributes as [NSAttributedString.Key : Any]?)
		strokeTextLayer.string = attributedString

		let size = attributedString.boundingRect(with: .zero, options: [], context: nil)

		return size
	}
}

#else
import UIKit

struct SVGGUITextView: View {
	@ObservedObject var model: SVGText

	var body: some View {

		switch getLabelColor(model: model) {
		case _ as SVGLinearGradient, _ as SVGRadialGradient:
			let height = getLabelHeight(model: model)
			StrokeTextLabel(model: model)
				.lineLimit(1)
				.alignmentGuide(.leading) { d in d[model.textAnchor] }
				.alignmentGuide(VerticalAlignment.top) { _ in height }
				.offset(x: (model.stroke?.width ?? 0) / 2, y: (model.stroke?.width ?? 0) / 2)
				.position(x: 0, y: 0) //to specify that positioning is global, coords are in transform
				.transformEffect(model.transform)
				.frame(alignment: .topLeading)
		case _ as SVGColor:
			let height = getLabelHeight(model: model)
			if model.stroke?.width != nil {
				StrokeTextLabel(model: model)
					.lineLimit(1)
					.alignmentGuide(.leading) { d in d[model.textAnchor] }
					.alignmentGuide(VerticalAlignment.top) { _ in height }
					.offset(x: (model.stroke?.width ?? 0) / 2, y: (model.stroke?.width ?? 0) / 2)
					.position(x: 0, y: 0) //to specify that positioning is global, coords are in transform
					.transformEffect(model.transform)
					.frame(alignment: .topLeading)
			} else {
				Text(model.text)
					.font(model.font?.toSwiftUI())
					.lineLimit(1)
					.alignmentGuide(.leading) { d in d[model.textAnchor] }
					.alignmentGuide(VerticalAlignment.top) { d in d[VerticalAlignment.firstTextBaseline] }
					.apply(paint: model.fill)
					.position(x: 0, y: 0) // just to specify that positioning is global, actual coords
					.transformEffect(model.transform)
					.frame(alignment: .topLeading)
					.minimumScaleFactor(0.3)
			}
		default:
			Text("")
		}
	}
}

struct StrokeTextLabel: UIViewRepresentable {
	@ObservedObject var model: SVGText

	func makeUIView(context: Context) -> UIView {
		return getStrokeLabel()
	}

	func updateUIView(_ uiView: UIView, context: Context) {
	}

	private func getStrokeLabel() -> UIView {
		let strokeColor = model.stroke?.fill
		let fillColor = model.fill
		let resultView = UIView()

		//we use two switches because we need to put fill at first, and then put above it stroke
		switch fillColor {
		case nil:
			break
		case let color as SVGColor:
			resultView.addSubview(createOneColorFillLabel(model: model, kitColor: color.toSwiftUI()))
		case let linearGradient as SVGLinearGradient:
			resultView.addSubview(createFilledGradientLabel(model: model, gradient: linearGradient))
		case let radialGradient as SVGRadialGradient :
			break
			//TODO: add radialGradientCase
		default:
			break
		}

		switch strokeColor {
		case nil:
			break
		case let color as SVGColor:
			resultView.addSubview(createOneColorStrokeLabel(model: model, kitColor: color.toSwiftUI()))
		case let linearGradient as SVGLinearGradient:
			resultView.addSubview(createGradientStrokeLabel(model: model, gradient: linearGradient))
		case let radialGradient as SVGRadialGradient :
			break
			//TODO: add radialGradientCase
		default:
			break
		}
		return resultView
	}

	private func createOneColorStrokeLabel(model: SVGText, kitColor: Color) -> UIView {
		guard let stroke = model.stroke, let font = model.font else {
			return UIView()
		}
		let strokeTextAttributes = [
			NSAttributedString.Key.strokeColor : UIColor(kitColor),
			NSAttributedString.Key.strokeWidth : stroke.width / font.size * 100, // you need this conversion because NSAttributedString.Key.strokeWidth is percent of font size
			NSAttributedString.Key.font : UIFont(name: getLabelFont(model: model), size: font.size) ?? .systemFont(ofSize: 15)
		] as [NSAttributedString.Key : Any]

		let strokeLabel = UILabel(frame: .zero)
		strokeLabel.attributedText = NSMutableAttributedString(string: model.text, attributes: strokeTextAttributes)

		guard var size = strokeLabel.attributedText?.boundingRect(with: .zero, options: [], context: nil) else {
			return UIView()
		}

		size = CGRect(x: 0, y: 0, width: (size.width ?? 0) + stroke.width, height: (size.height ?? 0) + stroke.width)
		strokeLabel.frame = size
		strokeLabel.bounds = CGRect(x: stroke.width, y: stroke.width, width: (size.width ?? 0) + stroke.width, height: (size.height ?? 0) + stroke.width)

		let resultView = UIView(frame: size )

		resultView.addSubview(strokeLabel)

		return resultView
	}

	private func createOneColorFillLabel(model: SVGText, kitColor: Color) -> UIView {
		guard let font = model.font else {
			return UIView()
		}
		let strokeTextAttributes = [
			NSAttributedString.Key.font : UIFont(name: getLabelFont(model: model), size: font.size) ?? .systemFont(ofSize: 15)
		] as [NSAttributedString.Key : Any]

		let strokeLabel = UILabel(frame: .zero)
		strokeLabel.textColor = UIColor(kitColor)
		strokeLabel.attributedText = NSMutableAttributedString(string: model.text, attributes: strokeTextAttributes)

		var size = strokeLabel.attributedText?.boundingRect(with: .zero, options: [], context: nil)
		size = CGRect(x: 0, y: 0, width: size?.width ?? 0, height: size?.height ?? 0)
		strokeLabel.frame = size ?? CGRect()

		let resultView = UIView(frame: size ?? CGRect())

		resultView.addSubview(strokeLabel)

		return resultView
	}

	private func createGradientStrokeLabel(model: SVGText, gradient: SVGLinearGradient) -> UIView {
		guard let stroke = model.stroke, let fontSize = model.font?.size else {
			return UIView()
		}
		let strokeTextAttributes = [
			NSAttributedString.Key.strokeColor : UIColor.black,
			NSAttributedString.Key.foregroundColor : UIColor.clear,
			NSAttributedString.Key.strokeWidth : stroke.width / fontSize * 100, // you need this conversion because NSAttributedString.Key.strokeWidth is percent of font size
			NSAttributedString.Key.font : UIFont(name: getLabelFont(model: model), size: fontSize) ?? .systemFont(ofSize: fontSize)
		] as [NSAttributedString.Key : Any]

		let strokeLabel = UILabel(frame: .zero)
		strokeLabel.attributedText = NSMutableAttributedString(string: model.text, attributes: strokeTextAttributes)

		guard var size = strokeLabel.attributedText?.boundingRect(with: .zero, options: [], context: nil) else {
			return UIView()
		}

		size = CGRect(x: 0, y: 0, width: size.width + stroke.width , height: (size.height ) + stroke.width)
		strokeLabel.frame = size
		strokeLabel.bounds = CGRect(x: stroke.width, y: stroke.width, width: size.width + stroke.width, height: size.height + stroke.width)

		let gradientLayer = CAGradientLayer()
		gradientLayer.frame = size
		let gradientColors = getGradientColors(gradient: gradient)
		gradientLayer.colors = [gradientColors[0].cgColor, gradientColors[1].cgColor]
		let gradientCoordinates = getLinearGradientCoordinates(rect: size , gradient: gradient)
		gradientLayer.locations = getGradientLoactions(stops: gradientCoordinates.stops)
		gradientLayer.startPoint = CGPoint(x: gradientCoordinates.0 , y: gradientCoordinates.1)
		gradientLayer.endPoint = CGPoint(x: gradientCoordinates.2, y: gradientCoordinates.3)

		let resultView = UIView(frame: size )
		resultView.layer.addSublayer(gradientLayer)
		resultView.addSubview(strokeLabel)
		resultView.layer.mask = strokeLabel.layer

		return resultView
	}

	private func createFilledGradientLabel(model: SVGText, gradient: SVGLinearGradient) -> UIView {
		guard let fontSize = model.font?.size else {
			return UIView()
		}
		let label =  UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
		label.text = model.text
		label.font = UIFont(name: getLabelFont(model: model), size: fontSize) ?? .systemFont(ofSize: fontSize)
		label.sizeToFit()
		let size = label.frame
		let resultView = UIView(frame: size)

		resultView.addSubview(label)

		let gradientLayer = CAGradientLayer()
		gradientLayer.frame = size
		let gradientColors = getGradientColors(gradient: gradient)
		gradientLayer.colors = [gradientColors[0].cgColor, gradientColors[1].cgColor]
		resultView.layer.addSublayer(gradientLayer)
		let gradientCoordinates = getLinearGradientCoordinates(rect: size, gradient: gradient)
		gradientLayer.startPoint = CGPoint(x: gradientCoordinates.0 , y: gradientCoordinates.1)
		gradientLayer.endPoint = CGPoint(x: gradientCoordinates.2, y: gradientCoordinates.3)
		gradientLayer.locations = getGradientLoactions(stops: gradientCoordinates.stops)

		resultView.layer.mask = label.layer
		return resultView
	}

	private func getGradientColors(gradient: SVGGradient) -> [UIColor] {
		var uiColorArr: [UIColor] = []
		_ = gradient.stops.map { stop in
			uiColorArr.append(UIColor(stop.color.toSwiftUI()))
		}
		return uiColorArr
	}
	
}

//need this method because you cant get height of view in any other way
private func getLabelHeight(model: SVGText) -> CGFloat {
	guard let fontSize = model.font?.size else {
		return 0
	}
	if let width = model.stroke?.width {
		let strokeTextAttributes = [
			NSAttributedString.Key.strokeColor : UIColor.red,
			NSAttributedString.Key.foregroundColor : UIColor.clear,
			NSAttributedString.Key.strokeWidth : width / fontSize * 100, // you need this conversion because NSAttributedString.Key.strokeWidth is percent of font size
			NSAttributedString.Key.font : UIFont(name: getLabelFont(model: model), size: fontSize) ?? .systemFont(ofSize: fontSize)
		] as [NSAttributedString.Key : Any]

		let label = UILabel(frame: .zero)
		label.attributedText = NSMutableAttributedString(string: model.text, attributes: strokeTextAttributes)
		let size = label.attributedText?.boundingRect(with: .zero, options: [], context: nil)
		return (size?.height ?? 0) + width
	} else {
		let label =  UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
		label.numberOfLines = 1
		label.text = model.text
		label.font = UIFont(name: getLabelFont(model: model), size: model.font?.size ?? 15) ?? .systemFont(ofSize: fontSize)
		label.sizeToFit()
		let size = label.frame
		return size.height
	}
}

#endif

private func getLabelFont(model: SVGText) -> String {
	let separator = ","
	let fontString = model.font?.name
	let fonts = fontString?.components(separatedBy: separator)
	return fonts?[0] ?? ""
}

private func getLinearGradientCoordinates(rect: CGRect, gradient: SVGLinearGradient) -> (x1: CGFloat, y1: CGFloat, x2:  CGFloat, y2: CGFloat, stops: [CGFloat]) {
	let suiStops = gradient.stops.map { stop in
		stop.offset
	}
	let x1 = gradient.userSpace ? (gradient.x1 - rect.minX) / rect.size.width : gradient.x1
	let y1 = gradient.userSpace ? (gradient.y1 - rect.minY) / rect.size.height : gradient.y1
	let x2 = gradient.userSpace ? (gradient.x2 - rect.minX) / rect.size.width : gradient.x2
	let y2 = gradient.userSpace ? (gradient.y2 - rect.minY) / rect.size.height : gradient.y2
	return (x1, y1, x2, y2, suiStops)
}

private func getGradientLoactions(stops: [CGFloat]) -> [NSNumber] {
	var locations: [NSNumber] = []
	for stop in stops {
		locations.append(stop as NSNumber)
	}
	return locations
}

private func getLabelColor (model: SVGText) -> SVGPaint {
	if let strokeColor = model.stroke?.fill {
		return strokeColor
	} else if let fillColor = model.fill {
		return fillColor
	}
	return SVGPaint()
}
