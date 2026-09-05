import SwiftUI

struct GalleryView: View {
    @Binding var navigationPath: NavigationPath
    @State private var selectedFilter = "All"
    let filters = ["All", "Favorites", "4 Cut", "Film"]
    
    var filteredItems: [GalleryItem] {
        if selectedFilter == "Favorites" {
            return MockData.galleryItems.filter { $0.isFavorite }
        } else if selectedFilter != "All" {
            return MockData.galleryItems.filter { $0.templateName == selectedFilter }
        }
        return MockData.galleryItems
    }
    
    var body: some View {
        ZStack {
            TAROColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: TAROSpacing.sm) {
                        ForEach(filters, id: \.self) { filter in
                            TAROChip(
                                title: filter,
                                isSelected: selectedFilter == filter
                            ) {
                                selectedFilter = filter
                            }
                        }
                    }
                    .padding(.horizontal, TAROSpacing.md)
                    .padding(.vertical, TAROSpacing.md)
                }
                
                // Grid
                if filteredItems.isEmpty {
                    EmptyStateView(
                        icon: TAROIcons.gallery,
                        title: "No Photos Yet",
                        message: "Your saved photobooth sessions will appear here."
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: TAROSpacing.md) {
                            ForEach(filteredItems) { item in
                                Button(action: {
                                    navigationPath.append(AppRoute.galleryDetail(item.id))
                                }) {
                                    GalleryCard(item: item)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(TAROSpacing.md)
                    }
                }
            }
        }
        .navigationTitle("My Gallery")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GalleryCard: View {
    let item: GalleryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: TAROSpacing.xs) {
            Rectangle()
                .fill(TAROColors.cream)
                .aspectRatio(2/3, contentMode: .fit)
                .cornerRadius(TARORadius.md)
                .overlay(
                    VStack {
                        HStack {
                            Spacer()
                            if item.isFavorite {
                                Image(systemName: TAROIcons.heart)
                                    .foregroundColor(TAROColors.primaryPink)
                                    .padding(8)
                            }
                        }
                        Spacer()
                    }
                )
            
            Text(item.templateName)
                .font(TAROTypography.subtitle)
                .foregroundColor(TAROColors.text)
            
            Text(item.date, style: .date)
                .font(TAROTypography.caption)
                .foregroundColor(TAROColors.gray)
        }
    }
}

#Preview {
    GalleryView(navigationPath: .constant(NavigationPath()))
}
