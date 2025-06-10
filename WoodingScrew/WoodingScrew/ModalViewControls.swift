import SwiftUI

// MARK: - Main Game View
@available(iOS 17.0, *)
struct ScrewGameView: View {
    @StateObject private var gameManager = ScrewGameManager()
    @State private var showInstructions = true
    @State private var showInfo = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.96, green: 0.88, blue: 0.76), Color(red: 0.82, green: 0.68, blue: 0.47)]),
                           startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            Image("ww")
                      .resizable()
                      .scaledToFill()
                      .frame(minWidth: 0) // 👈 This will keep other views (like a large text) in the frame
                      .edgesIgnoringSafeArea(.all)
            
            if showInstructions {
                ScrewInstructionView(showInstructions: $showInstructions)
            } else if showInfo {
                ScrewInfoView(showInfo: $showInfo)
            } else {
                VStack {
                    headerView
                    gameBoardView
                    controlsView
                }
                .transition(.opacity)
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: { withAnimation { showInfo = true } }) {
                Image(systemName: "info.circle")
                    .font(.title)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text("Level \(gameManager.currentLevel)")
                .font(.custom("AmericanTypewriter-Bold", size: 24))
                .foregroundColor(.white)
            
            Spacer()
            
            Text("Round \(gameManager.currentRound)/\(gameManager.roundsPerLevel)")
                .font(.custom("AmericanTypewriter", size: 20))
                .foregroundColor(.white)
        }
        .padding()
    }
    
    private var gameBoardView: some View {
        GeometryReader { geometry in
            ZStack {
                // Wood background
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.72, green: 0.53, blue: 0.34))
                    .shadow(radius: 10)
                
                  
                // Wood grain texture
                ForEach(0..<15) { _ in
                    Path { path in
                        let y = CGFloat.random(in: 0..<geometry.size.height)
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y + CGFloat.random(in: -10..<10)))
                    }
                    .stroke(Color(red: 0.62, green: 0.43, blue: 0.24), lineWidth: CGFloat.random(in: 0.5..<2))
                }
                
                // Game board
                BoardView(manager: gameManager, size: min(geometry.size.width, geometry.size.height) * 0.9)
                    .frame(width: min(geometry.size.width, geometry.size.height) * 0.9,
                           height: min(geometry.size.width, geometry.size.height) * 0.9)
                  
            }
            .frame(width: geometry.size.width, height: geometry.size.width)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
        }
        .aspectRatio(1, contentMode: .fit)
        .padding()
    }
    
    private var controlsView: some View {
        HStack {
            if gameManager.gameState == .gameOver {
                Button(action: { gameManager.restartGame() }) {
                    Text("Restart")
                        .font(.custom("AmericanTypewriter-Bold", size: 20))
                        .padding()
                     
                        .background(Color.brown)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: { shareGame() }) {
                    Text("Share")
                        .font(.custom("AmericanTypewriter-Bold", size: 20))
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }
    
    private func shareGame() {
        // Implement share functionality
        print("Sharing game progress")
    }
}

// MARK: - Board View
@available(iOS 17.0, *)
struct BoardView: View {
    @ObservedObject var manager: ScrewGameManager
    let size: CGFloat
    
    var body: some View {
        Canvas { context, size in
            // Draw the wood shape
            let woodPath = manager.currentShape.path(in: CGRect(origin: .zero, size: size))
            context.fill(woodPath, with: .color(Color(red: 0.62, green: 0.43, blue: 0.24)))
            context.stroke(woodPath, with: .color(Color(red: 0.52, green: 0.33, blue: 0.14)), lineWidth: 4)
            
            // Draw the screw holes
            for hole in manager.holes {
                let position = CGPoint(x: hole.x * size.width, y: hole.y * size.height)
                let holeRect = CGRect(x: position.x - 15, y: position.y - 15, width: 30, height: 30)
                
                if hole.filled {
                    // Draw screw
                    let screwPath = Path(ellipseIn: holeRect)
                    context.fill(screwPath, with: .color(Color(red: 0.8, green: 0.8, blue: 0.8)))
                    
                    // Screw head
                    let headRect = CGRect(x: position.x - 10, y: position.y - 10, width: 20, height: 20)
                    let headPath = Path(ellipseIn: headRect)
                    context.fill(headPath, with: .color(Color(red: 0.9, green: 0.9, blue: 0.9)))
                    
                    // Screw slot
                    let slotPath = Path { path in
                        path.move(to: CGPoint(x: position.x - 5, y: position.y))
                        path.addLine(to: CGPoint(x: position.x + 5, y: position.y))
                    }
                    context.stroke(slotPath, with: .color(Color.black), lineWidth: 2)
                } else {
                    // Draw empty hole
                    let holePath = Path(ellipseIn: holeRect)
                    context.fill(holePath, with: .color(Color.black.opacity(0.3)))
                    context.stroke(holePath, with: .color(Color.black.opacity(0.5)), lineWidth: 2)
                }
            }
        }
        .onTapGesture { location in
            let relativeX = location.x / size
            let relativeY = location.y / size
            manager.handleTap(x: relativeX, y: relativeY)
        }
    }
}

// MARK: - Game Manager
class ScrewGameManager: ObservableObject {
    enum GameState {
        case playing, roundComplete, levelComplete, gameOver
    }
    
    @Published var currentLevel: Int = 1
    @Published var currentRound: Int = 1
    @Published var roundsPerLevel: Int = 3
    @Published var holes: [ScrewHole] = []
    @Published var currentShape: WoodShape = .rectangle
    @Published var gameState: GameState = .playing
    
    init() {
        generateNewRound()
    }
    
    func generateNewRound() {
        currentShape = WoodShape.allCases.randomElement() ?? .rectangle
        let holeCount = 3 + currentLevel + currentRound
        var newHoles: [ScrewHole] = []
        
        for _ in 0..<holeCount {
            var x: CGFloat, y: CGFloat
            repeat {
                x = CGFloat.random(in: 0.1..<0.9)
                y = CGFloat.random(in: 0.1..<0.9)
            } while !currentShape.containsPoint(x: x, y: y)
            
            newHoles.append(ScrewHole(x: x, y: y, filled: false))
        }
        
        holes = newHoles
        gameState = .playing
    }
    
    func handleTap(x: CGFloat, y: CGFloat) {
        guard gameState == .playing else { return }
        
        if let index = holes.firstIndex(where: { hole in
            !hole.filled && distance(x1: x, y1: y, x2: hole.x, y2: hole.y) < 0.1
        }) {
            holes[index].filled = true
            
            if holes.allSatisfy({ $0.filled }) {
                if currentRound < roundsPerLevel {
                    currentRound += 1
                    gameState = .roundComplete
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            self.generateNewRound()
                        }
                    }
                } else {
                    currentLevel += 1
                    currentRound = 1
                    gameState = .levelComplete
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            self.generateNewRound()
                        }
                    }
                }
            }
        }
    }
    
    private func distance(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> CGFloat {
        sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2))
    }
    
    func restartGame() {
        currentLevel = 1
        currentRound = 1
        generateNewRound()
    }
}

// MARK: - Game Models
struct ScrewHole: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var filled: Bool
}

enum WoodShape: CaseIterable {
    case rectangle, circle, triangle, star, hexagon
    
    func path(in rect: CGRect) -> Path {
        switch self {
        case .rectangle:
            return Path(roundedRect: rect, cornerRadius: 20)
        case .circle:
            return Path(ellipseIn: rect)
        case .triangle:
            var path = Path()
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
            return path
        case .star:
            var path = Path()
            let points = 5
            let outerRadius = min(rect.width, rect.height) / 2
            let innerRadius = outerRadius * 0.4
            let center = CGPoint(x: rect.midX, y: rect.midY)
            
            for i in 0..<points * 2 {
                let angle = CGFloat.pi * 2 / CGFloat(points * 2) * CGFloat(i)
                let radius = i % 2 == 0 ? outerRadius : innerRadius
                let point = CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)
                if i == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            path.closeSubpath()
            return path
        case .hexagon:
            var path = Path()
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) / 2
            
            for i in 0..<6 {
                let angle = CGFloat.pi * 2 / 6 * CGFloat(i) - CGFloat.pi / 6
                let point = CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)
                if i == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            path.closeSubpath()
            return path
        }
    }
    
    func containsPoint(x: CGFloat, y: CGFloat) -> Bool {
        let point = CGPoint(x: x, y: y)
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let path = self.path(in: rect)
        return path.contains(point)
    }
}

// MARK: - Instruction View
struct ScrewInstructionView: View {
    @Binding var showInstructions: Bool
    @State private var currentPage = 0
    
    let instructions = [
        ("Welcome to WoodingScrew", "Tap empty holes to place screws. Fill all holes to complete the round."),
        ("Multiple Rounds", "Each level has 2-3 rounds with increasing difficulty."),
        ("No Time Limit", "Take your time to solve each puzzle at your own pace."),
        ("Unlimited Levels", "The game gets more challenging as you progress through levels.")
    ]
    
    var body: some View {
        ZStack {
//            LinearGradient(gradient: Gradient(colors: [Color(red: 0.96, green: 0.88, blue: 0.76), Color(red: 0.82, green: 0.68, blue: 0.47)]),
//                           startPoint: .top, endPoint: .bottom)
//                .edgesIgnoringSafeArea(.all)
            
            
            Image("ww")
                      .resizable()
                      .scaledToFill()
                      .frame(minWidth: 0) // 👈 This will keep other views (like a large text) in the frame
                      .edgesIgnoringSafeArea(.all)
            
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<instructions.count, id: \.self) { index in
                        VStack {
                            Text(instructions[index].0)
                                .font(.custom("AmericanTypewriter-Bold", size: 28))
                                .foregroundColor(.white)
                                .padding()
                            
                            Text(instructions[index].1)
                                .font(.custom("AmericanTypewriter", size: 20))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            InstructionAnimation(type: index)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                
                Button(action: { withAnimation { showInstructions = false } }) {
                    Text("Start Game")
                        .font(.custom("AmericanTypewriter-Bold", size: 24))
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

struct InstructionAnimation: View {
    let type: Int
    @State private var animate = false
    
    var body: some View {
        Group {
            switch type {
            case 0:
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(red: 0.72, green: 0.53, blue: 0.34))
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .fill(animate ? Color(red: 0.8, green: 0.8, blue: 0.8) : Color.black.opacity(0.3))
                        .frame(width: 30, height: 30)
                        .overlay(
                            animate ?
                            Circle()
                                .fill(Color(red: 0.9, green: 0.9, blue: 0.9))
                                .frame(width: 20, height: 20)
                                .overlay(Rectangle().fill(Color.black).frame(width: 10, height: 2)) : nil
                        )
                    
                    Image(systemName: "hand.point.up.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                        .offset(x: 0, y: animate ? 40 : 0)
                        .opacity(animate ? 0 : 1)
                }
            case 1:
                HStack(spacing: 20) {
                    ForEach(0..<3) { round in
                        VStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(red: 0.72, green: 0.53, blue: 0.34))
                                    .frame(width: 80, height: 80)
                                
                                VStack(spacing: 5) {
                                    ForEach(0..<(round + 2), id: \.self) { _ in
                                        Circle()
                                            .fill(Color(red: 0.8, green: 0.8, blue: 0.8))
                                            .frame(width: 20, height: 20)
                                    }
                                }
                            }
                            
                            Text("Round \(round + 1)")
                                .font(.custom("AmericanTypewriter", size: 14))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(animate && round == 2 ? 1.2 : 1.0)
                    }
                }
            case 2:
                ZStack {
                    Circle()
                        .fill(Color(red: 0.72, green: 0.53, blue: 0.34))
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .fill(Color(red: 0.82, green: 0.68, blue: 0.47))
                        .frame(width: 100, height: 100)
                    
                    Rectangle()
                        .fill(Color.brown)
                        .frame(width: 4, height: 30)
                        .offset(y: -15)
                    
                    Rectangle()
                        .fill(Color.brown)
                        .frame(width: 2, height: 40)
                        .offset(y: -20)
                        .rotationEffect(.degrees(animate ? 360 : 0))
                }
            default:
                VStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { level in
                        HStack {
                            Text("Level \(level + 1)")
                                .font(.custom("AmericanTypewriter-Bold", size: 18))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            HStack(spacing: 5) {
                                ForEach(0..<(level + 2), id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .scaleEffect(animate && level == 2 ? 1.5 : 1.0)
                                }
                            }
                        }
                        .padding()
                        .background(Color(red: 0.82, green: 0.68, blue: 0.47).opacity(0.5))
                        .cornerRadius(8)
                        .frame(width: 200)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever()) {
                animate = true
            }
        }
    }
}

// MARK: - Info View


// MARK: - Preview
@available(iOS 17.0, *)
struct ScrewGameView_Previews: PreviewProvider {
    static var previews: some View {
        ScrewGameView()
    }
}
