//
//  FilterViewCotroller.swift
//  ClickAccountingApp
//
//  Created by apptology on 1/15/18.
//  Copyright © 2018 Mobiloitte. All rights reserved.
//

import UIKit
protocol imageFilterDelegate {
    func getFilterData(image : UIImage)
}

class FilterViewCotroller: UIViewController {

    @IBOutlet var imageViewForFilter: UIImageView!
    var filterDelegate: imageFilterDelegate?
    var imageToEdit = UIImage()
    @IBOutlet var brightnessButton: UIButton!
    @IBOutlet var colorButton: UIButton!
    @IBOutlet var contrastButton: UIButton!
    var aCIImage = CIImage()
    var contrastFilter: CIFilter!
    var brightnessFilter: CIFilter!
    var context = CIContext()
    var outputImage = CIImage()
    var newUIImage = UIImage()
    var sharpenImage = UIImage()
    var currentMode : String = ""

    var valueForColor : Float = 0.0
    var valueForBrightness : Float = 0.0
    var valueForContrast : Float = 0.0

    
    
    
    @IBOutlet var slider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageViewForFilter.image  = imageToEdit
        colorButton.isSelected = true
        currentMode = "color"
        aCIImage = CIImage(image: imageViewForFilter.image!)!
        context = CIContext(options: nil);
        contrastFilter = CIFilter(name: "CIColorControls");
        contrastFilter.setValue(aCIImage, forKey: "inputImage")
        brightnessFilter = CIFilter(name: "CIColorControls");
        brightnessFilter.setValue(aCIImage, forKey: "inputImage")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK:  Slider Action
    
    @IBAction func colorSlider(_ sender: UISlider) {
        
        if(currentMode == "color"){
            let filter = CIFilter(name: "CIColorControls")
            filter?.setValue(aCIImage, forKey: kCIInputImageKey)
            filter?.setValue(sender.value, forKey: kCIInputContrastKey)
            outputImage = brightnessFilter.outputImage!;
            let imageRef = context.createCGImage(outputImage, from: outputImage.extent)
            newUIImage = UIImage.init(cgImage: imageRef!, scale: imageToEdit.scale, orientation: imageToEdit.imageOrientation)
            imageViewForFilter.image = newUIImage;
            valueForColor = sender.value
        }
        else if(currentMode == "brightness"){
            brightnessFilter.setValue(NSNumber(value: sender.value), forKey: "inputBrightness");
            outputImage = brightnessFilter.outputImage!;
            let imageRef = context.createCGImage(outputImage, from: outputImage.extent)
            newUIImage = UIImage.init(cgImage: imageRef!, scale: imageToEdit.scale, orientation: imageToEdit.imageOrientation)
            imageViewForFilter.image = newUIImage;
            valueForBrightness = sender.value

        }
        else{
            contrastFilter.setValue(NSNumber(value: sender.value + 1), forKey: "inputContrast")
            outputImage = contrastFilter.outputImage!;
            let cgimg = context.createCGImage(outputImage, from: outputImage.extent)
            newUIImage = UIImage.init(cgImage: cgimg!, scale: imageToEdit.scale, orientation: imageToEdit.imageOrientation)
            imageViewForFilter.image = newUIImage;
            valueForContrast = sender.value + 1
        }
        
    }
    
    @IBAction func changeColor(_ sender: Any) {
        slider.value = valueForColor
        currentMode = "color"
        colorButton.isSelected = true
        brightnessButton.isSelected = false
        contrastButton.isSelected = false

    }
    
    @IBAction func changeBrightness(_ sender: Any) {
        currentMode = "brightness"
        slider.value = valueForBrightness
        brightnessButton.isSelected = true
        colorButton.isSelected = false
        contrastButton.isSelected = false
    }
    
    @IBAction func changeContrast(_ sender: Any) {
        currentMode = "contrast"
        slider.value = valueForContrast
        if(valueForContrast > 1){
            slider.value  = valueForContrast - 1
        }
        contrastButton.isSelected = true
        brightnessButton.isSelected = false
        colorButton.isSelected = false
    }
    
    
    @IBAction func resetToOrignal(_ sender: Any) {
        valueForBrightness = 0.0
        valueForContrast = 0.0
        valueForColor = 0.0
        slider.value = 0.0
        imageViewForFilter.image = imageToEdit
    }
    
    //MARK:  Done Action
    
    @IBAction func done_Clicked(_ sender: Any) {
        filterDelegate?.getFilterData(image: imageViewForFilter.image!)
        self.dismiss(animated: true, completion: nil)
    }
  
    //MARK:  Cancel Action

    @IBAction func cancel_Clicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
