//
//  CADocumentPreviewViewController.swift
//  ClickAccountingApp
//
//  Created by apptology on 2/1/18.
//  Copyright © 2018 Mobiloitte. All rights reserved.
//

import UIKit
import QuickLook

class CADocumentPreviewViewController: UIViewController, QLPreviewControllerDataSource, QLPreviewControllerDelegate {

    let docPath =  String()
    var itemURL: URL!
    var fileURL = URL(string: "")
    let quickLookController = QLPreviewController()

    
    override func viewDidLoad() {
        quickLookController.dataSource = self
        quickLookController.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      
        let data = NSData(contentsOf: itemURL)
        do {
            // Get the documents directory
            let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            // Give the file a name and append it to the file path
            fileURL = documentsDirectoryURL.appendingPathComponent("sample.pdf")
            // Write the pdf to disk
            try data?.write(to: fileURL!, options: .atomic)
            
            // Make sure the file can be opened and then present the pdf
            if QLPreviewController.canPreview(itemURL as QLPreviewItem) {
                quickLookController.currentPreviewItemIndex = 0
                present(quickLookController, animated: true, completion: nil)
            }
        } catch {
            // cant find the url resource
        }
      
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return fileURL! as QLPreviewItem
    }
   
    func previewControllerWillDismiss(_ controller: QLPreviewController) {
        
        self.dismiss(animated: true, completion: nil)
    }
 

}
