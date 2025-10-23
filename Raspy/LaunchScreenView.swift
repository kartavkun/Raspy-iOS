import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            Image("Rasp_logo_noBG")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 250, height: 250)
        }
    }
}

#Preview {
    LaunchScreenView()
} 
