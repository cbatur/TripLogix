
import SwiftUI

struct ImageToFlightView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: ImageToFlightViewModel = ImageToFlightViewModel()
    @StateObject var aviationEdgeViewmodel: AviationEdgeViewmodel = AviationEdgeViewmodel()
    @State var showImagePicker: Bool = false
    @State var isRotating: Bool = false
    @State var selectedImage: Image? = nil
    @State var isPastDate: Bool = false

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
    
    private func submitImageUrl(_ imageUrl: String) {
        viewModel.getFlightParametersFromImage(imageUrl)
    }
    
    private func uploadFlightImage() {
        let uiImage: UIImage? = self.selectedImage?.asUIImage()
        let imageData: Data? = uiImage?.jpegData(compressionQuality: 0.1) ?? Data()
        let imageString: String? = imageData?.base64EncodedString()
        let imageURL: String = "https://palamana.com/TripLogix/TempFlightImages/uploadTempImage.php?id=\(UUID().uuidString)"
        guard let imageString = imageString else { return }
        viewModel.uploadFlightPhoto(imageUrl: imageURL, imageString: imageString)
    }
    
    func activity() -> Bool {
        return viewModel.loadingFlightImage == true ||
        viewModel.loadingMessage != nil ||
        aviationEdgeViewmodel.loading == true
    }
    
    var body: some View {
        ScrollView {
            VStack {
                BannerWithDismiss(
                    dismiss: dismiss,
                    headline: "Add Flights to Trip".uppercased(),
                    subHeadline: "Add your flight reservation screenshot"
                )
                .disabled(activity())
                .opacity(activity() ? 0.4 : 1.0)
                .padding()
                .padding(.top, 10)
                
                VStack {
                    if selectedImage == nil {
                        
                        Text("Upload Itinerary image".uppercased())
                            .font(.custom("Gilroy-Bold", size: 21))
                            .foregroundColor(.gray)
                            .onTapGesture {
                                self.showImagePicker = true
                            }
                            .isHidden(activity())
                            .padding()
                    } else {
                        Button(action: {
                            uploadFlightImage()
                        }) {
                            Text("Scan This Flight Photo?".uppercased())
                                .font(.custom("Gilroy-Bold", size: 18))
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .cardStyle(.wbPinkMedium)
                    }
                    
                    //Divider().isHidden(activity())
                    
                    self.selectedImage?.resizable().scaledToFit()

                    if viewModel.loadingFlightImage {
                        AlertWithIconView(
                            startAnimate: true,
                            systemImage: "text.below.photo.fill",
                            message: "Trying to understand your image!!!"
                        )
                    }
                    
                    if viewModel.loadingMessage != nil {
                        AlertWithIconView(
                            startAnimate: true,
                            systemImage: "airplane",
                            message: "Got your image, let's see If we can pull your flight info..."
                        )
                    }
                    
                    if aviationEdgeViewmodel.loading {
                        AlertWithIconView(
                            startAnimate: true,
                            systemImage: "info.bubble",
                            message: "Perfect. We tracked some flights, now fetching the details."
                        )
                    }
                    
                    if isPastDate {
                        AlertWithIconView(
                            startAnimate: false,
                            systemImage: "square.and.arrow.up.trianglebadge.exclamationmark",
                            message: "The reservation for this ticket is in the past; please ensure it is for a future flight."
                        )
                    }
                    
                    VStack {
                        ForEach(aviationEdgeViewmodel.futureFlights, id: \.self) { item in
                            FlightResultCard(item)
                            Divider()
                                .onTapGesture {
                                    //self.selectedFlight = item
                                }
                        }
                    }
                    
                }
                .padding()
                //.cardStyle(.white)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
            .sheet(isPresented: $showImagePicker, content: {
                ImagePicker(image: self.$selectedImage)
            })
            .onChange(of: viewModel.flightsFromImage) { _, flightSet in
                guard let firstRound = flightSet.first else { return }
                
                let dateString = firstRound.date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                if let date = dateFormatter.date(from: dateString), date <= Date() {
                    isPastDate = true
                } else {
                    aviationEdgeViewmodel.getFutureFlights(firstRound, flightChecklist: nil)
                }
            }
            .onChange(of: viewModel.flightImageUrl) { _, url in
                guard let imageUrl = url else { return }
                submitImageUrl(imageUrl)
                selectedImage = nil
            }
            
        }
    }
}

struct AlertWithIconView: View {
    
    var startAnimate: Bool = false
    @State var isRotating: Bool = false
    var systemImage: String = "info.bubble"
    var message: String = "..."
    
    init(startAnimate: Bool, systemImage: String, message: String) {
        self.systemImage = systemImage
        self.message = message
        self.startAnimate = startAnimate
    }
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(.largeTitle)
                .foregroundColor(.wbPinkMedium)
                .rotationEffect(.degrees(isRotating ? 360 : 0))
                .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), value: isRotating)
                .onAppear() {
                    self.isRotating = startAnimate
                }
            Text(message)
                .font(.custom("Gilroy-Medium", size: 19))
                .foregroundColor(.black.opacity(0.8))
                .padding()
        }
        .padding()
        .cardStyle(.gray.opacity(0.1))
    }
}

