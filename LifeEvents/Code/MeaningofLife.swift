//
//  MeaningofLife.swift
//  LifeEvents
//
//  Created by Quinn Von on 2024/3/9.
//

import SwiftUI
import SwiftData

struct MeaningofLife: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    @Binding var meaning: String
    @Query private var meanings: [Meaning]
    let placeholder = "Enter text here"
    var body: some View {
        
        VStack {
            List{
                HStack {
                    TextEditor(text: $meaning)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
                        .font(.title2)
                        .padding()
                        .zIndex(1) // 将 TextEditor 提升到更高的层级
                    
                }
            }
        }
        .toolbar {
            ToolbarItem {
                Button(action: {
                    if meaning.isEmpty {
                        let item = Meaning(content: meaning)
                        modelContext.insert(item)
                    } else {
                        meanings.first?.content = meaning
                    }
                    // 返回上一个视图
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text(meaning.isEmpty ? "Add" : "Update")
                }
                .disabled(meaning.isEmpty)
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        
    }
}
