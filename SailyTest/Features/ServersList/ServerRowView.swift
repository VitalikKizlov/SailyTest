//
//  ServerRowView.swift
//  SailyTest
//
//  Created by Vitalii Kizlov on 18.10.2025.
//

import Foundation
import SwiftUI

struct ServerRowView: View {
    let server: Server

    var body: some View {
        HStack {
            Text(server.name)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.primary)
            Spacer()
            Text("\(server.distance) km")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
