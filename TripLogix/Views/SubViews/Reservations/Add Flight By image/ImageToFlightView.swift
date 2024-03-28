
import SwiftUI

struct ImageToFlightView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var chatAPIViewModel: ChatAPIViewModel = ChatAPIViewModel()
    @StateObject var aviationEdgeViewmodel: AviationEdgeViewmodel = AviationEdgeViewmodel()
    @StateObject var tripLogixMediaViewmodel: TripLogixMediaViewmodel = TripLogixMediaViewmodel()
    @State var showImagePicker: Bool = false
    @State var isRotating: Bool = false
    @State var selectedImage: Image? = nil

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
    
    private func submitImageUrl(_ imageUrl: String) {
        chatAPIViewModel.getChatGPTContent(qType: QCategory.textFromImageUrl(imageUrl: imageUrl))
    }
    
    private func uploadFlightImage() {
        let uiImage: UIImage? = self.selectedImage?.asUIImage()
        let imageData: Data? = uiImage?.jpegData(compressionQuality: 0.1) ?? Data()
        let imageString: String? = imageData?.base64EncodedString()
        let imageURL: String = "https://palamana.com/TripLogix/TempFlightImages/uploadTempImage.php?id=\(UUID().uuidString)"
        guard let imageString = imageString else { return }
        tripLogixMediaViewmodel.uploadFlightPhoto(imageUrl: imageURL, imageString: imageString)
    }
    
    func activity() -> Bool {
        return tripLogixMediaViewmodel.loadingFlightImage == true ||
        chatAPIViewModel.loadingMessage != nil ||
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
                            .font(.custom("Gilroy-Bold", size: 18))
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
                    
                    Divider().isHidden(activity())
                    
                    self.selectedImage?.resizable().scaledToFit()

                    if tripLogixMediaViewmodel.loadingFlightImage {
                        HStack {
                            Image(systemName: "text.below.photo.fill")
                                .font(.largeTitle)
                                .foregroundColor(.wbPinkMedium)
                                .rotationEffect(.degrees(isRotating ? 360 : 0))
                                .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), value: isRotating)
                                .onAppear() {
                                    self.isRotating = true
                                }
                            Text("Trying to understand your image!!!")
                        }
                    }
                    
                    if chatAPIViewModel.loadingMessage != nil {
                        HStack {
                            Image(systemName: "airplane")
                                .font(.largeTitle)
                                .foregroundColor(.wbPinkMedium)
                                .rotationEffect(.degrees(isRotating ? 360 : 0))
                                .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), value: isRotating)
                                .onAppear() {
                                    self.isRotating = chatAPIViewModel.loadingMessage == nil
                                }
                            Text("Got your image, let's see If we can pull your flight info...")
                        }
                    }
                    
                    if aviationEdgeViewmodel.loading {
                        HStack {
                            Image(systemName: "info.bubble")
                                .font(.largeTitle)
                                .foregroundColor(.wbPinkMedium)
                                .rotationEffect(.degrees(isRotating ? 360 : 0))
                                .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), value: isRotating)
                                .onAppear() {
                                    self.isRotating = true
                                }
                            Text("Perfect. We tracked some flights, now fetching the details.")
                        }
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
            .onChange(of: chatAPIViewModel.flightsFromImage) { _, flightSet in
                guard let firstRound = flightSet.first else { return }
                aviationEdgeViewmodel.getFutureFlights(firstRound, flightChecklist: nil)
            }
            .onChange(of: tripLogixMediaViewmodel.flightImageUrl) { _, url in
                guard let imageUrl = url else { return }
                submitImageUrl(imageUrl)
                selectedImage = nil
            }
            
        }
    }
}

