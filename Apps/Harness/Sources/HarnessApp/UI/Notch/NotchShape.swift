import SwiftUI

struct NotchShape: Shape {
    var topRadius: CGFloat
    var bottomRadius: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(topRadius, bottomRadius) }
        set { topRadius = newValue.first; bottomRadius = newValue.second }
    }

    func path(in rect: CGRect) -> Path {
        Path(Self.cgPath(in: rect, topRadius: topRadius, bottomRadius: bottomRadius))
    }

    /// CGPath equivalent used by NotchMaskAnimator for CAShapeLayer mask animation (GPU path).
    static func cgPath(in rect: CGRect, topRadius: CGFloat, bottomRadius: CGFloat) -> CGPath {
        let p = CGMutablePath()
        p.move(to: .init(x: rect.minX, y: rect.minY))
        p.addLine(to: .init(x: rect.maxX, y: rect.minY))
        p.addLine(to: .init(x: rect.maxX, y: rect.maxY - bottomRadius))
        p.addQuadCurve(to: .init(x: rect.maxX - bottomRadius, y: rect.maxY),
                       control: .init(x: rect.maxX, y: rect.maxY))
        p.addLine(to: .init(x: rect.minX + bottomRadius, y: rect.maxY))
        p.addQuadCurve(to: .init(x: rect.minX, y: rect.maxY - bottomRadius),
                       control: .init(x: rect.minX, y: rect.maxY))
        p.addLine(to: .init(x: rect.minX, y: rect.minY + topRadius))
        p.addQuadCurve(to: .init(x: rect.minX + topRadius, y: rect.minY),
                       control: .init(x: rect.minX, y: rect.minY))
        p.closeSubpath()
        return p
    }
}
