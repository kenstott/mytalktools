//
//  ContentGridCell.swift
//  test
//
//  Created by Kenneth Stott on 1/16/23.
//

import SwiftUI

struct ContentGridCell: View {
    private var content = Content()
    private var defaultFontSize: CGFloat = 20
    private var foregroundColor = Color.black
    private var backgroundColor = Color.white
    private var maximumCellHeight: Double = 20
    private var cellWidth: Double = 20
    private var separatorLines: CGFloat = 1
    @AppStorage("CellMargin") var cellMargin: Double = 5.0
    @EnvironmentObject var globalState: BoardState
    @EnvironmentObject var media: Media
    
    init (_ content: Content, defaultFontSize: CGFloat, foregroundColor: Color, backgroundColor: Color, maximumCellHeight: Double, cellWidth: Double, separatorLines: CGFloat) {
        self.content = content
        self.defaultFontSize = defaultFontSize
        self.foregroundColor = content.convertColor(value: content.foregroundColor) ?? foregroundColor
        self.maximumCellHeight = maximumCellHeight
        self.cellWidth = cellWidth
        self.backgroundColor = content.convertColor(value: content.backgroundColor) ?? backgroundColor
        self.separatorLines = separatorLines
    }
    var body: some View {
        ZStack(alignment: .center) {
            VStack(alignment: .center) {
                Spacer()
                switch content.contentType {
                case .goHome: Image(systemName: "house").font(.system(size: 50)).imageScale(.medium)
                case .goBack: Image(systemName: "arrowshape.backward").font(.system(size: 50)).imageScale(.medium)
                default:
                    Image(uiImage: content.image)
                        .resizable()
                        .font(.system(size: 100))
                        .aspectRatio(1, contentMode: .fit)
                        .background(.clear)
                        .padding(5)
                }
                Spacer()
                Text(content.name)
                    .foregroundColor(foregroundColor)
                    .background(.clear)
                    .font(.system(size: defaultFontSize))
            }
            .background(.clear)
            if globalState.authorMode {
                ZStack(alignment: .topLeading) {
                    Color.clear
                    VStack(alignment: .leading) {
                        if (content.soundURL != "") {
                            Image(systemName: "waveform")
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: 15)
                                .foregroundColor(.gray)
                                .background(.clear)
                        }
                        if content.ttsSpeechPrompt != "" {
                            Text("[\(content.ttsSpeechPrompt)]")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                        }
                        if content.alternateTTS != "" {
                            Text("{\(content.alternateTTS)}")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(5)
            }
            if content.childBoardId != 0 {
                ZStack(alignment: .topTrailing) {
                    Color.clear
                    Image(systemName: "ellipsis")
                        .padding(5)
                        .alignmentGuide(.top) { $0[.bottom] - 20 }
                        .alignmentGuide(.trailing) { $0[.trailing] + 1 }
                        .foregroundColor(.gray)
                        .background(.clear)
                }
            }
        }
        .padding(cellMargin)
        .frame(width: cellWidth, height: maximumCellHeight)
        .border(foregroundColor, width: separatorLines)
        .background(backgroundColor)
    }
}
struct ContentGridCell_Previews: PreviewProvider {
    static var previews: some View {
        ContentGridCell(Content().setPreview(), defaultFontSize: 10, foregroundColor: .black, backgroundColor: .clear, maximumCellHeight: 200, cellWidth: 200, separatorLines: 1).environmentObject(BoardState())
    }
}
