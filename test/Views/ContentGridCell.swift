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
    private var padding: CGFloat = 1
    private var unzoomInternal: Int = 0
    
    @AppStorage("CellMargin") var cellMargin = 1
    @AppStorage("UseMarginForCoding") var useMarginForCoding = false
    
    @EnvironmentObject var globalState: BoardState
    @EnvironmentObject var media: Media
    
    @Environment(\.dismiss) var dismiss
    
    
    init (_ content: Content, defaultFontSize: CGFloat, foregroundColor: Color, backgroundColor: Color, maximumCellHeight: Double, cellWidth: Double, separatorLines: CGFloat) {
        self.content = content
        self.defaultFontSize = defaultFontSize
        if content.imageURL == "" {
            self.defaultFontSize *= 1.2
        }
        self.foregroundColor = Content.convertColor(value: content.foregroundColor) ?? foregroundColor
        self.maximumCellHeight = maximumCellHeight
        self.cellWidth = cellWidth
        self.backgroundColor = Content.convertBackgroundColor(value: content.backgroundColor) ?? backgroundColor
    }
    
    init (_ content: Content, defaultFontSize: CGFloat, foregroundColor: Color, backgroundColor: Color, maximumCellHeight: Double, cellWidth: Double, separatorLines: CGFloat, unzoomInterval: Int) {
        self.content = content
        self.defaultFontSize = defaultFontSize
        if content.imageURL == "" {
            self.defaultFontSize *= 1.2
        }
        self.foregroundColor = Content.convertColor(value: content.foregroundColor) ?? foregroundColor
        self.maximumCellHeight = maximumCellHeight
        self.cellWidth = cellWidth
        self.backgroundColor = Content.convertBackgroundColor(value: content.backgroundColor) ?? backgroundColor
        self.unzoomInternal = unzoomInterval
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack(alignment: .center) {
                Spacer()
                switch content.contentType {
                case .goHome: Image(systemName: "house").font(.system(size: 50)).imageScale(.medium)
                case .goBack: Image(systemName: "arrowshape.backward").font(.system(size: 50)).imageScale(.medium)
                default:
                    ZStack {
                        if content.imageURL != "" {
                            Image(uiImage: content.image)
                                .resizable()
                                .font(.system(size: 100))
                                .aspectRatio(contentMode: .fit)
                                .background(.clear)
                                .padding(5)
                        } else {
                            EmptyView()
                        }
                        if content.negate {
                            NegateView()
                        } else if (content.positive) {
                            PositiveView()
                        }
                    }
                }
                if content.name != "" && content.imageURL != "" {
                    Spacer()
                }
                if content.name != "" {
                    Text(content.name)
                        .foregroundColor(foregroundColor)
                        .background(.clear)
                        .font(.system(size: defaultFontSize))
                }
                if content.name != "" && content.imageURL == "" {
                    Spacer()
                }
            }
            .background(.clear)
            if globalState.authorMode {
                ZStack(alignment: .topLeading) {
                    Color.clear
                    VStack(alignment: .leading) {
                        if (content.soundURL != "") {
                            Image(systemName: "waveform")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
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
        .padding(Double(cellMargin))
        .frame(width: cellWidth, height: maximumCellHeight)
        .border(useMarginForCoding && content.backgroundColor != 0 ? backgroundColor : foregroundColor, width: CGFloat(cellMargin))
        .background(useMarginForCoding ? .clear : backgroundColor)
        .onAppear {
            if unzoomInternal > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(unzoomInternal)) {
                    dismiss()
                }
            }
        }
    }
}
struct ContentGridCell_Previews: PreviewProvider {
    static var previews: some View {
        ContentGridCell(Content().setPreview(), defaultFontSize: 10, foregroundColor: .black, backgroundColor: .clear, maximumCellHeight: 200, cellWidth: 200, separatorLines: 1).environmentObject(BoardState())
    }
}
