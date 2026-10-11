import SwiftUI

public struct SoundscapeOption: Identifiable {
    public let id = UUID()
    public let title: String
    public let subtitle: String
    public let icon: String
}

public struct SoundscapeSheetView: View {
    @Binding var selectedSoundscape: String
    @Environment(\.dismiss) private var dismiss
    
    let soundscapes: [SoundscapeOption] = [
        SoundscapeOption(title: "Alpha Waves 432Hz", subtitle: "Deep focus, clarity & relaxed alertness", icon: "waveform"),
        SoundscapeOption(title: "Deep Space Drone • Pink Noise", subtitle: "Consistent acoustic insulation", icon: "moon.stars.fill"),
        SoundscapeOption(title: "Rain on Forest Leaves", subtitle: "Gentle natural white noise", icon: "cloud.rain.fill"),
        SoundscapeOption(title: "Binaural High Flow State", subtitle: "Enhanced concentration theta waves", icon: "headphones"),
        SoundscapeOption(title: "Obsidian Silence", subtitle: "No audio playback", icon: "speaker.slash.fill")
    ]
    
    public var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Select Soundscape")
                    .font(PomoloTypography.headlineLarge(22))
                    .foregroundColor(Color.pomoloTextPrimary)
                    .padding(.top, 16)
                
                ForEach(soundscapes) { item in
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        selectedSoundscape = item.title
                        dismiss()
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(selectedSoundscape == item.title ? Color.pomoloOrange : Color.pomoloPeach.opacity(0.4))
                                    .frame(width: 40, height: 40)
                                Image(systemName: item.icon)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(selectedSoundscape == item.title ? .white : Color.pomoloTextPrimary)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(PomoloTypography.headlineSmall(14))
                                    .foregroundColor(Color.pomoloTextPrimary)
                                Text(item.subtitle)
                                    .font(PomoloTypography.bodyMedium(12))
                                    .foregroundColor(Color.pomoloTextSecondary)
                            }
                            
                            Spacer()
                            
                            if selectedSoundscape == item.title {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color.pomoloOrange)
                                    .font(.system(size: 18))
                            }
                        }
                        .padding(12)
                        .background(Color.pomoloCard)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(selectedSoundscape == item.title ? Color.pomoloOrange : Color.pomoloBorder, lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .background(Color.pomoloCanvas.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(PomoloTypography.headlineSmall(15))
                    .foregroundColor(Color.pomoloOrange)
                }
            }
        }
    }
}
