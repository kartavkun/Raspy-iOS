//
//  SupportSettingsView.swift
//  Rasp
//
//  Created by Nikita Kartaviy on 13.04.2025.
//

import SwiftUI

struct Donor: Identifiable {
    let id = UUID()
    let nickname: String
    let isRegular: Bool
}

struct SupportSettingsView: View {
    let regularDonors = [
        Donor(nickname: "", isRegular: true),
    ]
    
    let oneTimeDonors = [
        Donor(nickname: "", isRegular: false)
    ]
    
    var body: some View {
        List {
            Section {
                Link(destination: URL(string: "https://boosty.to/kartavkun")!) {
                    Text("Поддержать проект")
                        .foregroundColor(.blue)
                }
                .listRowBackground(
                    Rectangle()
                        .fill(Color(uiColor: .systemBackground))
                )
            }
            
            if !regularDonors.isEmpty {
                Section(header: Text("ЕЖЕМЕСЯЧНАЯ ПОДДЕРЖКА").textCase(.uppercase)) {
//                    ForEach(regularDonors) { donor in
//                        Text(donor.nickname)
//                    }
                }
                .listRowBackground(
                    Rectangle()
                        .fill(Color(uiColor: .systemBackground))
                )
            }
            
            if !oneTimeDonors.isEmpty {
                Section(header: Text("РАЗОВАЯ ПОДДЕРЖКА").textCase(.uppercase)) {
//                    ForEach(oneTimeDonors) { donor in
//                        Text(donor.nickname)
//                    }
                }
                .listRowBackground(
                    Rectangle()
                        .fill(Color(uiColor: .systemBackground))
                )
            }
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .scrollContentBackground(.hidden)
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Поддержка")
    }
}

#if DEBUG
struct SupportSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SupportSettingsView()
        }
    }
}
#endif
