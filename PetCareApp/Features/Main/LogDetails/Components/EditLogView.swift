//
//  EditLogView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 13.01.26.
//


import SwiftUI

struct EditLogView: View {
    // MARK: - Properties
    
    @Environment(\.dismiss) var dismiss
    
    @State private var editedLog: HealthLog
    @State private var date: Date
    @State private var note: String
    @State private var valueString: String
    @State private var dosage: String
    
    var onSave: (Date, String, String, String) -> Void
    var onDelete: () -> Void
    
    private var isHistory: Bool { editedLog.isResolved }
    
    // MARK: - Initializer
    
    init(log: HealthLog,
         onSave: @escaping (Date, String, String, String) -> Void,
         onDelete: @escaping () -> Void
    ) {
        _editedLog = State(initialValue: log)
        _date = State(initialValue: log.date)
        _note = State(initialValue: log.note ?? "")
        _valueString = State(initialValue: log.value.map { String($0) } ?? "")
        _dosage = State(initialValue: log.dosage ?? "")
        
        self.onSave = onSave
        self.onDelete = onDelete
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeaderView(text: "Time & Date")
                        
                        DatePicker(
                            "Date",
                            selection: $date,
                            in: isHistory ? Date.distantPast...Date() : Date()...Date.distantFuture,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .borderedSection()
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeaderView(text: "Details")
                        
                        VStack(spacing: 16) {
                            
                            if editedLog.category == .weight {
                                PrimaryTextField(
                                    title: "Weight (kg)",
                                    placeholder: "0.0",
                                    text: $valueString,
                                    keyboardType: .decimalPad
                                )
                            }
                            
                            if editedLog.category == .medication {
                                PrimaryTextField(
                                    title: "Dosage",
                                    placeholder: "e.g. 1 pill, 5ml",
                                    text: $dosage
                                )
                            }
                            
                            PrimaryTextField(
                                title: "Note",
                                placeholder: "Add a note...",
                                text: $note
                            )
                        }
                    }
                    
                    Button(action: {
                        onDelete()
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Log")
                        }
                        .foregroundColor(.error)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.error.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle(isHistory ? "Edit History" : "Reschedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(date, note, valueString, dosage)
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}
