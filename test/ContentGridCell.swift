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
    @EnvironmentObject var globalState: GlobalState
    
    init (_ content: Content, defaultFontSize: CGFloat, foregroundColor: Color, backgroundColor: Color, maximumCellHeight: Double, cellWidth: Double, separatorLines: CGFloat) {
        self.content = content
        self.defaultFontSize = defaultFontSize
        self.foregroundColor = foregroundColor
        self.maximumCellHeight = maximumCellHeight
        self.cellWidth = cellWidth
        self.backgroundColor = backgroundColor
        self.separatorLines = separatorLines
    }
    var body: some View {
        ZStack {
            
                VStack {
                    if content.urlImage != "" {
                        Image(String(content.urlImage.split(separator: ".").first!))
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .background(.clear)
                            .padding(5)
                    }
                    Text(content.name)
                        .foregroundColor(foregroundColor)
                        .background(.clear)
                        .font(.system(size: defaultFontSize))
                }
                .frame(width: cellWidth - cellMargin, height: maximumCellHeight - cellMargin)
                .background(.clear)

            
            if globalState.authorMode {
                ZStack(alignment: .topLeading) {
                        Color.clear
                    VStack(alignment: .leading) {
                        if (content.urlMedia != "") {
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
        .frame(minWidth: cellWidth, maxWidth: .infinity, minHeight: 0, maxHeight: maximumCellHeight)
        .border(foregroundColor, width: separatorLines * cellMargin)

        .background(backgroundColor)
    }
}
struct ContentGridCell_Previews: PreviewProvider {
    static var previews: some View {
        ContentGridCell(Content().setPreview(), defaultFontSize: 10, foregroundColor: .black, backgroundColor: .clear, maximumCellHeight: 200, cellWidth: 200, separatorLines: 1).environmentObject(GlobalState())
    }
}
