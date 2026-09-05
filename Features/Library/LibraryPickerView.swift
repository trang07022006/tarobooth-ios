import SwiftUI
import PhotosUI

struct LibraryPickerView: View {
    @Binding var navigationPath: NavigationPath
    @Binding var currentSession: BoothSession
    
    // Mock selection state (Windows / preview fallback)
    @State private var selectedPhotoIDs: [Int] = []
    
    // Native iOS PhotosPicker state
    @State private var selectedPickerItems: [PhotosPickerItem] = []
    @State private var isImporting = false
    @State private var importErrorMessage: String? = nil
    
    init(navigationPath: Binding<NavigationPath>, currentSession: Binding<BoothSession> = .constant(BoothSession())) {
        self._navigationPath = navigationPath
        self._currentSession = currentSession
    }
    
    private var isReplacementMode: Bool {
        currentSession.pendingReplacementPhotoID != nil
    }
    
    private var requiredPhotos: Int {
        isReplacementMode ? 1 : (currentSession.selectedTemplate?.photoCount ?? 4)
    }
    
    var body: some View {
        ZStack {
            TAROColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Custom Header
                topHeader
                    .padding(.top, TAROSpacing.xs)
                    .padding(.horizontal, TAROSpacing.lg)
                
                // Selection Counter Banner
                counterBanner
                    .padding(.top, TAROSpacing.xs)
                    .padding(.bottom, TAROSpacing.xs)
                
                // Native PhotosPicker Primary Action
                photosPickerButton
                    .padding(.horizontal, TAROSpacing.lg)
                    .padding(.bottom, TAROSpacing.xs)
                
                // Status / Error Banner
                if isImporting {
                    HStack(spacing: TAROSpacing.xs) {
                        ProgressView()
                            .tint(TAROColors.strongPink)
                        Text("Importing photos...")
                            .font(TAROTypography.caption)
                            .foregroundColor(TAROColors.text)
                    }
                    .padding(.vertical, 4)
                } else if let error = importErrorMessage {
                    Text(error)
                        .font(TAROTypography.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, TAROSpacing.md)
                        .padding(.vertical, 2)
                }
                
                // Photo Grid (Fallback & Quick Mock Tap)
                ScrollView {
                    PhotoSelectionGrid(
                        selectedItems: $selectedPhotoIDs,
                        requiredCount: requiredPhotos
                    )
                    .padding(.horizontal, TAROSpacing.md)
                    .padding(.top, TAROSpacing.xs)
                }
                
                // Bottom Area: Tray / Replacement Action
                if isReplacementMode {
                    replacementBottomBar
                } else {
                    SelectedPhotoTray(
                        selectedItems: selectedPhotoIDs,
                        requiredCount: requiredPhotos,
                        onRemove: { item in
                            selectedPhotoIDs.removeAll(where: { $0 == item })
                        },
                        onContinue: commitSelectionToSession
                    )
                }
            }
            .frame(maxWidth: 650)
            .frame(maxWidth: .infinity)
        }
        .navigationBarHidden(true)
        .disabled(isImporting)
        .onAppear {
            restoreSelectionFromSessionIfNeeded()
        }
        .onChange(of: selectedPickerItems) {
            Task {
                await importSelectedPickerItems()
            }
        }
    }
    
    // MARK: - Native PhotosPicker Button
    
    private var photosPickerButton: some View {
        PhotosPicker(
            selection: $selectedPickerItems,
            maxSelectionCount: requiredPhotos,
            selectionBehavior: .ordered,
            matching: .images
        ) {
            HStack(spacing: TAROSpacing.xs) {
                Image(systemName: "photo.stack.fill")
                    .font(.system(size: 15, weight: .bold))
                Text(isReplacementMode ? "CHOOSE REPLACEMENT FROM LIBRARY" : "CHOOSE FROM PHOTO LIBRARY")
                    .font(TAROTypography.button)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(TAROColors.strongPink)
            .cornerRadius(TARORadius.pill)
            .applyTAROShadow(.medium)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Header
    
    private var topHeader: some View {
        HStack {
            Button(action: handleBackAction) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(TAROColors.text)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())
                    .applyTAROShadow(.soft)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            VStack(spacing: 2) {
                Text(isReplacementMode ? "Replace Photo" : "Choose photos")
                    .font(TAROTypography.heading2)
                    .foregroundColor(TAROColors.text)
                
                Text(isReplacementMode ? "Choose 1 photo to replace target." : "Select photos for your booth.")
                    .font(TAROTypography.caption)
                    .foregroundColor(TAROColors.text.opacity(0.6))
            }
            
            Spacer()
            
            // Balance 44pt tap target
            Color.clear
                .frame(width: 44, height: 44)
        }
    }
    
    // MARK: - Selection Counter Banner
    
    private var counterBanner: some View {
        HStack(spacing: TAROSpacing.xs) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(TAROColors.strongPink)
            
            if isReplacementMode {
                Text(selectedPhotoIDs.isEmpty ? "0 / 1 selected" : "1 / 1 selected")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(TAROColors.text)
            } else {
                Text("\(selectedPhotoIDs.count) / \(requiredPhotos) selected")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(TAROColors.text)
            }
        }
        .padding(.horizontal, TAROSpacing.md)
        .padding(.vertical, 6)
        .background(Color.white)
        .cornerRadius(TARORadius.pill)
        .applyTAROShadow(.soft)
    }
    
    // MARK: - Replacement Mode Bottom Bar
    
    private var replacementBottomBar: some View {
        VStack(spacing: TAROSpacing.xs) {
            Button(action: performReplacement) {
                Text("REPLACE PHOTO")
                    .font(TAROTypography.button)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(selectedPhotoIDs.count == 1 ? TAROColors.strongPink : Color.gray.opacity(0.4))
                    .cornerRadius(TARORadius.pill)
                    .applyTAROShadow(selectedPhotoIDs.count == 1 ? .medium : .soft)
            }
            .buttonStyle(.plain)
            .disabled(selectedPhotoIDs.count != 1)
            .padding(.horizontal, TAROSpacing.lg)
            .padding(.vertical, TAROSpacing.md)
        }
        .background(Color.white)
        .applyTAROShadow(.medium)
    }
    
    // MARK: - Async PhotosPicker Import
    
    @MainActor
    private func importSelectedPickerItems() async {
        guard !selectedPickerItems.isEmpty else { return }
        guard !isImporting else { return }
        
        isImporting = true
        importErrorMessage = nil
        
        defer {
            isImporting = false
        }
        
        let itemsToProcess = selectedPickerItems
        selectedPickerItems = []
        
        if isReplacementMode {
            guard let item = itemsToProcess.first,
                  let targetID = currentSession.pendingReplacementPhotoID,
                  let targetIdx = currentSession.photos.firstIndex(where: { $0.id == targetID }) else {
                currentSession.pendingReplacementPhotoID = nil
                navigationPath.removeLast()
                return
            }
            
            do {
                guard let data = try await item.loadTransferable(type: Data.self), !data.isEmpty else {
                    importErrorMessage = "Failed to load selected photo."
                    return
                }
                
                let assetKey = try LocalPhotoStore.shared.savePhoto(data: data)
                
                let targetOrder = currentSession.photos[targetIdx].orderIndex
                let replacementPhoto = BoothPhoto(
                    id: UUID().uuidString,
                    source: .library,
                    localIdentifier: item.itemIdentifier ?? "library-\(UUID().uuidString)",
                    assetKey: assetKey,
                    orderIndex: targetOrder,
                    filmPresetID: "original",
                    cropState: PhotoCropState() // Fresh default crop state per Constraint 32
                )
                
                currentSession.photos[targetIdx] = replacementPhoto
                currentSession.pendingReplacementPhotoID = nil
                navigationPath.removeLast() // Return by POP to existing Review
            } catch {
                importErrorMessage = "Failed to load photo: \(error.localizedDescription)"
            }
        } else {
            guard itemsToProcess.count == requiredPhotos else {
                importErrorMessage = "Please select exactly \(requiredPhotos) photos."
                return
            }
            
            var importedPhotos: [BoothPhoto] = []
            var newlySavedKeys: [String] = []
            
            for (index, item) in itemsToProcess.enumerated() {
                do {
                    guard let data = try await item.loadTransferable(type: Data.self), !data.isEmpty else {
                        // Clean up newly written uncommitted files
                        for key in newlySavedKeys {
                            try? LocalPhotoStore.shared.deletePhoto(assetKey: key)
                        }
                        importErrorMessage = "Failed to load one or more photos."
                        return
                    }
                    let assetKey = try LocalPhotoStore.shared.savePhoto(data: data)
                    newlySavedKeys.append(assetKey)
                    
                    let photo = BoothPhoto(
                        id: UUID().uuidString,
                        source: .library,
                        localIdentifier: item.itemIdentifier ?? "library-\(UUID().uuidString)",
                        assetKey: assetKey,
                        orderIndex: index,
                        filmPresetID: "original",
                        cropState: PhotoCropState()
                    )
                    importedPhotos.append(photo)
                } catch {
                    for key in newlySavedKeys {
                        try? LocalPhotoStore.shared.deletePhoto(assetKey: key)
                    }
                    importErrorMessage = "Failed to import photos. Please try again."
                    return
                }
            }
            
            // Atomic commit: all requiredPhotos loaded and saved
            if importedPhotos.count == requiredPhotos {
                currentSession.photos = importedPhotos
                currentSession.normalizePhotoOrder()
                navigationPath.append(AppRoute.arrange)
            } else {
                for key in newlySavedKeys {
                    try? LocalPhotoStore.shared.deletePhoto(assetKey: key)
                }
                importErrorMessage = "Incomplete photo selection."
            }
        }
    }
    
    // MARK: - Actions
    
    private func handleBackAction() {
        if isReplacementMode {
            // Cancel replacement: preserve target photo, clear pending replacement, pop back to Review
            currentSession.pendingReplacementPhotoID = nil
            navigationPath.removeLast()
        } else {
            // Back from normal library picker: return to Source Picker without clearing unrelated session data
            navigationPath.removeLast()
        }
    }
    
    private func commitSelectionToSession() {
        guard selectedPhotoIDs.count == requiredPhotos else { return }
        
        // Convert selected mock library items into BoothPhoto session draft state atomically
        let newPhotos = selectedPhotoIDs.enumerated().map { index, itemID in
            BoothPhoto(
                id: UUID().uuidString,
                source: .library,
                localIdentifier: "mock-library-\(itemID)",
                orderIndex: index,
                filmPresetID: "original"
            )
        }
        currentSession.photos = newPhotos
        currentSession.normalizePhotoOrder()
        navigationPath.append(AppRoute.arrange)
    }
    
    private func performReplacement() {
        guard let selectedItem = selectedPhotoIDs.first,
              let targetID = currentSession.pendingReplacementPhotoID,
              let targetIdx = currentSession.photos.firstIndex(where: { $0.id == targetID }) else {
            currentSession.pendingReplacementPhotoID = nil
            navigationPath.removeLast()
            return
        }
        
        let targetOrder = currentSession.photos[targetIdx].orderIndex
        let replacementPhoto = BoothPhoto(
            id: UUID().uuidString,
            source: .library,
            localIdentifier: "mock-library-\(selectedItem)",
            orderIndex: targetOrder,
            filmPresetID: "original"
        )
        
        currentSession.photos[targetIdx] = replacementPhoto
        currentSession.pendingReplacementPhotoID = nil
        navigationPath.removeLast() // Return by POP to existing Review
    }
    
    private func restoreSelectionFromSessionIfNeeded() {
        guard !isReplacementMode else { return }
        if !currentSession.photos.isEmpty && currentSession.photos.allSatisfy({ $0.source == .library }) {
            var reconstructed: [Int] = []
            for photo in currentSession.photos {
                let idString: String
                if photo.localIdentifier.hasPrefix("mock-library-") {
                    idString = String(photo.localIdentifier.dropFirst("mock-library-".count))
                } else if photo.localIdentifier.hasPrefix("lib_") {
                    idString = String(photo.localIdentifier.dropFirst("lib_".count))
                } else {
                    idString = photo.localIdentifier
                }
                if let itemID = Int(idString), !reconstructed.contains(itemID) {
                    reconstructed.append(itemID)
                }
            }
            if !reconstructed.isEmpty {
                selectedPhotoIDs = reconstructed
            }
        }
    }
}

#Preview {
    LibraryPickerView(
        navigationPath: .constant(NavigationPath()),
        currentSession: .constant(BoothSession())
    )
}
