//
//  TransactionClassifier.swift
//  Transactions-Search-Page
//
//  Created by Nicole Go on 2025-02-27.
//
//
//  TransactionClassifier.swift
//  Transactions-Search-Page
//
//  Created by Nicole Go on 2025-02-27.
//

import CoreML
import NaturalLanguage

class TransactionClassifier {
    private var nlModel: NLModel?  // Natural Language model for text classification

    init() {
        loadCategoryModel()
    }

    // Load MLTextClassifier as an NLModel
    private func loadCategoryModel() {
        guard let model = try? TransactionsClassifierText(configuration: MLModelConfiguration()) else {
            print("ERROR: Failed to load CoreML model.")
            return
        }
        
        do {
            self.nlModel = try NLModel(mlModel: model.model) // Convert MLModel to NLModel
        } catch {
            print("ERROR: Failed to convert MLModel to NLModel.")
        }
    }

    // Predict category using NLModel
    func predictCategory(for description: String) -> String? {
        guard let categoryPredictor = nlModel else {
            print("ERROR: ML model not loaded")
            return "unknown"
        }

        let predictedLabel = categoryPredictor.predictedLabel(for: description) ?? "n/a"
        let possibleLabels = categoryPredictor.predictedLabelHypotheses(for: description, maximumCount: 2)

        print("Transaction: \(description) → Predictions: \(predictedLabel), Probabilities: \(possibleLabels)")

        return predictedLabel
    }
    func predictCategoryWithProbabilities(for description: String) -> (String, [String: Double])? {
        guard let categoryPredictor = nlModel else {
            print("ERROR: ML model not loaded")
            return nil
        }

        let predictedLabel = categoryPredictor.predictedLabel(for: description) ?? "n/a"
        let possibleLabels = categoryPredictor.predictedLabelHypotheses(for: description, maximumCount: 13)
        print(predictedLabel)
        print(possibleLabels)
        return (predictedLabel, possibleLabels)
    }

}
