
import SwiftUI

struct AddNewDestinationView: View {
    @StateObject private var viewModel = AddNewDestinationViewModel()
    @StateObject var placesViewModel: PlacesViewModel = PlacesViewModel()
    @State private var showMenu = false
    @Environment(\.presentationMode) var presentationMode
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible())]
    
    var onDataReceive: ((GooglePlace)) -> Void
    @State private var settingsDetent = PresentationDetent.medium

    @FocusState private var isInputActive: Bool
    @State private var searchCity = ""
    @State private var selectedCity: PlaceWithPhoto?
    
    private var alertMessage: String {
        return "Set your destination as \(self.searchCity)? "
    }
    
    func passSelectedCity(_ f: PlaceWithPhoto) {
        onDataReceive(f.googlePlace)
        presentationMode.wrappedValue.dismiss()
    }
    
    func addToWishList(_ f: PlaceWithPhoto) {
        self.viewModel.cachePlace(f.googlePlace, catalog: .wishlist)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    CityTitleBannerView(cityName: "Add New, Destination")
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 20, alignment: .leading)
                }
                .padding()
                .background(
                    Image("destination_placeholder")
                )
                .cardStyle()
                
                TextField("Where to?", text: $viewModel.query)
                    .focused($isInputActive)
                    .font(.headline)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(24)
                    .overlay(
                        HStack {
                            Spacer()
                            if !searchCity.isEmpty || !viewModel.query.isEmpty {
                                Button(action: clearText) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .font(.largeTitle)
                                }
                                .padding(.trailing, 10)
                            }
                        }
                    )
                    .padding(7)
                
                VStack {
                    ForEach(viewModel.suggestions, id: \.self) { suggestion in
                        HStack {
                            Image(suggestion.description.split(separator: ",").map(String.init).last?.replacingOccurrences(of: " ", with: "") ?? "")
                                .resizable()
                                .frame(width: 26, height: 18)
                            
                            Text(suggestion.description)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 20, alignment: .leading)
                        }
                        .onTapGesture {
                            self.searchCity = suggestion.description
                            isInputActive = false
                            viewModel.selectSuggestion(suggestion)
                        }
                        Divider()
                    }
                }
                .frame(height: isInputActive == false || viewModel.suggestions.count == 0 || viewModel.query.isEmpty ? 0 : 120)
                .padding()
                .isHidden(isInputActive == false)
                
                // Cached Wished List
                if !viewModel.cachedTilesWishlist.isEmpty {
                    VStack {
                        HeaderHero(headline: "My Wishlist")
                            .padding(.leading, 13)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(viewModel.cachedTilesWishlist) { f in
                                    LocationCardRecentSearch(f: f)
                                }
                            }
                        }
                        .frame(height: 200)
                        .padding(.bottom, 50)
                    }
                    .isHidden(isInputActive == true)
                }
                    
                // Cached Recent Searched Places
                if !viewModel.cachedTilesRecentSearches.isEmpty {
                    VStack {
                        HeaderHero(headline: "Recent Searches")
                            .padding(.leading, 13)
                        LazyVGrid(columns: columns) {
                            ForEach(viewModel.cachedTilesRecentSearches) { f in
                                LocationCardRecentSearch(f: f)
                                    .onTapGesture {
                                        self.selectedCity = f
                                        showMenu.toggle()
                                    }
                            }
                        }
                    }
                    .isHidden(isInputActive == true)
                }
            }
            .opacity(showMenu ? 0.02 : 1.0)
            .onAppear{
                viewModel.getCachedSearchedPlaces()
                viewModel.getCachedWishlistPlaces()
            }
            .sheet(isPresented: $showMenu) {
                if let city = selectedCity {
                    LocationLinkMenu(
                        f: city,
                        passToParentSearched: passSelectedCity,
                        passToParentWishlist: addToWishList
                    )
                }
            }
            .onChange(of: viewModel.selectedLocation) { _, newLocation in
                guard let city = newLocation else { return }
                self.selectedCity = city
                showMenu = true
            }
            .navigationBarTitle("", displayMode: .inline)
        }
    }
    
    private func clearText() {
        searchCity = ""
        viewModel.resetSearch()
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct LocationLinkMenu: View {
    var f: PlaceWithPhoto
    @Environment(\.presentationMode) var presentationMode
    var passToParentSearched: ((PlaceWithPhoto)) -> Void
    var passToParentWishlist: ((PlaceWithPhoto)) -> Void

    var body: some View {
        VStack {
            LocationCardRecentSearch(f: f)
            VStack {
                TLButton(.green, title: "Add as a New Trip")
                    .onTapGesture {
                        passToParentSearched(f)
                    }
                TLButton(.orange, title: "Add to Wishlist")
                    .onTapGesture {
                        passToParentWishlist(f)
                        presentationMode.wrappedValue.dismiss()
                    }
                TLButton(.plain, title: "Cancel")
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }
            }
            .padding()
        }
        .presentationDetents([.medium])

    }
}
