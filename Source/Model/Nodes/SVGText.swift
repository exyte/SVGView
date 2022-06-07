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
		if model.stroke != nil {
			StrokeTextLabel(model: model)
		}
	}
}

struct StrokeTextLabel: UIViewRepresentable {
	var model: SVGText

	init(model: SVGText) {
		self.model = model
	}

	func makeUIView(context: Context) -> UIView {

		let strokeColor = model.stroke?.fill
		var resultView = UIView()
		var kitColor = Color.black

		switch strokeColor {
		case _ as SVGLinearGradient:
			return createGradientLabel(targetView: UIView(frame: CGRect(x: 0, y: 0, width: model.bounds().width, height: model.bounds().height)), letter: model.text, fontsize: model.font!.size, UIColor.blue, UIColor.green)
		case _ as SVGRadialGradient:
			break
		case let color as SVGColor:
			kitColor = color.toSwiftUI()
			resultView = createPlainColorLabel(model: model, kitColor: kitColor)
		default:
			fatalError("Base SVGPaint is not convertable to SwiftUI")
		}
		return resultView
	}

	func updateUIView(_ uiView: UIView, context: Context) {
	}
}

func createGradientLabel(targetView : UIView, letter : String,fontsize : CGFloat , _ startColor: UIColor = UIColor.init(named: "startColor")!, _ endColor: UIColor = UIColor.init(named: "endColor")!) -> UIView {
	let gradientLayer = CAGradientLayer()
   gradientLayer.frame = targetView.bounds
   gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
   targetView.layer.addSublayer(gradientLayer)
   gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
   gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

	let label = UILabel(frame: targetView.bounds)
	let strokeTextAttributes = [
		NSAttributedString.Key.strokeColor : UIColor.red,
		NSAttributedString.Key.foregroundColor : UIColor.clear,
		NSAttributedString.Key.strokeWidth : -4.0,
		NSAttributedString.Key.font : UIFont(name: "Arial", size: fontsize)!
	] as [NSAttributedString.Key : Any]

	label.attributedText = NSMutableAttributedString(string: letter, attributes: strokeTextAttributes)
   targetView.addSubview(label)

   targetView.layer.mask = label.layer
	return targetView
}

func createPlainColorLabel(model: SVGText, kitColor: Color) -> UILabel {
	let attributedStringParagraphStyle = NSMutableParagraphStyle()
	attributedStringParagraphStyle.alignment = NSTextAlignment.center

	let attributedString = NSAttributedString(
		string: model.text,
		attributes:[
			NSAttributedString.Key.paragraphStyle: attributedStringParagraphStyle,
			NSAttributedString.Key.strokeWidth: (model.stroke!.width / 4) as CGFloat,
			NSAttributedString.Key.foregroundColor: UIColor.black,
			NSAttributedString.Key.strokeColor: UIColor(cgColor:  kitColor.cgColor ?? CGColor(red: 255, green: 255, blue: 255, alpha: 1)),
			NSAttributedString.Key.font: UIFont(name: "Arial", size: model.font!.size)!

		]
	)

	let strokeLabel = UILabel(frame: CGRect.zero)
	strokeLabel.attributedText = attributedString
	strokeLabel.backgroundColor = UIColor.clear
	strokeLabel.sizeToFit()
	strokeLabel.center = CGPoint.init(x: 0.0, y: 0.0)

	return strokeLabel
}
