
import SwiftUI
import Popovers
import ScalingHeaderScrollView
import SwiftData

struct EventsView: View {
    
    @ObservedObject private var viewModel = ProfileScreenViewModel()
    @Environment(\.presentationMode) var presentationMode

    @State var progress: CGFloat = 0
    
    private let minHeight = 110.0
    private let maxHeight = 372.0
    
    @StateObject var tripPlanViewModel: TripPlanViewModel = TripPlanViewModel()
    @StateObject var chatAPIViewModel: ChatAPIViewModel = ChatAPIViewModel()
    @StateObject var googlePlacesViewModel: GooglePlacesViewModel = GooglePlacesViewModel()

    @Bindable var destination: Destination
    
    init(destination: Destination) {
        _destination = Bindable(wrappedValue: destination)
    }
    
    func loadPhotodByGooglePlacesId() {
        self.googlePlacesViewModel.fetchPlaceDetails(placeId: destination.googlePlaceId)
    }
    
    func fetchDateLinkFromHeader() {
        //launchDateSelection = true
    }
    
    func fetchIconClickFromHeader() {
        //self.launchUpdateIconView = true
    }
    
    func changeTabs(_ index: Int) {
        //self.selectedIndex = index
    }

    var body: some View {
        ZStack {
            ScalingHeaderScrollView {
                ZStack {
                    Color.white.edgesIgnoringSafeArea(.all)
                    largeHeader(progress: progress)
                }
            } content: {
                profilerContentView
            }
            .height(min: minHeight, max: maxHeight)
            .collapseProgress($progress)
            .allowsHeaderGrowth()
            
            topButtons
            hireButton
        }
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea()
        .onChange(of: googlePlacesViewModel.photosData) { _, photoArray in
            guard photoArray.count > 0, let photo = photoArray.first else { return }
            self.chatAPIViewModel.downloadImage(from: photo)
        }
        .onChange(of: chatAPIViewModel.imageData) { oldData, newData in
            destination.icon = newData
        }
        .onAppear {
            if destination.icon == nil {
                self.loadPhotodByGooglePlacesId()
            }
        }
    }

    private var tripHeader: some View {
//        LocationDateHeader(
//            destination: destination,
//            passDateClick: fetchDateLinkFromHeader,
//            passIconClick: fetchIconClickFromHeader
//        )
        VStack {
            CityTitleHeader(cityName: destination.name)
                .frame(alignment: .leading)
            
            HStack {
                Text("\(destination.startDate.formatted(date: .abbreviated, time: .omitted)) - \(destination.endDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.system(size: 14))
                    .foregroundColor(.gray3) +
                Text("dayDiffLabel()")
                    .foregroundColor(.black)
                
            }
            //.padding(.top, -10)
            //.onTapGesture { passDateClick() }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.leading, 8)
        .padding(.top, 15)
    }
    
    private var linkBar: some View {
        VStack {
            //Divider()
            TripLinks(passSelectedIndex: changeTabs)
            //Divider()
        }
    }
    
    private var topButtons: some View {
        VStack {
            HStack {
                Button("<", action: { self.presentationMode.wrappedValue.dismiss() })
                    //.buttonStyle(CircleButtonStyle(imageName: "arrow.backward"))
                    .buttonStylePrimary()
                    .padding(.leading, 17)
                    .padding(.top, 50)
                Spacer()
                Button("", action: { print("Info") })
                    //.buttonStyle(CircleButtonStyle(imageName: "ellipsis"))
                    .buttonStylePrimary()
                    .padding(.trailing, 17)
                    .padding(.top, 50)
            }
            Spacer()
        }
        .ignoresSafeArea()
    }

    private var hireButton: some View {
        VStack {
            Spacer()
            ZStack {
                VisualEffectView(effect: UIBlurEffect(style: .regular))
                    .frame(height: 180)
                    .padding(.bottom, -100)
                linkBar
//                HStack {
//                    Button("Hire", action: { print("hire") })
//                        //.buttonStyle(HireButtonStyle())
//                        .padding(.horizontal, 15)
//                        .frame(width: 396, height: 60, alignment: .bottom)
//                }
            }
        }
        .ignoresSafeArea()
        .padding(.bottom, 40)
    }
    
    private var smallHeader: some View {
        HStack(spacing: 12.0) {
            DestinationIconRawImage(iconData: destination.icon)
                .frame(width: 40.0, height: 40.0)
                .clipShape(RoundedRectangle(cornerRadius: 6.0))

            Text(viewModel.userName)
                .fontRegular(color: .appDarkGray, size: 17)
        }
    }
    
    private func largeHeader(progress: CGFloat) -> some View {
        ZStack {
            DestinationIconRawImage(iconData: destination.icon)
                .scaledToFill()
                .frame(height: maxHeight)
                .opacity(1 - progress)
            
            VStack {
                Spacer()
                
                HStack(spacing: 4.0) {
                    Capsule()
                        .frame(width: 40.0, height: 3.0)
                        .foregroundColor(.white)
                    
                    Capsule()
                        .frame(width: 40.0, height: 3.0)
                        .foregroundColor(.white.opacity(0.2))
                    
                    Capsule()
                        .frame(width: 40.0, height: 3.0)
                        .foregroundColor(.white.opacity(0.2))
                }
                
                ZStack(alignment: .leading) {

                    VisualEffectView(effect: UIBlurEffect(style: .regular))
                        .mask(Rectangle().cornerRadius(40, corners: [.topLeft, .topRight]))
                        .offset(y: 10.0)
                        .frame(height: 100.0)

                    RoundedRectangle(cornerRadius: 40.0, style: .circular)
                        .foregroundColor(.clear)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.white.opacity(0.0), .white]), startPoint: .top, endPoint: .bottom)
                        )

                    tripHeader
                        .padding(.leading, 24.0)
                        .padding(.top, 10.0)
                        .opacity(1 - max(0, min(1, (progress - 0.75) * 4.0)))

                    smallHeader
                        .padding(.leading, 85.0)
                        .opacity(progress)
                        .opacity(max(0, min(1, (progress - 0.75) * 4.0)))
                }
                .frame(height: 80.0)
            }
        }
    }
    
    private var profilerContentView: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 20) {
                    //pageTitle
//                    tripHeader
                    mainContent
//                    skills
//                    description
//                    portfolio
                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private var pageTitle: some View {
        Text(viewModel.userName)
            .fontBold(color: .appDarkGray, size: 24)
    }

//    private var profession: some View {
//        tripDetails
//    }

//    private var address: some View {
//        Text(viewModel.address)
//            .fontRegular(color: .appLightGray, size: 16)
//    }

//    private var reviews: some View {
//        HStack(alignment: .center , spacing: 8) {
//            Image("Star")
//                .offset(y: -3)
//            grade
//            reviewCount
//        }
//        .padding(.top, 15)
//    }
    
    private var mainContent: some View {
        VStack {
            //tripDetails
            itineraryDetails
                .isHidden(tripPlanViewModel.activeAlertBox != nil)
        }
    }
    
    private var itineraryDetails: some View {
        VStack {
            if destination.itinerary.count > 0 {
                eventGrid
                eventsAndActivitiesView
            } else {
                noPlanView
                    .padding(.top, 30)
            }
        }
    }
    
    private var eventGrid: some View {
        Group {
            if destination.itinerary.count == 0 {
                VStack {
                    createTripButton
                    personalizeButton
                }
                .padding(.leading, 35)
                .padding(.trailing, 35)
                .padding(.top, 20)
                .isHidden(tripPlanViewModel.activeAlertBox != nil)
            }
        }
    }
    
    private var createTripButton: some View {
        Button(action: { tripPlanViewModel.updateTrip(destination) }) {
            if destination.itinerary.count == 0 {
                Label("Create", systemImage: "text.redaction")
                .padding(.horizontal, 15)
                .padding(9)
            } else {
                Image(systemName: "arrow.clockwise")
                    .padding(10)
            }
        }
        .frame(maxWidth: .infinity)
        .buttonStylePrimary(.pink)
    }

    private var personalizeButton: some View {
        Group {
            if destination.allEventTags.count > 0 {
                Button(action: {
                    //launchAllEvents = true
                }) {
                    if destination.itinerary.count == 0 {
                        Label("Personalize", systemImage: "person.fill.viewfinder")
                            .padding(.horizontal, 15)
                            .padding(9)
                    } else {
                        Image(systemName: "person.fill.viewfinder")
                            .padding(10)
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStylePrimary(.primary)
            } else {
                EmptyView()
            }
        }
    }
    
//    private var navigationBarItems: some ToolbarContent {
//        ToolbarItemGroup(placement: .navigationBarTrailing) {
//            NavigationBarIconView(onAction: {
//                shareButtonTapped()
//            }, icon: "square.and.arrow.up")
//        }
//    }
    
//    private func shareButtonTapped() {
//        launchAdminTools = true
//        print("Share button tapped \(destination.id)")
//    }
    
    private var noPlanView: some View {
        GeometryReader { geometry in
            VStack {
                Image("hero_create_trip")
                    .resizable()
                    .scaledToFit()
                    .background(Color.clear)
                    .edgesIgnoringSafeArea(.all)
                    .padding(.leading, geometry.size.width / 4)
                    .padding(.trailing, geometry.size.width / 4)
                Text("Create a trip plan")
                    .font(.custom("Gilroy-Bold", size: 23))
                    .foregroundColor(Color.black)
                    .padding(.bottom, 10)
                Text("A trip itinerary will be created for the dates you selected.")
                    .font(.custom("Gilroy-Regular", size: 18))
                    .foregroundColor(Color.gray3)
                    .frame(alignment: .center)
                
                eventGrid
            }
            .padding(.leading, 15)
            .padding(.trailing, 15)
            .padding(.top, 15)
        }
    }
    
    private var eventsAndActivitiesView: some View {
        VStack {
            HStack {
                HeaderView(title: "Events and Activities")
                Spacer()
                Templates.Menu {
                    Templates.MenuButton(title: "Personalize", systemImage: "person.fill.viewfinder") {
                        //launchAllEvents = true
                    }
                    Templates.MenuButton(title: "Create New", systemImage: "arrow.clockwise") {
                        tripPlanViewModel.updateTrip(destination)
                    }
                    
                } label: { fadeEvents in
                    VStack {
                        Image(systemName: "ellipsis")
                            .aspectRatio(contentMode: .fit)
                            .font(.system(size: 21)).bold()
                            .background(.clear)
                            .padding(8)
                            .buttonStylePrimary(.plain)
                    }
                    .opacity(fadeEvents ? 0.5 : 1)
                }
                .padding(.trailing, 10)
            }
            VStack {
                ForEach(destination.itinerary.sorted(by: { $0.index < $1.index }), id: \.self) { day in
                    EventCardView(day: day, city: destination.name)
                }
            }
            .padding(.top, 25)
        }
    }

}
