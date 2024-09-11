//
//  ContentView.swift
//  VoiceMemo
//
//  Created by Joaquim Pessoa Filho on 11/09/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var memos: [Memo]
    @State private var isPlayingIndex = -1
    @State var viewModel = AudioRecordViewModel()

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(memos) { memo in
                    let index = getIndex(memo: memo)
                    Button {
                        if isPlayingIndex == index {
                            viewModel.stopPlaying()
                            viewModel.reset()
                        } else if isPlayingIndex == -1 {
                            viewModel.startPlaying(audioData: memo.audioData)
                            isPlayingIndex = index
                        }
                    } label: {
                        HStack {
                            Text(memo.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                            Spacer()
                            Label("", systemImage: isPlayingIndex == index ? "stop": "play")
                                .font(.largeTitle)
                        }
                    }
                    .saturation(isPlayingIndex != -1 && isPlayingIndex != index ? 0 : 1)
                    .disabled(isPlayingIndex != -1 && isPlayingIndex != index)
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .disabled(isPlayingIndex != -1)
                }
                ToolbarItem {
                    NavigationLink {
                        RecordMemoView()
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                    .disabled(isPlayingIndex != -1)
                }
            }
            .onChange(of: viewModel.isPlaying) { _, _ in
                if !viewModel.isPlaying {
                    isPlayingIndex = -1
                }
            }
        } detail: {
            Text("Select an item")
        }
        .environment(viewModel)
    }

    private func addItem() {
        withAnimation {
            let newItem = Memo(audioData: Data())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(memos[index])
            }
        }
    }
    
    private func getIndex(memo: Memo) -> Int {
        for i in 0..<memos.count {
            if memos[i] == memo {
                return i
            }
        }
        return -1
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Memo.self, inMemory: true)
}
