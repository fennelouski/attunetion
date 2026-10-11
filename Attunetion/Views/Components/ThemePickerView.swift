//
//  ThemePickerView.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import SwiftUI
import SwiftData

struct ThemePickerView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedTheme: IntentionTheme?
    @State private var isGeneratingAITheme = false
    let intentionText: String
    let modelContext: ModelContext
    @ObservedObject var themeManager: AppThemeManager
    let onAIGenerate: () async -> Void
    var maxUnsplashThemes: Int = 5
    var currentUnsplashThemeCount: Int = 0
    
    @State private var presetThemes: [IntentionTheme] = []
    @State private var curatedPhotos: [CuratedPhoto] = []
    @State private var isLoadingPhotos = false
    @State private var photoLoadError: String?
    
    init(
        selectedTheme: Binding<IntentionTheme?>,
        intentionText: String,
        modelContext: ModelContext,
        themeManager: AppThemeManager,
        onAIGenerate: @escaping () async -> Void,
        maxUnsplashThemes: Int = 5,
        currentUnsplashThemeCount: Int = 0
    ) {
        self._selectedTheme = selectedTheme
        self.intentionText = intentionText
        self.modelContext = modelContext
        self.themeManager = themeManager
        self.onAIGenerate = onAIGenerate
        self.maxUnsplashThemes = maxUnsplashThemes
        self.currentUnsplashThemeCount = currentUnsplashThemeCount
    }

    /// When true (unlock key valid), user can add unlimited Unsplash themes.
    @State private var unlimitedUnsplashThemes: Bool = false

    private var canAddUnsplashTheme: Bool {
        unlimitedUnsplashThemes || currentUnsplashThemeCount < maxUnsplashThemes
    }

    /// First curated photo whose suggested_theme_name matches the preset (e.g. "Serene").
    private func suggestedPhoto(forPresetName name: String) -> CuratedPhoto? {
        curatedPhotos.first { (($0.suggested_theme_name ?? "").lowercased() == name.lowercased()) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "Choose Theme"))
                .font(.system(size: 17, weight: .semibold, design: .default))
                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
            
            // Preset themes grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(presetThemes, id: \.id) { theme in
                    VStack(spacing: 8) {
                        ThemeCard(
                            theme: theme,
                            isSelected: selectedTheme?.id == theme.id,
                            themeManager: themeManager
                        ) {
                            selectedTheme = theme
                        }
                        // Suggested photo for this preset (when curated has a match)
                        if let photo = suggestedPhoto(forPresetName: theme.name), canAddUnsplashTheme {
                            Button(action: { selectPhotoTheme(photo) }) {
                                HStack(spacing: 6) {
                                    if let url = APIClient.shared.imageProxyURL(photoId: photo.unsplash_photo_id) {
                                        AsyncImage(url: url) { phase in
                                            if case .success(let img) = phase {
                                                img.resizable().aspectRatio(contentMode: .fill)
                                            } else {
                                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                    .fill(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.2))
                                            }
                                        }
                                        .frame(width: 28, height: 28)
                                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                    }
                                    Text("Photo")
                                        .font(.system(size: 10, weight: .medium, design: .default))
                                        .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.12))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            // Photos (curated Unsplash) section - only when backend available
            if BackendHealthManager.shared.isBackendAvailable {
                photosSection
            }
            
            // AI Generate button - only show if backend is available
            if BackendHealthManager.shared.isBackendAvailable {
                Button(action: {
                    #if os(iOS)
                    HapticFeedback.light()
                    #endif
                    Task {
                        isGeneratingAITheme = true
                        await onAIGenerate()
                        isGeneratingAITheme = false
                    }
                }) {
                    HStack {
                        if isGeneratingAITheme {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                        } else {
                            Image(systemName: "target")
                        }
                        Text(String(localized: "Generate AI Theme"))
                            .font(.system(size: 15, weight: .medium, design: .default))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.15))
                    )
                    .foregroundColor(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                }
                .disabled(isGeneratingAITheme)
            }
        }
        .onAppear {
            loadPresetThemes()
            loadCuratedPhotos()
            loadImagesAccess()
        }
    }

    @ViewBuilder
    private var photosSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "Photos"))
                .font(.system(size: 15, weight: .semibold, design: .default))
                .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())

            if !canAddUnsplashTheme {
                Text("You've reached the limit of \(maxUnsplashThemes) photo themes. Change or remove one to add another.")
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
            } else if isLoadingPhotos {
                HStack {
                    ProgressView()
                        .scaleEffect(0.9)
                        .tint(themeManager.accentColor(for: colorScheme).toSwiftUIColor())
                    Text(String(localized: "Loading photos…"))
                        .font(.system(size: 13, weight: .regular, design: .default))
                        .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            } else if let error = photoLoadError {
                Text(error)
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
            } else if curatedPhotos.isEmpty {
                Text(String(localized: "No photos available right now."))
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(curatedPhotos, id: \.id) { photo in
                        PhotoThemeCard(
                            photo: photo,
                            themeManager: themeManager,
                            colorScheme: colorScheme,
                            isSelected: selectedTheme?.unsplashPhotoId == photo.unsplash_photo_id
                        ) {
                            selectPhotoTheme(photo)
                        }
                    }
                }
            }
        }
    }
    
    private func loadPresetThemes() {
        Task { @MainActor in
            let themeRepo = ThemeRepository(modelContext: modelContext)
            presetThemes = themeRepo.getPresetThemes()
            if presetThemes.isEmpty {
                try? PresetThemes.populatePresetThemes(in: themeRepo)
                presetThemes = themeRepo.getPresetThemes()
            }
        }
    }

    private func loadCuratedPhotos() {
        guard canAddUnsplashTheme || curatedPhotos.isEmpty else { return }
        isLoadingPhotos = true
        photoLoadError = nil
        Task { @MainActor in
            do {
                let response = try await APIClient.shared.fetchCuratedPhotos(page: 1, perPage: 30)
                curatedPhotos = response.photos
            } catch {
                photoLoadError = error.localizedDescription
                curatedPhotos = []
            }
            isLoadingPhotos = false
        }
    }

    private func loadImagesAccess() {
        Task { @MainActor in
            guard BackendHealthManager.shared.isBackendAvailable else { return }
            if let access = try? await APIClient.shared.fetchImagesAccess() {
                unlimitedUnsplashThemes = access.unlimitedThemes
                if access.unlimitedThemes {
                    submitStablePhotosIfEligible()
                }
            }
        }
    }

    /// If user has unlock key, find intentions with Unsplash theme unchanged 7+ days and submit for curation.
    private func submitStablePhotosIfEligible() {
        Task { @MainActor in
            let intentionRepo = IntentionRepository(modelContext: modelContext)
            let themeRepo = ThemeRepository(modelContext: modelContext)
            let all = intentionRepo.getAll()
            let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            var items: [FromStablePhotoItem] = []
            for intention in all {
                guard let themeId = intention.themeId,
                      let setAt = intention.themeSetAt,
                      setAt <= sevenDaysAgo,
                      let theme = themeRepo.getTheme(byId: themeId),
                      let pid = theme.unsplashPhotoId, !pid.isEmpty,
                      let attText = theme.attributionText,
                      let attURL = theme.attributionURL,
                      let downloadLoc = theme.unsplashDownloadLocation,
                      let imageURL = theme.backgroundImageURL else { continue }
                items.append(FromStablePhotoItem(
                    unsplash_photo_id: pid,
                    image_url: imageURL,
                    attribution_text: attText,
                    attribution_url: attURL,
                    download_location: downloadLoc,
                    color: nil
                ))
            }
            guard !items.isEmpty else { return }
            try? await APIClient.shared.submitStablePhotosForCuration(items)
        }
    }

    private func selectPhotoTheme(_ photo: CuratedPhoto) {
        guard canAddUnsplashTheme else { return }
        #if os(iOS)
        HapticFeedback.light()
        #endif

        let proxyURL = APIClient.shared.imageProxyURL(photoId: photo.unsplash_photo_id)?.absoluteString ?? photo.image_url
        let theme = IntentionTheme(
            name: String(localized: "Photo"),
            backgroundColor: "#1A1A1A",
            textColor: "#FFFFFF",
            accentColor: "#FFFFFF",
            isPreset: false,
            isAIGenerated: false,
            backgroundImageURL: proxyURL,
            unsplashPhotoId: photo.unsplash_photo_id,
            unsplashDownloadLocation: photo.download_location,
            attributionText: photo.attribution_text,
            attributionURL: photo.attribution_url
        )

        let repo = ThemeRepository(modelContext: modelContext)
        do {
            try repo.create(theme)
            Task {
                try? await APIClient.shared.triggerUnsplashDownload(
                    unsplashPhotoId: photo.unsplash_photo_id,
                    downloadLocation: photo.download_location
                )
            }
            selectedTheme = theme
        } catch {
            photoLoadError = error.localizedDescription
        }
    }
}

struct ThemeCard: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeManager: AppThemeManager
    let theme: IntentionTheme
    let isSelected: Bool
    let action: () -> Void
    
    init(theme: IntentionTheme, isSelected: Bool, themeManager: AppThemeManager, action: @escaping () -> Void) {
        self.theme = theme
        self.isSelected = isSelected
        self.themeManager = themeManager
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            #if os(iOS)
            HapticFeedback.light()
            #endif
            action()
        }) {
            VStack(spacing: 8) {
                // Preview: image or color gradient
                Group {
                    if let urlString = theme.backgroundImageURL, let url = URL(string: urlString), !urlString.isEmpty {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure, .empty:
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [theme.backgroundColorValue, theme.accentColorValue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            @unknown default:
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(theme.backgroundColorValue)
                            }
                        }
                        .frame(height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    } else {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [theme.backgroundColorValue, theme.accentColorValue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 60)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(
                            isSelected
                                ? themeManager.accentColor(for: colorScheme).toSwiftUIColor()
                                : themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.2),
                            lineWidth: isSelected ? 3 : 1
                        )
                )
                .shadow(
                    color: isSelected
                        ? themeManager.accentColor(for: colorScheme).toSwiftUIColor().opacity(0.3)
                        : .clear,
                    radius: isSelected ? 8 : 0,
                    x: 0,
                    y: isSelected ? 4 : 0
                )
                
                Text(theme.name)
                    .font(.system(size: 12, weight: .medium, design: .default))
                    .foregroundColor(themeManager.primaryTextColor(for: colorScheme).toSwiftUIColor())
                    .lineLimit(1)

                if let attribution = theme.attributionText, !attribution.isEmpty {
                    Text(attribution)
                        .font(.system(size: 9, weight: .regular, design: .default))
                        .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                        .lineLimit(1)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct PhotoThemeCard: View {
    let photo: CuratedPhoto
    @ObservedObject var themeManager: AppThemeManager
    let colorScheme: ColorScheme
    let isSelected: Bool
    let action: () -> Void

    private var thumbURL: URL? {
        APIClient.shared.imageProxyURL(photoId: photo.unsplash_photo_id)
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Group {
                    if let url = thumbURL {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure, .empty:
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.2))
                            @unknown default:
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.2))
                            }
                        }
                        .frame(height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    } else {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.2))
                            .frame(height: 60)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(
                            isSelected
                                ? themeManager.accentColor(for: colorScheme).toSwiftUIColor()
                                : themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor().opacity(0.2),
                            lineWidth: isSelected ? 3 : 1
                        )
                )

                Text(photo.attribution_text)
                    .font(.system(size: 9, weight: .regular, design: .default))
                    .foregroundColor(themeManager.secondaryTextColor(for: colorScheme).toSwiftUIColor())
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var selected: IntentionTheme? = nil
    let container = try! ModelContainer(for: IntentionTheme.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = container.mainContext
    ThemePickerView(
        selectedTheme: $selected,
        intentionText: "Be present with family",
        modelContext: context,
        themeManager: AppThemeManager()
    ) {
        // Mock AI generation
    }
    .padding()
    .modelContainer(container)
    .environmentObject(BackendHealthManager.shared)
}
