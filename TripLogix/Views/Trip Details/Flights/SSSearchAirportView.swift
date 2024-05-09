
import SwiftUI

struct SearchAirportsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: SearchAirportViewModel = SearchAirportViewModel()
    @StateObject var flightsViewModel: SSFlightsViewModel = SSFlightsViewModel()

    @State private var searchText: String = ""
    @State private var globalSearchText: String = ""
    var passCachedAirport: (SSAirport.SSAirportPresentation) -> Void
    @State private var selectedSegment = 0

    func loadCachedAirports() {
        flightsViewModel.getCachedSSAirports()
    }
    
    var filteredAirports: [SSAirport.SSAirportPresentation] {
        if searchText.isEmpty {
            return flightsViewModel.cachedSSAirports
        } else {
            return flightsViewModel.cachedSSAirports.filter { $0.suggestionTitle.localizedCaseInsensitiveContains(searchText) }
        }
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

            VStack {
                Picker("Options", selection: $selectedSegment) {
                    Text("Recent Searches").tag(0)
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    Text("Search Airports").tag(1)
                        .background(Color.green)
                        .foregroundColor(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            if selectedSegment == 0 {
                Form {
                    TextField("Filter Search History", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                    
                    ForEach(Array(filteredAirports.reversed().enumerated()), id: \.element) { index, item in
                        HStack {
                            Image(item.subtitle.split(separator: ",").map(String.init).last?.replacingOccurrences(of: " ", with: "").flagIconSanitized() ?? "")
                                .resizable()
                                .frame(width: 24, height: 17)
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                            
                            Text("\(item.suggestionTitle)")
                                .font(.custom("Gilroy-Medium", size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 4)
                        }
                        .padding(8)
                        .onTapGesture {
                            passCachedAirport(item)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                
            } else {
                
                Form {
                    TextField("Airport or City Name", text: $viewModel.query)
                        .textFieldStyle(.roundedBorder)
                    
                    ForEach(viewModel.globalSSAirports, id: \.self) { item in
                        HStack {
                            Image(item.presentation.subtitle.split(separator: ",").map(String.init).last?.replacingOccurrences(of: " ", with: "").flagIconSanitized() ?? "")
                                .resizable()
                                .frame(width: 24, height: 17)
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                            
                            Text("\(item.presentation.suggestionTitle)")
                                .font(.custom("Gilroy-Medium", size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 4)
                        }
                        .padding(8)
                        .onTapGesture {
                            flightsViewModel.manageSSAirporteCache(item.presentation)
                            passCachedAirport(item.presentation)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            
        }
        .background(Color(UIColor.systemGroupedBackground))
        .presentationDetents([.fraction(0.6)])
        .onAppear {
            self.loadCachedAirports()
        }
    }
}
