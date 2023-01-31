//
//  DisclosureIndicator.swift
//  test
//
//  Created by Kenneth Stott on 1/16/23.
//

import SwiftUI

struct DisclosureIndicator: View {
    var body: some View {
        Button {

        } label: {
            Image(systemName: "chevron.right")
                .font(.body)
                .foregroundColor(Color(UIColor.tertiaryLabel))
        }
        .disabled(true)
        .accessibilityLabel(Text("chevron"))
        .accessibilityIdentifier("chevron")
        .accessibilityHidden(true)
    }
}


struct DisclosureIndicator_Previews: PreviewProvider {
    static var previews: some View {
        DisclosureIndicator()
    }
}
