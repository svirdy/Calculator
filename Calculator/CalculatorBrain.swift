//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Sachin Virdy on 9/23/15.
//  Copyright © 2015 Sachin Virdy. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private enum Op {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String: Op]() // a dictionary of strings looking up to find Ops
    
    init() {
        knownOps["✕"] = Op.BinaryOperation("✕", *)
        knownOps["÷"] = Op.BinaryOperation("÷") { $1 / $0 }
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["-"] = Op.BinaryOperation("-") { $1 - $0 }
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
                
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        
        return (nil, ops)
    }
    
    func evaluate() -> Double? { // must be an optional because user could hit +, *, etc first without a number
        let (result, remainder) = evaluate(opStack)
        return result
    }
    
    
    func pushOperand(operand: Double) {
        opStack.append(Op.Operand(operand))
    }
    
    func performOperation(symbol: String) {
        if let operation = knownOps[symbol] { // whenever you look up something in a dictionary it always returns an Optional
            opStack.append(operation)
        }
    }
}