
import SwiftUI

struct AdminViewCachedLocations: View {
    @Binding var selectedView: Int
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: EventViewModel = EventViewModel()
    @StateObject var cacheViewModel: CacheViewModel = CacheViewModel()
    let tabLinkItems: [String] = ["Locations", "Items"]
    @State private var selectedLink: String = "Locations"
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible())]

    func loadPlaces() {
        viewModel.getCachedGooglelocations()
        cacheViewModel.getCachedItems()
    }
    
    var body: some View {
        VStack {
            
            HStack {
                Spacer()
                Image(systemName: "x.circle")
                    .font(.largeTitle)
                    .foregroundColor(.wbPinkMedium)
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }
            }
            .padding()
            
            LazyVGrid(columns: columns) {
                ForEach(tabLinkItems, id: \.self) { link in
                    Text(link.uppercased())
                        .font(.custom("Satoshi-Bold", size: 13))
                        .padding(7)
                        .background(
                            self.selectedLink == link ? Color.wbPinkMedium : Color.clear
                        )
                        .foregroundColor(
                            self.selectedLink == link ? Color.white : Color.black
                        )
                        .cornerRadius(5)
                        .onTapGesture {
                            self.selectedLink = link
                        }
                }
            }
            .padding(7)
            .cardStyle(.white)
            
            if self.selectedLink == "Locations" {
                
                Form {
                    Section(header: Text("Admin Cached Locations View")) {
                        ForEach(Array(viewModel.cachedGoogleLocations.reversed().enumerated()), id: \.element) { index, place in
                            VStack {
                                Text("\(index + 1) - \(place.result.name)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(place.result.formattedAddress)
                                    .foregroundColor(.gray)
                                    .font(.caption)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        Divider()
                    }
                }
                
            } else {
                
                Form {
                    Section(header: Text("Cached items")) {
                        ForEach(Array(cacheViewModel.cachedItems.reversed().enumerated()), id: \.element) { index, item in
                            VStack {
                                Text("\(index + 1) - \(item.name)")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(item.content)
                                    .foregroundColor(.gray)
                                    .font(.caption)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(basicDateTime(item.date))")
                                    .foregroundColor(.black)
                                    .font(.caption)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        Divider()
                    }
                }
            }
        }
        .onAppear {
            self.loadPlaces()
        }
    }
}
