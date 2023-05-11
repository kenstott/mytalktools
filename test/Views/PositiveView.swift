//
//  PositiveView.swift
//  test
//
//  Created by Kenneth Stott on 5/11/23.
//

import SwiftUI

struct PositiveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.width, rect.height) / 2
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: radius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
        return path
    }
}

struct PositiveView: View {
    var body: some View {
        GeometryReader { geometry in
            PositiveShape().stroke(Color.green, lineWidth: min(geometry.size.width, geometry.size.height) / 8).padding(10).opacity(0.8)
        }
    }
}
