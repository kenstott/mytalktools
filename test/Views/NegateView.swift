import SwiftUI

struct NegateShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.width, rect.height) / 2
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: radius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
        if rect.height > rect.width {
            var adjust = (rect.height - rect.width) / 2
            path.move(to: CGPoint(x: rect.midX, y: rect.maxY - adjust))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY + adjust))
        } else {
            path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        }
        return path
    }
}

struct NegateView: View {
    var body: some View {
        GeometryReader { geometry in
            NegateShape().stroke(Color.red, lineWidth: min(geometry.size.width, geometry.size.height) / 8).padding(10).rotationEffect(.degrees(45)).opacity(0.8)
        }
    }
}

