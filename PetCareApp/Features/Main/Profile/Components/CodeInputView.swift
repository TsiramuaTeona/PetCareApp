//
//  CodeInputView.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 06.01.26.
//

import SwiftUI

struct CodeInputView: View {
    // MARK: - Properties
    
    @Binding var code: String
    var length: Int = 6
    
    @FocusState private var isFocused: Bool
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            TextField("", text: $code)
                .textContentType(.oneTimeCode)
                .focused($isFocused)
                .frame(width: 1, height: 1)
                .opacity(0.001)
                .textInputAutocapitalization(.characters)
                .onChange(of: code) { _, newValue in
                    limitText(newValue)
                }
            
            HStack(spacing: 10) {
                ForEach(0..<length, id: \.self) { index in
                    boxView(at: index)
                        .onTapGesture {
                            isFocused = true
                        }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func boxView(at index: Int) -> some View {
        let char = getChar(at: index)
        let isCurrentIndex = (index == code.count) || (index == length - 1 && code.count == length)
        
        return Text(char)
            .font(.appButton)
            .foregroundColor(.textPrimary)
            .frame(maxWidth: .infinity, minHeight: 42)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isFocused && isCurrentIndex
                        ? Color.brandSecondary
                        : Color.textSecondary.opacity(0.4),
                        lineWidth: 1
                    )
            )
    }
    
    private func getChar(at index: Int) -> String {
        if index < code.count {
            let start = code.index(code.startIndex, offsetBy: index)
            return String(code[start])
        }
        return ""
    }
    
    private func limitText(_ newValue: String) {
        let filtered = newValue.filter { $0.isLetter || $0.isNumber }
        
        if filtered.count > length {
            code = String(filtered.prefix(length))
        } else if filtered != newValue {
            code = filtered
        }
    }
}
