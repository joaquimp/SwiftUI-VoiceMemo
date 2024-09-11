//
//  RecordMemoView.swift
//  VoiceMemo
//
//  Created by Joaquim Pessoa Filho on 11/09/24.
//

import SwiftUI

struct RecordMemoView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AudioRecordViewModel.self) var viewModel
    
    var body: some View {
        VStack {
            Text("Gravador")
            
            Spacer()
            
            VStack(spacing: 16) {
                VStack {
                    Text("Tempo de gravação")
                    Text(viewModel.recordTime)
                        .monospaced()
                }
                
                HStack {
                    Button(action: {
                        startStopRecord()
                    }, label: {
                        Label("", systemImage: viewModel.isRecording ? "recordingtape.circle.fill" : "recordingtape.circle").font(.largeTitle)
                    })
                    .disabled(viewModel.isPlaying)
                    
                    Button(action: {
                        playStop()
                    }, label: {
                        Label("", systemImage: viewModel.isPlaying ? "stop": "play")
                            .font(.largeTitle)
                    })
                    .disabled(viewModel.isRecording || !viewModel.hasAudio)
                }
                
                Button(action: {
                    saveAudio()
                }, label: {
                    Text("Salvar")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 16.0))
                })
                .disabled(viewModel.isRecording || viewModel.isPlaying || !viewModel.hasAudio)
            }
            
            Spacer()
        }
    }
    
    private func startStopRecord() {
        if viewModel.isRecording {
            viewModel.stopRecording()
        } else {
            viewModel.startRecording()
        }
    }
    
    private func playStop() {
        if viewModel.isPlaying {
            viewModel.stopPlaying()
        } else {
            viewModel.startPlaying()
        }
    }
    
    private func saveAudio() {
        guard let audioData = viewModel.getAudioData() else {
            print("problema ao obter dados do audio")
            return
        }
        let memo = Memo(audioData: audioData)
        modelContext.insert(memo)
        viewModel.reset()
        dismiss()
    }
}

#Preview {
    RecordMemoView()
        .environment(AudioRecordViewModel())
}
