//
//  ContentListRow.swift
//  test
//
//  Created by Kenneth Stott on 1/16/23.
//

import SwiftUI

struct ContentListRow: View {
    @EnvironmentObject var media: Media
    private var content = Content()
    private var defaultFontSize: CGFloat = 20
    private var foregroundColor = Color.white
    private var addDisclosureIndicator = true
    init (_ content: Content, defaultFontSize: CGFloat, foregroundColor: Color, disclosureIndicator: Bool? = nil) {
        self.content = content
        self.defaultFontSize = defaultFontSize
        self.foregroundColor = foregroundColor
        self.addDisclosureIndicator = disclosureIndicator ?? true
    }
    var body: some View {
        HStack {
            if content.imageURL != "" {
                ZStack {
                    Image(uiImage: content.image)
                        .resizable()
                        .font(.system(size: 100))
                        .aspectRatio(contentMode: .fit)
                        .background(.clear)
                        .padding(5)
                    if content.negate {
                        NegateView()
                    } else if (content.positive) {
                        PositiveView()
                    }
                }
                .frame(width: 50, height: 50)
            } else {
                EmptyView()
                    .frame(width: 50, height: 50)
            }
            Text(content.name)
                .foregroundColor(foregroundColor)
                .background(.clear)
                .font(.system(size: defaultFontSize))
            Spacer()
            if (content.linkId != 0 && addDisclosureIndicator) {
                DisclosureIndicator()
            }
        }
    }
}
struct ContentListRow_Previews: PreviewProvider {
    static var previews: some View {
        ContentListRow(Content().setPreview(), defaultFontSize: 20, foregroundColor: Color.black).environmentObject(BoardState())
    }
}
