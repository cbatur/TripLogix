import SwiftUI

struct AirportSearchField: View {
    @ObservedObject var viewModel = AirportsViewModel(mode: .departure)
    var placeholder: String
    var icon: String

    @FocusState private var isInputActive: Bool

    var body: some View {
        VStack(alignment: .leading) {
            FlightInputField(icon: icon, placeholder: placeholder, text: $viewModel.searchQuery)
                .focused($isInputActive)
                .overlay(
                    HStack {
                        Spacer()
                        if !viewModel.searchQuery.isEmpty {
                            Button(action: {
                                viewModel.resetSearch()
                            }) {
                                VStack {
                                    if viewModel.isLoading && viewModel.selectedAirport == nil {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                            .scaleEffect(1.2)
                                    } else {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 15))
                                    }
                                }
                                .padding(.top, 20)
                            }
                            .padding(.trailing, 10)
                        }
                    }
                )

            if isInputActive {
                VStack {
                    ForEach(viewModel.suggestions, id: \.self) { suggestion in
                        HStack {
                            Text(suggestion.presentation.suggestionTitle)
                                .foregroundStyle(Color.appBookingBlue)
                                .font(.headline)
                            Spacer()
                            Text(suggestion.presentation.subtitle)
                                .foregroundStyle(Color.gray)
                                .font(.system(size: 15))
                        }
                        .onTapGesture {
                            viewModel.selectAirport(suggestion)
                            isInputActive = false
                        }
                        Divider()
                    }
                }
                .frame(height: min(CGFloat(viewModel.suggestions.count * 40), 20))
                .background(Color.white)
                .padding(.vertical, viewModel.suggestions.count > 0 ? CGFloat(viewModel.suggestions.count * 20) : 0)
                .padding(viewModel.suggestions.count > 0 ? 10 : 0)
            }
        }
    }
}

struct FlightInputField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(placeholder)
                .font(.footnote)
                .foregroundColor(.gray)

            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                TextField(placeholder, text: $text)
                    .font(.system(size: 18))
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundStyle(Color.gray2)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}

struct DateInputField: View {
    @Binding var selectedDate: Date

    var body: some View {
        VStack(alignment: .leading) {
            Text("Date")
                .font(.footnote)
                .foregroundColor(.gray)

            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .labelsHidden()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}
