//
//  AIChatContextBuilder.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 15.01.26.
//

import Foundation

struct AIChatContextBuilder {
    
    static func build(
        pets: [Pet],
        logsByPetId: [String: [HealthLog]],
        includeResolved: Bool = true,
        historyDays: Int? = nil,
        maxHistoryLinesPerPet: Int = 40
    ) -> String {
        guard !pets.isEmpty else {
            return "No pets available in household. Provide general pet care info."
        }
        
        var lines: [String] = []
        lines.append("Household Pets Summary:")
        
        for pet in pets {
            let petId = pet.id ?? ""
            var logs = logsByPetId[petId] ?? []
            
            if !includeResolved {
                logs = logs.filter { !$0.isResolved }
            }
            
            if let historyDays {
                let cutoff =
                Calendar.current.date(
                    byAdding: .day,
                    value: -historyDays,
                    to: Date()
                ) ?? .distantPast
                logs = logs.filter { $0.date >= cutoff }
            }
            
            logs.sort(by: { $0.date > $1.date })
            
            lines.append("")
            lines.append("Pet: \(pet.name)")
            lines.append("- Species: \(pet.species.rawValue)")
            lines.append("- Gender: \(pet.gender.rawValue)")
            lines.append("- Age: \(pet.ageFormatted)")
            if let breed = pet.breed, !breed.isEmpty {
                lines.append("- Breed: \(breed)")
            }
            if let color = pet.color, !color.isEmpty {
                lines.append("- Color: \(color)")
            }
            if let bio = pet.bio, !bio.isEmpty { lines.append("- Bio: \(bio)") }
            
            lines.append(contentsOf: summarizeHealthSummary(logs: logs))
            
            lines.append(
                contentsOf: summarizeHistoryLines(
                    logs: logs,
                    maxLines: maxHistoryLinesPerPet
                )
            )
        }
        
        lines.append("")
        lines.append(
            "If user asks medical advice, ask clarifying questions: species, age, weight, duration, symptoms."
        )
        
        return lines.joined(separator: "\n")
    }
    
    // MARK: - Private
    
    private static func summarizeHealthSummary(logs: [HealthLog]) -> [String] {
        guard !logs.isEmpty else { return ["- Health: no logs yet"] }
        
        var out: [String] = []
        
        if let lastWeight = logs
            .filter({ $0.category == .weight })
            .first(where: { $0.value != nil }),
           let value = lastWeight.value
        {
            out.append(
                "- Latest weight: \(String(format: "%.1f", value)) kg on \(lastWeight.date.formatted(.dateTime.year().month().day()))"
            )
        }
        
        let activeMeds = logs
            .filter { $0.category == .medication && !$0.isResolved }
            .sorted {
                ($0.nextDueDate ?? .distantFuture)
                < ($1.nextDueDate ?? .distantFuture)
            }
        
        if !activeMeds.isEmpty {
            out.append("- Active medications:")
            for med in activeMeds.prefix(5) {
                let due =
                med.nextDueDate?.formatted(
                    .dateTime.year().month().day().hour().minute()
                ) ?? "unknown"
                let dose =
                (med.dosage?.isEmpty == false) ? " (\(med.dosage!))" : ""
                out.append("  - \(med.title)\(dose) – next due: \(due)")
            }
        }
        
        let upcoming = logs
            .filter {
                $0.category != .medication && !$0.isResolved
                && $0.nextDueDate != nil
            }
            .sorted {
                ($0.nextDueDate ?? .distantFuture)
                < ($1.nextDueDate ?? .distantFuture)
            }
        
        if !upcoming.isEmpty {
            out.append("- Upcoming health items:")
            for item in upcoming.prefix(5) {
                let due =
                item.nextDueDate?.formatted(.dateTime.year().month().day())
                ?? "unknown"
                out.append(
                    "  - \(item.category.rawValue): \(item.title) – due: \(due)"
                )
            }
        }
        
        return out
    }
    
    private static func summarizeHistoryLines(logs: [HealthLog], maxLines: Int)
    -> [String]
    {
        guard !logs.isEmpty else { return [] }
        
        var out: [String] = []
        out.append("- Recent history (most recent first):")
        
        for log in logs.prefix(maxLines) {
            let date = log.date.formatted(.dateTime.year().month().day())
            let cat = log.category.rawValue
            
            let valuePart: String = {
                if let value = log.value {
                    return " value=\(String(format: "%.1f", value))"
                }
                return ""
            }()
            
            let dosagePart: String = {
                if let dosage = log.dosage, !dosage.isEmpty {
                    return " dose=\(dosage)"
                }
                return ""
            }()
            
            let nextDuePart: String = {
                if let due = log.nextDueDate {
                    return " nextDue=\(due.formatted(.dateTime.year().month().day()))"
                }
                return ""
            }()
            
            let resolvedPart = log.isResolved ? " resolved=yes" : " resolved=no"
            
            out.append(
                "  - \(date) \(cat): \(log.title)\(valuePart)\(dosagePart)\(nextDuePart)\(resolvedPart)"
            )
        }
        
        if logs.count > maxLines {
            out.append(
                "  - (and \(logs.count - maxLines) older items not shown)"
            )
        }
        
        return out
    }
}
