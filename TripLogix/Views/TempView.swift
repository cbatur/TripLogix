import SwiftUI

struct TempView: View {
    @State private var selection: String = "Overview"
    let tripDays = [
        TripDay(day: "Day 1", date: "Thursday, 11 Sept 2022", activities: [
            ActivityT(name: "Kebun Pink", description: "tour around on horseback and get to know the culture of the local people in the traditional way"),
            ActivityT(name: "Siwalan Bogor", description: "a tour of the palm plantation, of course, by trying the taste of the palm fruit that is directly picked from the tree")
        ]),
        TripDay(day: "Day 2", date: "Thursday, 12 Sept 2022", activities: [
            ActivityT(name: "Candinan", description: "Tourism is a tour of the relics of the Hindu-Buddhist religion")
        ])
        // Add more days and activities as needed
    ]

    var body: some View {
        NavigationView {
            VStack {
                Picker("What is your favorite color?", selection: $selection) {
                    Text("Overview").tag("Overview")
                    Text("Trip plan").tag("Trip plan")
                    Text("Budget").tag("Budget")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                List {
                    ForEach(tripDays, id: \.day) { day in
                        Section(header: Text(day.date)) {
                            ForEach(day.activities, id: \.name) { activity in
                                VStack(alignment: .leading) {
                                    Text(activity.name)
                                        .font(.headline)
                                    Text(activity.description)
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
            }
            .navigationTitle("Trip to klaten central java")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "chevron.left")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "person.crop.circle")
                }
            }
        }
    }
}

struct TripDay: Identifiable {
    var id = UUID()
    var day: String
    var date: String
    var activities: [ActivityT]
}

struct ActivityT: Identifiable {
    var id = UUID()
    var name: String
    var description: String
}
