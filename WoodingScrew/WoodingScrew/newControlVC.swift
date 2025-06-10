import SwiftUI


struct ScrewInfoView: View {
    @Binding var showInfo: Bool
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.96, green: 0.88, blue: 0.76), Color(red: 0.82, green: 0.68, blue: 0.47)]),
                           startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("About WoodingScrew")
                    .font(.custom("AmericanTypewriter-Bold", size: 28))
                    .foregroundColor(.brown)
                    .padding(.top, 40)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        InfoSection(title: "How to Play",
                                  content: "Tap on the empty screw holes to place screws. Fill all the holes to complete the round. Each level has multiple rounds with increasing difficulty.")
                        
                        InfoSection(title: "Features",
                                  content: "• Freely place screws to solve the puzzle\n• No time limit - play at your own pace\n• Unlimited levels with increasing challenge\n• Beautiful wood textures and animations")
                        
                        InfoSection(title: "For Puzzle Lovers",
                                  content: "Perfect for fans of:\n• Nuts & bolts puzzles\n• Wood puzzles\n• Screw and bolt challenges\n• Mechanical puzzle games")
                    }
                    .padding()
                }
                
                Spacer()
                
                Button(action: { withAnimation { showInfo = false } }) {
                    Text("Back to Game")
                        .font(.custom("AmericanTypewriter-Bold", size: 20))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.brown)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
            }
        }
    }
}

struct InfoSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("AmericanTypewriter-Bold", size: 22))
                .foregroundColor(Color(red: 0.52, green: 0.33, blue: 0.14))
            
            Text(content)
                .font(.custom("AmericanTypewriter", size: 18))
                .foregroundColor(.brown)
        }
    }
}
