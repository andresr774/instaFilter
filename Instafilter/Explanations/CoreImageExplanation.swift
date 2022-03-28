//
//  CoreImageExplanation.swift
//  Instafilter
//
//  Created by Andres camilo Raigoza misas on 27/03/22.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct CoreImageExplanation: View {
    @State private var image: Image?
    
    var body: some View {
        VStack {
            image?
                .resizable()
                .scaledToFit()
        }
        .onAppear(perform: loadImage)
    }
    func loadImage() {
        guard let inputImage = UIImage(named: "fox-woodcutter") else {
            return
        }
        let beginImage = CIImage(image: inputImage)
        
        let context = CIContext()
        //let currentFilter = CIFilter.sepiaTone()
        //let currentFilter = CIFilter.pixellate()
        let currentFilter = CIFilter.crystallize()
        //let currentFilter = CIFilter.twirlDistortion()
        
        let amount = 1.0
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(amount, forKey: kCIInputIntensityKey)
        }
        
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(amount * 200, forKey: kCIInputRadiusKey)
        }
        
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(amount * 10, forKey: kCIInputScaleKey)
        }
        
        currentFilter.inputImage = beginImage
        //currentFilter.intensity = 1
        //currentFilter.scale = 10
        //currentFilter.radius = 500
        currentFilter.center = CGPoint(x: inputImage.size.width / 2, y: inputImage.size.height / 2)
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgImg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgImg)
            image = Image(uiImage: uiImage)
        }
    }
}

struct CoreImageExplanation_Previews: PreviewProvider {
    static var previews: some View {
        CoreImageExplanation()
    }
}
