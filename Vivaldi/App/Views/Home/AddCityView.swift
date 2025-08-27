//
//  AddCityView.swift
//  Vivaldi
//
//  Created by Justin SL on 8/16/25.
//

import SwiftUI
import VivaldiDesignSystem
import VivaldiModels

struct AddCityView: View {
    @Binding var isPresented: Bool
    let onAddCity: (City) -> Void
    
    @State private var cityName = ""
    @State private var countryCode = ""
    @FocusState private var isCityNameFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                VStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(Colors.toolbarMaterial)

                    Text("Add New City")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    Text("Add a city to track its weather")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.top)

                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("City Name")
                            .font(.headline)
                            .foregroundStyle(.white)

                        TextField("Enter city name", text: $cityName)
                            .textFieldStyle(SimpleField())
                            .focused($isCityNameFocused)
                            .autocorrectionDisabled()
                            .submitLabel(.next)
                            .onSubmit {
                                if !cityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    addCity()
                                }
                            }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Country Code (Optional)")
                            .font(.headline)
                            .foregroundStyle(.white)
                        
                        TextField("US, GB, FR, etc.", text: $countryCode)
                            .textFieldStyle(SimpleField())
                            .autocorrectionDisabled()
                            .textCase(.uppercase)
                            .submitLabel(.done)
                            .onSubmit {
                                addCity()
                            }
                    }
                }
                .padding(.horizontal, 24)
                
                Button("Add City") {
                    addCity()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(cityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .background(Colors.pageBackground.gradient)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundStyle(.white)
                }
            }
            .onAppear {
                isCityNameFocused = true
            }
        }
    }
    
    private func addCity() {
        let trimmedName = cityName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCountry = countryCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        guard !trimmedName.isEmpty else { return }

        let newCity = City(
            name: trimmedName,
            countryCode: trimmedCountry.isEmpty ? "US" : trimmedCountry
        )

        onAddCity(newCity)
        isPresented = false
    }
}

#Preview("Add City") {
    @Previewable @State var isPresented = true
    
    AddCityView(isPresented: $isPresented) { city in
        print("Added city: \(city.name)")
    }
}
