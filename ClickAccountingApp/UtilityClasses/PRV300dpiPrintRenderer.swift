//
//  PRV300dpiPrintRenderer.swift
//  ClickAccountingApp
//
//  Created by Tarun Kaushik on 03/07/18.
//  Copyright © 2018 Mobiloitte. All rights reserved.
//

import Foundation

class PRV300dpiPrintRenderer : UIPrintPageRenderer {
    func pdfData() -> NSData? {
        let data = NSMutableData()
        UIGraphicsBeginPDFContextToData(data, self.paperRect, nil)
        UIColor.white.set();
        guard let pdfContext = UIGraphicsGetCurrentContext() else{return nil}
        pdfContext.saveGState()
        pdfContext.concatenate(CGAffineTransform(scaleX: 72/300, y: 72/300)) // scale down to improve dpi from screen 72dpi to printable 300dpi
        self.prepare(forDrawingPages: NSRange.init(0...self.numberOfPages))
        let bounds = UIGraphicsGetPDFContextBounds()
        for i in 0..<self.numberOfPages {
            UIGraphicsBeginPDFPage();
            self.drawPage(at: i, in: bounds)
        }
        pdfContext.restoreGState()
        UIGraphicsEndPDFContext();
        return data
    }
}

