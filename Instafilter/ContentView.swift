//
//  ContentView.swift
//  Instafilter
//
//  Created by Andres camilo Raigoza misas on 26/03/22.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
    @State private var image: Image?
    
    @State private var filterIntensity = 0.5
    @State private var filterRadius = 0.5
    @State private var filterScale = 0.5
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    
    @State private var showingSaveAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    @State private var setFilterCenter = false
    
    @State private var filterDisplayName = "Sepia Tone"
    
    @State private var showingFilterSheet = false
    
    @State private var showIntensitySlider = true
    @State private var showRadiusSlider = false
    @State private var showScaleSlider = false
    
    enum filterOption {
        case crystallize, edges, gaussian, pixellate, sepia, unsharp, vignette
    }
    
    var body: some View {
        NavigationView {
            VStack {
                imageView
                sliders
                buttons
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .onChange(of: inputImage) { _ in loadImage() }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
            .confirmationDialog("Select a filter", isPresented: $showingFilterSheet) {
                Group {
                    Button("Crystallize") { setFilter(CIFilter.crystallize()) }
                    Button("Edges") { setFilter(CIFilter.edges()) }
                    Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
                    Button("Pixellate") { setFilter(CIFilter.pixellate()) }
                    Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
                    Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
                    Button("Vignette") { setFilter(CIFilter.vignette()) }
                    Button("Twirl Distortion") { setFilter(CIFilter.twirlDistortion())}
                    Button("Bloom") { setFilter(CIFilter.bloom())}
                    Button("Bump Distortion") { setFilter(CIFilter.bumpDistortion())}
                }
                Button("Cancel", role: .cancel) { }
            }
            .alert(alertTitle, isPresented: $showingSaveAlert) {
    
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        if currentFilter.inputKeys.contains(kCIInputCenterKey) && setFilterCenter {
            currentFilter.setValue(CIVector(x: inputImage.size.width / 2, y: inputImage.size.height / 2), forKey: kCIInputCenterKey)
            setFilterCenter = false
        }
        applyProcesing()
    }
    
    func save() {
        guard let processedImage = processedImage else { return }
        
        let imageSaver = ImageSaver()
        
        imageSaver.successHandler = {
            alertTitle = "Success!"
            alertMessage = "Your photo has been saved to your library"
            showingSaveAlert = true
        }
        
        imageSaver.errorHandler = {
            alertTitle = "Oops!"
            alertMessage = "Your photo couldn't be saved to your library, please try again!"
            showingSaveAlert = true
            print("Oops! \($0.localizedDescription)")
        }
        
        imageSaver.writeToPhotoAlbum(image: processedImage)
    }
    
    func applyProcesing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            if currentFilter.name.lowercased().contains("twirl") || currentFilter.name.lowercased().contains("bump"){
                currentFilter.setValue(filterRadius * 2000, forKey: kCIInputRadiusKey)
            } else {
                currentFilter.setValue(filterRadius * 200, forKey: kCIInputRadiusKey)
            }
        }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(filterScale * 10, forKey: kCIInputScaleKey)
        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        
        let inputKeys = currentFilter.inputKeys
        print("\(currentFilter.name): \(inputKeys)")
        
        let filterName = currentFilter.name.lowercased()
        
        if filterName.contains("sepia") {
            filterDisplayName = "Sepia Tone"
        }
        if filterName.contains("crystallize") {
            filterDisplayName = "crystallize".capitalized
        }
        if filterName.contains("gaussian") {
            filterDisplayName = "gaussian blur".capitalized
        }
        if filterName.contains("pixellate") {
            filterDisplayName = "pixellate".capitalized
        }
        if filterName.contains("unsharp") {
            filterDisplayName = "unsharp mask".capitalized
        }
        if filterName.contains("vignette") {
            filterDisplayName = "vignette".capitalized
        }
        if filterName.contains("twirl") {
            filterDisplayName = "twirl distortion".capitalized
            setFilterCenter = true
        }
        if filterName.contains("bloom") {
            filterDisplayName = "bloom".capitalized
        }
        if filterName.contains("bump") {
            filterDisplayName = "bump distortion".capitalized
            setFilterCenter = true
        }
        
        showIntensitySlider = false
        showRadiusSlider = false
        showScaleSlider = false
        
        if inputKeys.contains(kCIInputIntensityKey) {
            showIntensitySlider = true
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            showRadiusSlider = true
        }
        if inputKeys.contains(kCIInputScaleKey) {
            showScaleSlider = true
        }
        loadImage()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension ContentView {
    private var sliders: some View {
        VStack {
            Text(filterDisplayName)
                .font(.headline)
            if showIntensitySlider {
                HStack {
                    Text("Intensity")
                    Slider(value: $filterIntensity)
                        .onChange(of: filterIntensity) { _ in
                            applyProcesing()
                        }
                }
            }
            
            if showRadiusSlider {
                HStack {
                    Text("Radius")
                    Slider(value: $filterRadius)
                        .onChange(of: filterRadius) { _ in
                            applyProcesing()
                        }
                }
            }
            
            if showScaleSlider {
                HStack {
                    Text("Scale")
                    Slider(value: $filterScale)
                        .onChange(of: filterScale) { _ in
                            applyProcesing()
                        }
                }
            }
        }
        .padding(.vertical)
    }
    private var buttons: some View {
        HStack {
            Button("Change filter") {
                showingFilterSheet = true
            }
            Spacer()
            Button("Save", action: save)
                .disabled(image == nil)
        }
    }
    private var imageView: some View {
        ZStack {
            Rectangle()
                .fill(.secondary)
            
            Text("Tap to select a picture")
                .foregroundColor(.white)
                .font(.headline)
            
            image?
                .resizable()
                .scaledToFit()
        }
        .onTapGesture {
            showingImagePicker = true
        }
    }
}
