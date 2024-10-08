//
//  ContentView.swift
//  BetterRest
//
//  Created by Seohyeong Jeong on 9/2/24.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime // need defaultWakeTime to be static
    @State private var sleepAmount = 8.0
    @State private var coffee = 1
    
    @State private var alertTitle = " "
    @State private var alertMessage = " "
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 0) {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Daily coffee intake")
                        .font(.headline)
                    
                    Stepper(coffee == 1 ? "1 cup" : "\(coffee) cups", value: $coffee, in: 1...20, step: 1)
                }
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculateBedtime)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try BetterRestModel(configuration: config)
            
            // get hour and minute in sec
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            // call model
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffee))
        
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time:.shortened)
        } catch {
            // catch error
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bed time."
        }
        showingAlert = true
    }
}

#Preview {
    ContentView()
}
