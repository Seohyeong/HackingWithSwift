//
//  ContentView.swift
//  RockPaperScissor
//
//  Created by Seohyeong Jeong on 8/30/24.
//

import SwiftUI

struct ContentView: View {
    @State private var appsChoice = Int.random(in: 0...2)
    @State private var shouldWin = Bool.random()
    @State private var numRound: Int = 0
    @State private var playerScore: Int = 0
    @State private var showAlert = false
    
    let choicesEmojis = ["👊", "✋", "✌️"]
//    let playerMoveMessage = shouldWin ? "WIN" : "LOSE"
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.red, .yellow, .green, .blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Text("\(numRound+1) Round")
                        .font(.title2).fontWeight(.medium)
                        .shadow(radius: 10)
                    
                    Spacer()
                    
                    Text("Score: \(playerScore)")
                        .font(.title2).fontWeight(.medium)
                        .shadow(radius: 10)
                }
                Spacer()
                
                Text(choicesEmojis[appsChoice])
                    .font(.system(size: 60))
                    .shadow(radius: 10)
                
                Text("You should \(shouldWin ? "WIN" : "LOSE") this game")
                    .font(.title).fontWeight(.medium)
                    .shadow(radius: 10)
                
                HStack {
                    ForEach(choicesEmojis, id: \.self) { choice in
                        Button {
                            buttonTapped(choice)
                            continueGame()
                        } label: {
                            Text(choice)
                                .font(.system(size: 60))
                                .shadow(radius: 10)
                                .padding()
                        }
                    }
                }
                Spacer()
            }
            .padding()
        }
        .alert("END", isPresented: $showAlert) {
            Button("Continue") {
                resetGame()
            }
        } message: {
            Text("Your score: \(playerScore)")
        }
    }
    
    func resetGame() {
        numRound = 0
        playerScore = 0
        shouldWin.toggle()
        appsChoice = Int.random(in: 0...2)
    }
    
    func continueGame() {
        shouldWin.toggle()
        appsChoice = Int.random(in: 0...2)
    }
    
    func getAnswerToWin(_ appMove: String) -> String {
        var answer = ""
        
        if (appMove == "👊") {
            if shouldWin {
                answer = "✋"
            } else {
                answer = "✌️"
            }
        } else if (appMove == "✋") {
            if shouldWin {
                answer = "✌️"
            } else {
                answer = "👊"
            }
        } else {
            if shouldWin {
                answer = "👊"
            } else {
                answer = "✋"
            }
        }
        return answer
    }
    
    func buttonTapped(_ playerMove: String) {
        let appMove = choicesEmojis[appsChoice]
        let answer = getAnswerToWin(appMove)
        
        if (answer == playerMove) { playerScore += 1 }

        numRound += 1
        showAlert = numRound == 10 ? true : false
    }
}

#Preview {
    ContentView()
}
