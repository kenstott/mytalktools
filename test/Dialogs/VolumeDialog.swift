import SwiftUI

struct VolumeDialog: View {
    var body: some View {
        ZStack {
            VolumeSlider()
                .padding([.leading, .trailing], 40)
                .padding([.top], 100)
        }
        .background(.gray.opacity(0.5))
    }
}

