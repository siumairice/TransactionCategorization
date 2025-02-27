//
//  TransactionClassifierView.swift
//  Transactions-Search-Page
//
//  Created by Nicole Go on 2025-02-27.
//

import SwiftUI
import Charts

struct CategoryProbability: Identifiable {
    let id = UUID()
    let category: String
    let probability: Double
}

struct TransactionClassifierView: View {
    @State private var description: String = ""
    @State private var amount: String = ""
    @State private var date: Date = Date()
    @State private var predictedCategory: String = "No prediction yet"
    @State private var categoryProbabilities: [CategoryProbability] = []
    
    private let classifier = TransactionClassifier()

    var body: some View {
        VStack(spacing: 20) {
            Text("Transaction Classifier")
                .font(.title)
                .bold()
            
            TextField("Enter transaction description", text: $description)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Enter amount", text: $amount)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .padding()
            
            Button("Predict Category") {
                predictTransactionCategory()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Text("Predicted Category: \(predictedCategory)")
                .font(.headline)
                .padding()

            if !categoryProbabilities.isEmpty {
                PieChartView(data: categoryProbabilities)
                    .frame(height: 300)
                    .padding()
            }
        }
        .padding()
    }
    
    private func predictTransactionCategory() {
        if let (category, probabilities) = classifier.predictCategoryWithProbabilities(for: description) {
            predictedCategory = category
            categoryProbabilities = probabilities.map { CategoryProbability(category: $0.key, probability: $0.value) }
        } else {
            predictedCategory = "Prediction failed"
            categoryProbabilities = []
        }
    }

    
}

// Pie Chart View
struct PieChartView: View {
    let data: [CategoryProbability]

    var body: some View {
        Chart(data) { entry in
            SectorMark(
                angle: .value("Probability", entry.probability),
                innerRadius: .ratio(0.5)
            )
            .foregroundStyle(by: .value("Category", entry.category))
        }
        .chartLegend(.visible)
    }
}

struct TransactionClassifierView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionClassifierView()
    }
}
