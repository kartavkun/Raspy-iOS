//
//  AboutSettingsView.swift
//  Raspy
//
//  Created by Nikita Kartaviy on 16.04.2025.
//

import SwiftUI

struct AboutSettingsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Image("Rasp_logo_noBG")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .padding(.top, 20)
                
                Text("Raspy")
                    .font(.system(size: 32, weight: .bold))
                
                Text("Made by kartav__")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                Text("Beta 0.1.0")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.bottom, 30)
                
                HStack(spacing: 24) {
                    Link(destination: URL(string: "https://github.com/kartavkun/Raspy-iOS")!) {
                        Image("GithubLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                    }
                    
                    Link(destination: URL(string: "https://t.me/Raspy56")!) {
                        Image("TelegramLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("О приложении")
        .background(Color(uiColor: .secondarySystemBackground))
    }
}

#Preview {
    NavigationView {
        AboutSettingsView()
    }
}
