import UIKit

final class OtherMessageBalloonView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_: CGRect) {
        let bezierPath = UIBezierPath()
        UIColor.white.setFill()
        UIColor.clear.setStroke()
        bezierPath.move(to: CGPoint(x: 20, y: 15))
        bezierPath.addQuadCurve(to: CGPoint(x: 5, y: 5), controlPoint: CGPoint(x: 5, y: 10))
        bezierPath.addQuadCurve(to: CGPoint(x: 10, y: 25), controlPoint: CGPoint(x: 0, y: 10))
        bezierPath.close()
        bezierPath.fill()
        bezierPath.stroke()
    }
}
