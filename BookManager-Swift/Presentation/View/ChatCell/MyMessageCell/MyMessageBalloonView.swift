import UIKit

final class MyMessageBalloonView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_: CGRect) {
        let bezierPath = UIBezierPath()
        UIColor.systemGreen.setFill()
        UIColor.clear.setStroke()
        bezierPath.move(to: CGPoint(x: 0, y: 10))
        bezierPath.addQuadCurve(to: CGPoint(x: 20, y: 0), controlPoint: CGPoint(x: 10, y: 20))
        bezierPath.addQuadCurve(to: CGPoint(x: 5, y: 20), controlPoint: CGPoint(x: 15, y: 30))
        bezierPath.close()
        bezierPath.fill()
        bezierPath.stroke()
    }
}
