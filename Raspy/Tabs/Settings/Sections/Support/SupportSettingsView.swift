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
}

struct SupportSettingsView: View {
    let donors = [
        Donor(nickname: "Регина Ходырева"),
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
            
            if !donors.isEmpty {
                Section(header: Text("ПОДДЕРЖАВШИЕ").textCase(.uppercase)) {
                    ForEach(donors) { donor in
                        Text(donor.nickname)
                    }
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
