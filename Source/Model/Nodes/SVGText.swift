import SwiftUI
import UIKit

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

struct SVGGUITextView: View {
	@ObservedObject var model: SVGText

	var body: some View {

		switch getLabelColor(model: model) {
		case _ as SVGLinearGradient:
			let height = getHeightOfLabel(model: model)
			StrokeTextLabel(model: model)
			//TODO : need to fix postion to y axis
				.offset(x: model.transform.tx, y: model.transform.ty - height)
		case _ as SVGColor:
			if model.stroke?.width != nil {
				StrokeTextLabel(model: model)
					.lineLimit(1)
					.alignmentGuide(.leading) { d in d[model.textAnchor] }
					.alignmentGuide(VerticalAlignment.top) { d in d[VerticalAlignment.firstTextBaseline] }
					.position(x: 0, y: 0) //to specify that positioning is global, coords are in transform
				//TODO : need to fix postion to y axis
					.transformEffect(CGAffineTransform(a: model.transform.a, b: model.transform.b, c: model.transform.c, d: model.transform.d, tx: model.transform.tx, ty: model.transform.ty))
					.frame(alignment: .topLeading)
			}
			Text(model.text)
				.font(model.font?.toSwiftUI())
				.lineLimit(1)
				.alignmentGuide(.leading) { d in d[model.textAnchor] }
				.alignmentGuide(VerticalAlignment.top) { d in d[VerticalAlignment.firstTextBaseline] }
				.apply(paint: model.fill)
				.position(x: 0, y: 0) // just to specify that positioning is global, actual coords
				.transformEffect(model.transform)
				.frame(alignment: .topLeading)
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
		var resultView = UIView()
		let strokeColor = getLabelColor(model: model)

		switch strokeColor {
		case let color as SVGColor:
			resultView = createOneColorStrokeLabel(model: model, kitColor: color.toSwiftUI())
		case let linearGradient as SVGLinearGradient:
			let gradientColors: [UIColor] = getGradientColors(gradient: linearGradient)
			if model.stroke?.width != nil {
				resultView = createGradientLabel(model: model, startColor: gradientColors[0], endColor: gradientColors[1])
			} else if model.fill != nil {
				resultView = createFilledGradientLabel(model: model,startColor: gradientColors[0], endColor: gradientColors[1])
			}
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
			NSAttributedString.Key.foregroundColor : UIColor.clear,
			NSAttributedString.Key.strokeWidth : stroke.width / font.size * 100, // you need this conversion because NSAttributedString.Key.strokeWidth is percent of font size
			NSAttributedString.Key.font : UIFont(name: getLabelFont(model: model), size: font.size) ?? .systemFont(ofSize: 15)
		] as [NSAttributedString.Key : Any]

		let strokeLabel = UILabel(frame: .zero)
		strokeLabel.attributedText = NSMutableAttributedString(string: model.text, attributes: strokeTextAttributes)

		var size = strokeLabel.attributedText?.boundingRect(with: .zero, options: [], context: nil)
		size = CGRect(x: 0, y: 0, width: size?.width ?? 0, height: (size?.height ?? 0) + stroke.width)
		strokeLabel.frame = size ?? CGRect()

		let resultView = UIView(frame: size ?? CGRect())
		resultView.backgroundColor = .blue

		resultView.addSubview(strokeLabel)

		return resultView
	}

	private func createGradientLabel(model: SVGText, startColor: UIColor, endColor: UIColor) -> UIView {
		guard let stroke = model.stroke, let font = model.font else {
			return UIView()
		}
		let strokeTextAttributes = [
			NSAttributedString.Key.strokeColor : UIColor.red,
			NSAttributedString.Key.foregroundColor : UIColor.clear,
			NSAttributedString.Key.strokeWidth : stroke.width / font.size * 100, // you need this conversion because NSAttributedString.Key.strokeWidth is percent of font size
			NSAttributedString.Key.font : UIFont(name: getLabelFont(model: model), size: font.size) ?? .systemFont(ofSize: 15)
		] as [NSAttributedString.Key : Any]

		let strokeLabel = UILabel(frame: .zero)
		strokeLabel.attributedText = NSMutableAttributedString(string: model.text, attributes: strokeTextAttributes)

		var size = strokeLabel.attributedText?.boundingRect(with: .zero, options: [], context: nil)
		let height = (size?.height ?? 0) + stroke.width
		size = CGRect(x: 0, y: 0, width: size?.width ?? 0, height: height)
		strokeLabel.frame = size ?? CGRect()

		let resultView = UIView(frame: size ?? CGRect())
		let gradientLayer = CAGradientLayer()
		gradientLayer.frame = size ?? CGRect()
		gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
		resultView.layer.addSublayer(gradientLayer)
		gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
		gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

		resultView.addSubview(strokeLabel)

		resultView.layer.mask = strokeLabel.layer
		return resultView
	}

	private func createFilledGradientLabel(model: SVGText, startColor: UIColor, endColor: UIColor) -> UIView {
		guard let font = model.font else {
			return UIView()
		}
		let label =  UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
		label.text = model.text
		label.font = UIFont(name: getLabelFont(model: model), size: font.size) ?? .systemFont(ofSize: 15)
		label.sizeToFit()
		let size = label.frame
		let resultView = UIView(frame: size)

		resultView.addSubview(label)

		let gradientLayer = CAGradientLayer()
		gradientLayer.frame = size
		gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
		resultView.layer.addSublayer(gradientLayer)
		gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
		gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

		resultView.layer.mask = label.layer
		return resultView
	}

	private func getGradientColors(gradient: SVGLinearGradient) -> [UIColor] {
		var uiColorArr: [UIColor] = []
		_ = gradient.stops.map { stop in
			uiColorArr.append(UIColor(stop.color.toSwiftUI()))
		}
		return uiColorArr
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

private func getLabelFont(model: SVGText) -> String {
	let separator = ","
	let fontString = model.font?.name
	let fonts = fontString?.components(separatedBy: separator)
	return fonts?[0] ?? ""
}

//need this method because you cant get height of view in any other way
private func getHeightOfLabel(model: SVGText) -> CGFloat {
	if let width = model.stroke?.width, let fontSize = model.font?.size {
		let strokeTextAttributes = [
			NSAttributedString.Key.strokeColor : UIColor.red,
			NSAttributedString.Key.foregroundColor : UIColor.clear,
			NSAttributedString.Key.strokeWidth : width / fontSize * 100, // you need this conversion because NSAttributedString.Key.strokeWidth is percent of font size
			NSAttributedString.Key.font : UIFont(name: getLabelFont(model: model), size: fontSize) ?? .systemFont(ofSize: 15)
		] as [NSAttributedString.Key : Any]

		let label = UILabel(frame: .zero)
		label.attributedText = NSMutableAttributedString(string: model.text, attributes: strokeTextAttributes)
		let size = label.attributedText?.boundingRect(with: .zero, options: [], context: nil)
		return size?.height ?? 0
	} else {

		let label =  UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
		label.numberOfLines = 1
		label.text = model.text
		label.font = UIFont(name: getLabelFont(model: model), size: model.font?.size ?? 15) ?? .systemFont(ofSize: 15)
		label.sizeToFit()
		let size = label.frame
		return size.height
	}
}
