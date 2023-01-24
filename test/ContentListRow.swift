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
    init (_ content: Content, defaultFontSize: CGFloat, foregroundColor: Color) {
        self.content = content
        self.defaultFontSize = defaultFontSize
        self.foregroundColor = foregroundColor
    }
    var body: some View {
        HStack {
            if content.urlImage != "" {
                Image(uiImage: media.getImage(content.urlImage))
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .background(.clear)
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
            if (content.childBoardId != 0 || content.childBoardLink != 0) {
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
