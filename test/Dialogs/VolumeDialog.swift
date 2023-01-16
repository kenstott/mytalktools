import SwiftUI

struct VolumeDialog: View {
    var body: some View {
        ZStack {
            VolumeSlider().padding([.all], 40)
        }
        .background(.gray.opacity(0.5))
    }
}

