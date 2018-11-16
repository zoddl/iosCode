//  CAHomeViewController.swift
//  ClickAccountingApp
//  Created by Ratneshwar Singh on 6/29/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.

import UIKit
import Charts
import SDWebImage
import MobileCoreServices



protocol goToReportDelegate{
    func changeToReportTab(reportData : AnyObject)
}



class CAHomeViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , UIScrollViewDelegate , UICollectionViewDelegate, UICollectionViewDataSource, ChartViewDelegate, AddTagDelegate,UICollectionViewDelegateFlowLayout, UIWebViewDelegate, UIDocumentPickerDelegate, docScreenshotDelegate,SearchDelegate {
    
    @IBOutlet var homeTableView: UITableView!
    @IBOutlet var topDetailsTableView: UITableView!
    @IBOutlet var tagTableView: UITableView!
    @IBOutlet var headerView: UIView!
    
    @IBOutlet weak var chartView: PieChartView!
    
    var refreshControl: UIRefreshControl!
    var docScreenshotView = CADocScreenshotViewController()
    var userTagDictionary = NSDictionary()
    var primaryTagArray = NSMutableArray()
    var secondaryTagArray = NSMutableArray()
  
    var reportDelegate: goToReportDelegate?


    var fetchData  = Bool()
    var fetchTopFive  = Bool()

    var documentExtension : String = ""
    var documentPath : String = ""
    var tagTypeAdded : String = ""
    
    
    let months = ["Cash+", "Cash-", "Bank+", "Bank-", "Others"]
    var unitsSold = [Double]()
    var unitsBought = [Double]()
    var uBought = [Double]()
    var u4Bought = [Double]()
    var u5Bought = [Double]()
    
    
    var cashPlusArray = NSMutableArray()
    var cashMinusArray = NSMutableArray()
    var bankPlusArray = NSMutableArray()
    var bankMinusArray = NSMutableArray()
    var otherArray = NSMutableArray()

    
    
    var categoryArray = NSArray()
    // MARK: - view controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData = true
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing data")
        refreshControl.addTarget(self, action: #selector(CAGalleryDocumentViewController.refresh(sender:)), for: .valueChanged)
        homeTableView.addSubview(refreshControl)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshView(notification:)), name: Notification.Name("newTagAdded"), object: nil)
        
        // Do any additional setup after loading the view.
        initialMethod()
        getTopFiveElements()
        //loadChart()
        
   
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // setPieChart()
    }
    
    // MARK: - intial data load methods
    
    func initialMethod(){
        
        self.topDetailsTableView!.register(UINib(nibName: "CAHomeTableHeaderCell", bundle: nil), forCellReuseIdentifier: "CAHomeTableHeaderCell")
        
        self.topDetailsTableView!.register(UINib(nibName: "CAHomeTableDataCell", bundle: nil), forCellReuseIdentifier: "CAHomeTableDataCell")
        
        self.topDetailsTableView!.register(UINib(nibName: "CAHomeTableDataSecCell", bundle: nil), forCellReuseIdentifier: "CAHomeTableDataSecCell")
        
        self.tagTableView!.register(UINib(nibName: "CAHomeTagCell", bundle: nil), forCellReuseIdentifier: "CAHomeTagCell")
        
        self.homeTableView!.register(UINib(nibName: "CAHomeCategoryCell", bundle: nil), forCellReuseIdentifier: "CAHomeCategoryCell")
        
        self.homeTableView!.register(UINib(nibName: "CAHomeCollectionViewCell", bundle: nil), forCellReuseIdentifier: "CAHomeCollectionViewCell")
        
        self.homeTableView!.tableHeaderView = headerView
        self.homeTableView!.separatorColor = UIColor.clear
        
        self.topDetailsTableView!.separatorColor = UIColor.clear
        self.topDetailsTableView!.isScrollEnabled = false
        
        self.tagTableView.delegate = self
        self.tagTableView.dataSource = self
        
        
        if(fetchData == true){
            self.getHomeData()
            self.getAllPrimaryTags()
            
            self.getAllSecondaryTags()
        }
        
    }
    
    //Mark: - Refresh table
    
    func refresh(sender:AnyObject) {
        self.getHomeData()
    }
    
    
    //Mark: - Load Gra

func setPieChart () {
    chartView.delegate = self
    
    
    chartView.legend.horizontalAlignment = .left
    chartView.legend.verticalAlignment = .bottom
    chartView.legend.orientation = .vertical
    chartView.legend.xEntrySpace = 7
    chartView.legend.yEntrySpace = 0
    chartView.legend.yOffset = 0
    //chartView.legend = l
    
    chartView.entryLabelColor = .white
    //hartView.entryLabelFont = UIFont.systemFont(ofSize: 12, weight: .)
    chartView.centerText = "Hightlight Tags"
    
    chartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
    
    
    let parties = ["C+","B+","O","C-","B-"]
    var values:[Double] = []
    var total:Double = 0.0
    if categoryArray.count > 0{
        print("data is available")
        for i in 0..<5{
            let price = (((categoryArray.value(forKey: kTotal) as! NSArray).object(at: i) as? NSNumber )!)
            values.append(Double(price))
            total += Double(price)
        }
    }else{
        print("data is not available")
    }
    
    print(total)

    let count = 5
    let entries = (0..<count).map { (i) -> PieChartDataEntry in
        // IMPORTANT: In a PieChart, no values (Entry) should have the same xIndex (even if from different DataSets), since no values can be drawn above each other.
        let percentage = Double(values[i]/total)
        print("percentage value is \(percentage)")
        return PieChartDataEntry(value:Double(percentage),
                                 label: parties[i % parties.count],
                                 icon: #imageLiteral(resourceName: "icon"))
    }
    
    let set = PieChartDataSet(values: entries, label: "")
    set.drawIconsEnabled = false
    set.sliceSpace = 2
    
    
      set.colors = [RGBA(52, g: 211, b: 202, a: 1),RGBA(33, g: 144, b: 202, a: 1),RGBA(240, g: 240, b: 240, a: 1),RGBA(191, g: 240, b: 238, a: 1),RGBA(204, g: 232, b: 244, a: 1)]
    
//    set.colors = ChartColorTemplates.vordiplom()
//        + ChartColorTemplates.joyful()
//        + ChartColorTemplates.colorful()
//        + ChartColorTemplates.liberty()
//        + ChartColorTemplates.pastel()
//        + [UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)]
    
    let data = PieChartData(dataSet: set)
    
    let pFormatter = NumberFormatter()
    pFormatter.numberStyle = .percent
    pFormatter.maximumFractionDigits = 1
    pFormatter.multiplier = 100
    pFormatter.percentSymbol = "%"
    data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
    
    //data.setValueFont(.systemFont(ofSize: 11, weight: ))
    data.setValueTextColor(.black)
    
    
    chartView.data = data
    chartView.highlightValues(nil)
 
}

func setDataCount(_ count: Int, range: UInt32) {
   
}
    
//    func loadChart(){
//        chartView.delegate = self
//        chartView.noDataText = "You need to provide data for the chart."
//        //   chartView.chartDescription?.text = "sales vs bought "
//
//
//        //legend
//        let legend = chartView.legend
//        legend.enabled = false
//        legend.horizontalAlignment = .right
//        legend.verticalAlignment = .top
//        legend.orientation = .vertical
//        legend.drawInside = true
//        legend.yOffset = 10.0;
//        legend.xOffset = 10.0;
//        legend.yEntrySpace = 0.0;
//
//
//        let xaxis = chartView.xAxis
//        //    xaxis.valueFormatter = axisFormatDelegate
//        xaxis.drawGridLinesEnabled = true
//        xaxis.labelPosition = .bottom
//        xaxis.centerAxisLabelsEnabled = true
//        xaxis.valueFormatter = IndexAxisValueFormatter(values:self.months)
//        xaxis.granularity = 1
//
//
//        let leftAxisFormatter = NumberFormatter()
//        leftAxisFormatter.maximumFractionDigits = 1
//
//        let yaxis = chartView.leftAxis
//        yaxis.spaceTop = 0.35
//        yaxis.axisMinimum = 0
//        yaxis.drawGridLinesEnabled = false
//
//        chartView.rightAxis.enabled = false
//        //axisFormatDelegate = self
//
//     }
//
//    func setChart() {
//        chartView.noDataText = "You need to provide data for the chart."
//        var dataEntries:  [BarChartDataEntry] = []
//        var dataEntries1: [BarChartDataEntry] = []
//        var dataEntries2: [BarChartDataEntry] = []
//        var dataEntries3: [BarChartDataEntry] = []
//        var dataEntries4: [BarChartDataEntry] = []
//
//        for i in 0..<self.months.count {
//
//            let dataEntry = BarChartDataEntry(x: Double(i) , y: self.unitsSold[i])
//            let dataEntry1 = BarChartDataEntry(x: Double(i) , y: self.self.unitsBought[i])
//            let dataEntry2 = BarChartDataEntry(x: Double(i) , y: self.self.uBought[i])
//            let dataEntry3 = BarChartDataEntry(x: Double(i) , y: self.self.uBought[i])
//            let dataEntry4 = BarChartDataEntry(x: Double(i) , y: self.self.uBought[i])
//
//            dataEntries.append(dataEntry)
//            dataEntries1.append(dataEntry1)
//            dataEntries2.append(dataEntry2)
//            dataEntries3.append(dataEntry3)
//            dataEntries4.append(dataEntry4)
//
//            //stack barchart
//            //let dataEntry = BarChartDataEntry(x: Double(i), yValues:  [self.unitsSold[i],self.unitsBought[i]], label: "groupChart")
//        }
//
//        //        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Unit sold")
//        //        let chartDataSet1 = BarChartDataSet(values: dataEntries1, label: "Unit Bought")
//
//        let chartDataSet = BarChartDataSet(values: dataEntries, label: "")
//        let chartDataSet1 = BarChartDataSet(values: dataEntries1, label: "")
//        let chartDataSet2 = BarChartDataSet(values: dataEntries2, label: "")
//        let chartDataSet3 = BarChartDataSet(values: dataEntries3, label: "")
//        let chartDataSet4 = BarChartDataSet(values: dataEntries4, label: "")
//        let dataSets: [BarChartDataSet] = [chartDataSet,chartDataSet1,chartDataSet2,chartDataSet3,chartDataSet4]
//
//        chartDataSet1.colors = [UIColor.black]
//        chartDataSet3.colors = [UIColor.black]
//
//        // commented by me
//        /*        chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)] */
//
//
//        //chartDataSet.colors = ChartColorTemplates.colorful()
//        //let chartData = BarChartData(dataSet: chartDataSet)
//
//        let chartData = BarChartData(dataSets: dataSets)
//
//        //  (groupSpace * barSpace) * n + groupSpace = 1
//        let groupSpace = 0.01
//        let barSpace = 0.16
//        let barWidth = 0.04
//
//        // (0.3 + 0.05) * 2 + 0.3 = 1.00 -> interval per "group"
//        // (0.01 + 0.18) * 5 + 0.04 = 1.00 -> interval per "group"
//
//        let groupCount = self.months.count
//        let startYear = 0
//
//        chartData.barWidth = barWidth;
//        chartView.xAxis.axisMinimum = Double(startYear)
//        let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
//        print("Groupspace: \(gg)")
//        chartView.xAxis.axisMaximum = Double(startYear) + gg * Double(groupCount)
//        chartData.groupBars(fromX: Double(startYear), groupSpace: groupSpace, barSpace: barSpace)
//        //chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
//        chartView.notifyDataSetChanged()
//        chartView.data = chartData
//        //background color
//        chartView.backgroundColor = UIColor.white
//        //chart animation
//        chartView.animate(xAxisDuration: 1.5, yAxisDuration: 1.5, easingOption: .linear)
//
//    }
    
    
    func loadTagsMethod(){
    }
    
    // MARK: - Memory management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableView delegate Methods
    
    //    func numberOfSections(in tableView: UITableView) -> Int {
    //        if tableView == topDetailsTableView{
    //            return 1
    //        }else{
    //            return 0;
    //        }
    //    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == topDetailsTableView{
            return 26
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell: CAHomeTableHeaderCell? = (self.topDetailsTableView.dequeueReusableCell(withIdentifier: "CAHomeTableHeaderCell") as? CAHomeTableHeaderCell)
        return cell?.contentView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = Int()
        
        if tableView == topDetailsTableView {
            count = 5
        }else if tableView == tagTableView{
            count = 1
        }else if tableView == homeTableView{
            count = self.categoryArray.count
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == topDetailsTableView {
            return 24
        }else if tableView == tagTableView{
            return 50
        }else if tableView == homeTableView{
            return 140
        }
        else{
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        if tableView == tagTableView {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CAHomeTagCell", for: indexPath) as? CAHomeTagCell
            cell?.tagCollectionView.register(UINib(nibName: "CATagCollectionCell", bundle: nil), forCellWithReuseIdentifier: "CATagCollectionCell")
            cell?.tagCollectionView.showsHorizontalScrollIndicator = false
            cell?.tagCollectionView.tag = indexPath.section + 500
            cell?.tagCollectionView.allowsSelection = true
            cell?.tagCollectionView.delegate = self
            cell?.tagCollectionView.dataSource = self
            cell?.tagCollectionView.reloadData()
            
            return cell!
        }
        else if tableView == homeTableView {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CAHomeCategoryCell", for: indexPath) as? CAHomeCategoryCell
            cell?.seeAllBtn.tag = indexPath.row + 15000
            cell?.seeAllBtn?.addTarget(self, action: #selector(CAHomeViewController.catAction(_:)), for: .touchUpInside)
          //  cell?.categoryCollectionView.register(UINib(nibName: "CAHomeCatCell", bundle: nil), forCellWithReuseIdentifier: "CAHomeCatCell")
            cell?.categoryCollectionView.register(UINib(nibName: "CAHomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CAHomeCollectionViewCell")
            
            cell?.categoryCollectionView.showsHorizontalScrollIndicator = false
            cell?.categoryCollectionView.tag = indexPath.row + 5000
            cell?.categoryCollectionView.allowsSelection = true
            cell?.categoryCollectionView.delegate = self
            cell?.categoryCollectionView.dataSource = self
            cell?.categoryCollectionView.reloadData()
            
            cell?.categoryCollectionView.register(UINib(nibName: "CAReportCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CAReportCollectionViewCell")

            
            if(categoryArray.count > 0){
                let secondaryItemAttay = ((categoryArray.object(at: indexPath.row)as AnyObject).value(forKey: kPrimaryImages) as? NSArray)?.count
                
                if(indexPath.row == 5){
                        cell?.categoryNameLabel.text = "Reports"
                        cell?.seeAllBtn.isHidden = true
                        cell?.categoryPriceLabel.isHidden = true
                    
                }else{
                       cell?.categoryNameLabel.text = (((categoryArray.value(forKey: kTagType) as AnyObject).object(at: indexPath.row) as? String )?.capitalized)?.appending (" (").appending((secondaryItemAttay! as NSNumber).stringValue ).appending (")")
                    let text = (((categoryArray.value(forKey: kTagType) as AnyObject).object(at: indexPath.row) as? String )?.capitalized)?.appending (" (").appending((secondaryItemAttay! as NSNumber).stringValue ).appending (")")
                    print(text)
                }
            
            }
  
            if(indexPath.row == 5){
                
            }else{
                let price = (((categoryArray.value(forKey: kTotal) as! NSArray).object(at: indexPath.row) as? NSNumber )!)
                cell?.categoryPriceLabel.text = "Rs." + ((price as NSNumber).stringValue)
                print(indexPath)
                print("price \(price)")
            }
            return cell!
        }
            
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CAHomeTableDataSecCell", for: indexPath) as? CAHomeTableDataSecCell
            cell?.selectionStyle = .none
            
            let xNSNumber = indexPath.row + 1 as NSNumber
            let dataString : String = xNSNumber.stringValue
            cell?.serialNoLabel.text = dataString
            if(self.fetchTopFive){
              
                cell?.top5CPlusLabel.text = (self.cashPlusArray.object(at: indexPath.row) as AnyObject).value(forKey: kTotalAmout) as? String
                cell?.top5BPlusLabel.text = (self.bankPlusArray.object(at: indexPath.row) as AnyObject).value(forKey: kTotalAmout) as? String
                cell?.top5BMinusLabel.text = (self.bankMinusArray.object(at: indexPath.row) as AnyObject).value(forKey: kTotalAmout) as? String
                cell?.otherLabel.text = (self.otherArray.object(at: indexPath.row) as AnyObject).value(forKey: kTotalAmout) as? String
                cell?.top5CMinusLabel.text = (self.cashMinusArray.object(at: indexPath.row) as AnyObject).value(forKey: kTotalAmout) as? String
                
                
                if(cell?.top5CPlusLabel.text == ""){
                    cell?.top5CPlusLabel.text = "-"
                }
                if(cell?.top5BPlusLabel.text == ""){
                    cell?.top5BPlusLabel.text = "-"
                }
                if(cell?.top5BMinusLabel.text == ""){
                    cell?.top5BMinusLabel.text = "-"
                }
                if(cell?.otherLabel.text == ""){
                    cell?.otherLabel.text = "-"
                }
                if(cell?.top5CMinusLabel.text == ""){
                    cell?.top5CMinusLabel.text = "-"
                }
                
            }
            return cell!
        }
    }
    
    // MARK: - UICollectionView delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView.tag == 500) {
            return self.primaryTagArray.count
            
        }else{
            var currentIndex  = Int()
            currentIndex =  collectionView.tag - 5000
            return  ((self.categoryArray.object(at:currentIndex ) as AnyObject).value(forKey: kPrimaryImages) as! NSArray).count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (collectionView.tag == 500) {
            let tagCell: CATagCollectionCell? = (collectionView.dequeueReusableCell(withReuseIdentifier: "CATagCollectionCell", for: indexPath) as? CATagCollectionCell)
            tagCell?.tagBtn?.setTitle((self.primaryTagArray[indexPath.row] as AnyObject) .value(forKey: kPrimaryName) as? String, for: .normal)
            tagCell?.tagBtn?.tag = indexPath.item + 10000
            tagCell?.tagBtn?.addTarget(self, action: #selector(CAHomeViewController.tagAction(_:)), for: .touchUpInside)
            return tagCell!
        }
        else {
            var currentIndex  = Int()
            currentIndex =  collectionView.tag - 5000
            
            print("The indexpath is\(indexPath.row)")
            print(currentIndex)
            
            if(currentIndex == 5){
                
                let reportCell: CAReportCollectionViewCell? = (collectionView.dequeueReusableCell(withReuseIdentifier: "CAReportCollectionViewCell", for: indexPath) as? CAReportCollectionViewCell)
                
              let secondaryArr = (((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).object(at: indexPath.row) as AnyObject).value(forKey: kReportData) as! NSArray)
                 
                reportCell?.title1.text = (((secondaryArr.object(at: 0) as AnyObject).value(forKey: "column1") as AnyObject).value(forKey: kPrimaryName) as? String)?.capitalized
                reportCell?.title2.text = (((secondaryArr.object(at: 0) as AnyObject).value(forKey: "column2") as AnyObject).value(forKey: kPrimaryName) as? String)?.capitalized
                reportCell?.title3.text = (((secondaryArr.object(at: 0) as AnyObject).value(forKey: "column3") as AnyObject).value(forKey: kPrimaryName) as? String)?.capitalized
                reportCell?.title4.text = (((secondaryArr.object(at: 0) as AnyObject).value(forKey: "column4") as AnyObject).value(forKey: kPrimaryName) as? String)?.capitalized
                reportCell?.title5.text = (((secondaryArr.object(at: 0) as AnyObject).value(forKey: "column5") as AnyObject).value(forKey: kPrimaryName) as? String)?.capitalized
                
              //  reportCell?.reportDetailButton?.addTarget(self, action: #selector(CAHomeViewController.reportAction(_:)), for: .touchUpInside)

                reportCell?.layer.borderWidth = 1.0
                reportCell?.layer.cornerRadius = 10.0
                reportCell?.layer.borderColor = UIColor.lightGray.cgColor
                return reportCell!
                
            }
            
            
            let categoryCell: CAHomeCollectionViewCell? = (collectionView.dequeueReusableCell(withReuseIdentifier: "CAHomeCollectionViewCell", for: indexPath) as? CAHomeCollectionViewCell)
            
            categoryCell?.primaryName.text = (checkNull(inputValue: (((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kPrimaryName) as! NSArray).object(at: indexPath.row) as? String)  as AnyObject) as? String)?.appending("(").appending((checkNull(inputValue: (((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kCount) as! NSArray).object(at: indexPath.row) as? String)  as AnyObject) as! String)).appending(")")
            
            categoryCell?.primaryAmount.text = ("Rs. ").appending(checkNull(inputValue: (((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kAmount) as! NSArray).object(at: indexPath.row) as? String)  as AnyObject) as! String)
            
            if((((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Type") as! NSArray).object(at: indexPath.row) as? String) == "document"){
                categoryCell?.typeIcon.image = #imageLiteral(resourceName: "icon18")

            }else{
                 categoryCell?.typeIcon.image = #imageLiteral(resourceName: "icon15")
            }
            
            categoryCell?.categoryTypeLabel.text = (((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Type") as! NSArray).object(at: indexPath.row) as? String)?.capitalized
            
            //**************** comment out this to remove shortform feature **************************
            
             categoryCell?.categoryTypeLabel.font = UIFont.boldSystemFont(ofSize: 12)
            
            let catergoryType = (((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Type") as! NSArray).object(at: indexPath.row) as? String)?.capitalized
            
            var catergoryText = ""
            switch catergoryType{
            case "Bank+":
                catergoryText = "B+"
            case "Bank-":
                catergoryText = "B-"
            case "Cash+":
                catergoryText = "C+"
            case "Cash-":
                catergoryText = "C-"
            case "Other":
                catergoryText = "O"
            default :
                catergoryText = ""
            }
            
            categoryCell?.categoryTypeLabel.text = catergoryText
            //**************** commenting ends here ***************************
            
            
            
            categoryCell?.layer.borderWidth = 1.0
            categoryCell?.layer.cornerRadius = 10.0
            categoryCell?.layer.borderColor = UIColor.lightGray.cgColor
                let primaryTag = (((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Type") as! NSArray).object(at: indexPath.row) as? String)?.lowercased()
            
            if(primaryTag == kBankPlus){
                categoryCell?.categoryTypeLabel.backgroundColor = RGBA(33, g: 144, b: 202, a: 1)
            }
            else if(primaryTag == kBankMinus){
                categoryCell?.categoryTypeLabel.backgroundColor = RGBA(204, g: 232, b: 244, a: 1)
            }
            else if(primaryTag == kCashPlus){
                categoryCell?.categoryTypeLabel.backgroundColor = RGBA(52, g: 211, b: 202, a: 1)
            }
            else if(primaryTag == kCashMinus){
                categoryCell?.categoryTypeLabel.backgroundColor = RGBA(191, g: 240, b: 238, a: 1)
            }
            else if(primaryTag == kOther){
                categoryCell?.categoryTypeLabel.backgroundColor = RGBA(240, g: 244, b: 245, a: 1)
                categoryCell?.categoryTypeLabel.text = "0"
            }
            else{
                categoryCell?.categoryTypeLabel.backgroundColor = UIColor.clear
            }
            
            categoryCell?.detailButtonAction?.tag = indexPath.item + 10000
            
         //   categoryCell?.detailButtonAction?.addTarget(self, action: #selector(CAHomeViewController.tagAction(_:)), for: .touchUpInside)
            
            if(currentIndex == 6 || currentIndex == 7 ){
                categoryCell?.categoryTypeLabel.backgroundColor = UIColor.clear
                categoryCell?.categoryTypeLabel.text = ""
            }
            
            return categoryCell!
        }
            
            
//            let categoryCell: CAHomeCatCell? = (collectionView.dequeueReusableCell(withReuseIdentifier: "CAHomeCatCell", for: indexPath) as? CAHomeCatCell)
//            categoryCell?.categoryBtn?.tag = collectionView.tag + 20000
//            categoryCell?.categoryBtn?.addTarget(self, action: #selector(CAHomeViewController.catAction(_:)), for: .touchUpInside)
//            categoryCell?.categoryImage.sd_setShowActivityIndicatorView(true)
//            categoryCell?.categoryImage.sd_setIndicatorStyle(.gray)
//            categoryCell?.categoryImage.contentMode = UIViewContentMode.scaleAspectFill
//            categoryCell?.categoryImage.clipsToBounds = true
//
//            let date = (((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kTagDate) as! NSArray).object(at: indexPath.row) as? String)
//            var dateString = NSString()
//
//            if((date) != nil){
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "yyyy-MM-dd"
//                let newdate = dateFormatter.date(from:date!)
//                let dateformatterToString = DateFormatter()
//                dateformatterToString.dateFormat = "dd MMM,yyyy"
//                dateString = dateformatterToString.string(from: newdate!) as NSString
//            }
//
//
//            let secondaryArr = checkNull(inputValue:(((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kSecondaryTag) as! NSArray).object(at: indexPath.row)) as! NSArray)
//
//
//            categoryCell?.tagNameLabel.text  = dateString.appending(",").appending((checkNull(inputValue: (((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kPrimaryName) as! NSArray).object(at: indexPath.row) as? String)  as AnyObject) as? String)!).appending(",").appending((secondaryArr.value(forKey: kSecondaryName) as AnyObject).componentsJoined(by: ",")).appending(",").appending(checkNull(inputValue: (((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kPrimaryDescription) as! NSArray).object(at: indexPath.row) as? String)  as AnyObject) as! String)
//
//            categoryCell?.categoryTypeLabel.text = (((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Type") as! NSArray).object(at: indexPath.row) as? String)?.capitalized
//
//
//            categoryCell?.priceLabel.text = ("Rs. ").appending(checkNull(inputValue: (((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kAmount) as! NSArray).object(at: indexPath.row) as? String)  as AnyObject) as! String)
//
//            if((((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Type") as! NSArray).object(at: indexPath.row) as? String) == kOther){
//                categoryCell?.categoryTypeLabel.text = ""
//            }
//
//
//            if((((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Image_Url") as! NSArray).object(at: indexPath.row) as? String == "")){
//                categoryCell?.categoryImage.image =  UIImage(named: "icon18")
//            }
//            else{
//
//                if((self.categoryArray .value(forKey: kTagType) as AnyObject).objectAt(currentIndex) as! String == "document"){
//
//                    categoryCell?.categoryImage.isHidden = false
//                    categoryCell?.categoryImage.contentMode = UIViewContentMode.scaleAspectFit
//                    let webViewDisplayed = UIWebView()
//                    webViewDisplayed.tag = 3250
//                    webViewDisplayed.frame = (categoryCell?.categoryImage.frame)!
//                    webViewDisplayed.backgroundColor = UIColor.clear
//                    webViewDisplayed.scrollView.isScrollEnabled = false
//                    webViewDisplayed.isOpaque = false
//                    webViewDisplayed.delegate = self
//                    webViewDisplayed.scrollView.bounces = false
//                    categoryCell?.bgView.addSubview(webViewDisplayed)
//
//                    if(((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kIsUploaded) as! NSArray).object(at: indexPath.row) as? String == "1"){
//
//                        let tagImageURL = (((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Image_Url_Thumb") as! NSArray).object(at: indexPath.row) as? String)
//
//                        let docURL = URL(string: tagImageURL!)
//
//                        if(docURL?.pathExtension == ""){
//
//                            webViewDisplayed.isHidden  = true
//                            categoryCell?.categoryImage.sd_setImage(with: URL(string: checkNull(inputValue: (((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Image_Url_Thumb") as! NSArray).object(at: indexPath.row) as? String)  as AnyObject) as! String), placeholderImage: UIImage(named: "icon18"))
//
//
//                            categoryCell?.categoryImage.contentMode = UIViewContentMode.scaleAspectFill
//                            categoryCell?.categoryImage.clipsToBounds = true
//
//                        }
//                        else if(docURL?.pathExtension == "pdf"){
//                            webViewDisplayed.isHidden  = false
//                            categoryCell?.categoryImage.image =  UIImage(named: "icon18")
//                            categoryCell?.categoryImage.isHidden = true
//
//                            if((docURL) != nil){
//                                self.loadPDFWebViewData(url: docURL!, webView: webViewDisplayed, placeHolderImageView:(categoryCell?.categoryImage)! )
//                            }
//
//                        }
//                        else if(docURL?.pathExtension == "xls"){
//                            categoryCell?.categoryImage.image =  UIImage(named: "icon18")
//                            if((docURL) != nil){
//                                self.loadWebViewData(url: docURL!, webView: webViewDisplayed, placeHolderImageView:  (categoryCell?.categoryImage)!)
//                                webViewDisplayed.backgroundColor  = UIColor.white
//                            }
//                        }
//                        else
//                        {
//                            webViewDisplayed.isHidden  = false
//                            categoryCell?.categoryImage.image =  UIImage(named: "icon18")
//                            if((docURL) != nil){
//                                self.loadWebViewData(url: docURL!, webView: webViewDisplayed, placeHolderImageView:  (categoryCell?.categoryImage)!)
//                            }
//                        }
//                    }
//                    else
//                    {
//                        let dirPath = ((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Image_Url") as! NSArray).object(at: indexPath.row) as? String
//
//                        let urlString  = URL.init(fileURLWithPath: dirPath!)
//                        //      let data = try! Data(contentsOf: urlString as URL)
//
//                        if(urlString.pathExtension == "jpg"){
//                            let dirPath = ((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Image_Url") as! NSArray).object(at: indexPath.row) as? String
//                            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(dirPath!)
//                            categoryCell?.categoryImage.contentMode = UIViewContentMode.scaleAspectFill
//                            categoryCell?.categoryImage.clipsToBounds = true
//                            categoryCell?.categoryImage.image = UIImage(contentsOfFile: paths)
//                        }
//
//                        if(urlString.pathExtension == "pdf"){
//
//                            self.loadPDFWebViewData(url: urlString as URL, webView: webViewDisplayed, placeHolderImageView:  (categoryCell?.categoryImage)!)
//                        }
//                        else{
//                            self.loadWebViewData(url: urlString as URL, webView: webViewDisplayed, placeHolderImageView:  (categoryCell?.categoryImage)!)
//                        }
//                    }
//                }
//                else{
//                    if(((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kIsUploaded) as! NSArray).object(at: indexPath.row) as? String == "1"){
//
//
//                        categoryCell?.categoryImage.sd_setImage(with: URL(string: checkNull(inputValue: (((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Image_Url") as! NSArray).object(at: indexPath.row) as? String)  as AnyObject) as! String), placeholderImage: UIImage(named: "icon18"),options: [], completed: { (image, error, cacheType, imageURL) in
//                            // Perform operation.
//                            print(error as Any)
//
//                        })
//                    }
//                    else{
//                        let dirPath = ((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Image_Url") as! NSArray).object(at: indexPath.row) as? String
//                        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(dirPath!)
//                        categoryCell?.categoryImage.image = UIImage(contentsOfFile: paths)
//                    }
//                }
//            }
//
//            if categoryCell?.categoryImage.image == nil{
//                categoryCell?.categoryImage.image =  UIImage(named: "icon18")
//            }
//
//
//            if((((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Type") as! NSArray).object(at: indexPath.row) as? String) == kBankPlus){
//                categoryCell?.categoryTypeLabel.backgroundColor = RGBA(33, g: 144, b: 202, a: 1)
//            }
//            else if((((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Type") as! NSArray).object(at: indexPath.row) as? String) == kBankMinus){
//                categoryCell?.categoryTypeLabel.backgroundColor = RGBA(204, g: 232, b: 244, a: 1)
//
//            }
//            else if((((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Type") as! NSArray).object(at: indexPath.row) as? String) == kCashPlus){
//                categoryCell?.categoryTypeLabel.backgroundColor = RGBA(52, g: 211, b: 202, a: 1)
//
//            }
//            else if((((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Type") as! NSArray).object(at: indexPath.row) as? String) == kCashMinus){
//                categoryCell?.categoryTypeLabel.backgroundColor = RGBA(191, g: 240, b: 238, a: 1)
//
//            }
//            else if((((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Type") as! NSArray).object(at: indexPath.row) as? String) == kOther){
//                categoryCell?.categoryTypeLabel.backgroundColor = UIColor.clear
//                categoryCell?.categoryTypeLabel.text = ""
//            }
//            else{
//                categoryCell?.categoryTypeLabel.backgroundColor = UIColor.clear
//            }
//
//            if((((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Status") as! NSArray).object(at: indexPath.row) as? String) == "1" ){
//                categoryCell?.categoryColorLabel.backgroundColor = RGBA(33, g: 144, b: 202, a: 1)
//            }
//            else if((((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Status") as! NSArray).object(at: indexPath.row) as? String) == "2"  ){
//                categoryCell?.categoryColorLabel.backgroundColor = RGBA(33, g: 144, b: 202, a: 1)
//            }
//            else if((((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Status") as! NSArray).object(at: indexPath.row) as? String) == "3" ){
//                categoryCell?.categoryColorLabel.backgroundColor = RGBA(33, g: 144, b: 202, a: 1)
//
//            }
//            else if((((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Status") as! NSArray).object(at: indexPath.row) as? String) == "4" ){
//                categoryCell?.categoryColorLabel.backgroundColor = RGBA(248, g: 114, b: 35, a: 1)
//
//            }
//            else if((((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Status") as! NSArray).object(at: indexPath.row) as? String) == "6"  ){
//                categoryCell?.categoryColorLabel.backgroundColor = RGBA(204, g: 232, b: 244, a: 1)
//            }
//
//            if((((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Type") as! NSArray).object(at: indexPath.row) as? String) == kOther){
//                categoryCell?.categoryTypeLabel.text = " "
//            }
//
//            return categoryCell!
//
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var cellSize = CGSize()
        
        if (collectionView.tag == 500) {
            
            let myString: NSString = checkNull(inputValue:(primaryTagArray.object(at: indexPath.row ) as AnyObject).value(forKey: kPrimaryName) as! NSString) as! NSString
            let size: CGSize = myString.size(attributes: [NSFontAttributeName: UIFont.init(name: "Calibri", size: 16.0)!])
            
            cellSize  = CGSize(width:size.width + 30,height: 50)
            
        }else{
            cellSize = CGSize(width:130,height: 94)
        }
        
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 500{
            print("Center tapped")
        }
            
        else if(indexPath.row == self.categoryArray.count){
            print(indexPath.row)
            let galleryDetailsVC: CAGalleryDetailViewController = CAGalleryDetailViewController(nibName:"CAGalleryDetailViewController", bundle:nil)
            galleryDetailsVC.isShowingGalleryData = true
            
        }
            
        else{
            var currentIndex  = Int()
            currentIndex =  collectionView.tag - 5000
            
//            let galleryDetailsVC: CAGalleryDetailViewController = CAGalleryDetailViewController(nibName:"CAGalleryDetailViewController", bundle:nil)
            
            if(currentIndex == 5){
                let dataSent = (((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex)).object(at: indexPath.row))
                reportDelegate?.changeToReportTab(reportData: dataSent as AnyObject as AnyObject)
            }
            else{
                let tagListVC: CATagListViewController = CATagListViewController(nibName:"CATagListViewController", bundle:nil)
                //            tagListVC.isFromGallery = false
                tagListVC.isFromHome = true
                tagListVC.navBarTitleString = (((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kPrimaryName) as! NSArray).object(at: indexPath.row) as? String)!
                tagListVC.selectedTagId = (((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kPrimaryTag) as! NSArray).object(at: indexPath.row) as? String)!
                tagListVC.incomingTagTypeFormHome = (((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kTagType) as! NSArray).object(at: indexPath.row) as? String)!
                
                if((((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Type") as! NSArray).object(at: indexPath.row) as? String) == "gallery"){
                   // tagListVC.isPrimaryTagTypeGallery = true
                    tagListVC.isGalleryTypeFromHomeItem = true
                }else{
                    tagListVC.isGalleryTypeFromHomeItem = false
                  //  tagListVC.isSeeAllFromDocument = false
                }
                
                tagListVC.isPrimaryTag = true
                tagListVC.userDefineArray = primaryTagArray
                tagListVC.preDefineArray = secondaryTagArray
                
                if(currentIndex == 6){
                    tagListVC.selectedGalleryOrDocumentItem = true
                    tagListVC.isFromDocument = true
                }
                
                if(currentIndex == 7){
                    tagListVC.selectedGalleryOrDocumentItem = true
                    tagListVC.isFromGallery = true
                }
                                navigationController?.pushViewController(tagListVC, animated: true)
                
            }
            
            
//            if((((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kPrimaryTagId) as! NSArray).object(at: indexPath.row) as? String) != nil){
//
//                if((((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Type") as! NSArray).object(at: indexPath.row) as? String) == "gallery"){
//                    galleryDetailsVC.isShowingGalleryData = true
//                }
//
//                galleryDetailsVC.tagId =   (((self.categoryArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kPrimaryTagId) as! NSArray).object(at: indexPath.row) as? String)!
//                navigationController?.pushViewController(galleryDetailsVC, animated: true)
//            }
            
        }
    }
    
    
    func loadWebViewData(url : URL, webView : UIWebView, placeHolderImageView : UIImageView){
        
        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            
            let request = URLRequest(url: url,
                                     cachePolicy:NSURLRequest.CachePolicy.returnCacheDataElseLoad,
                                     timeoutInterval: 10.0)
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
                if((data) != nil){
                    
                    
                }
            })
            task.resume()
            
            DispatchQueue.main.async {
                webView.loadRequest(request as URLRequest)
                webView.scrollView.bounces = false
                webView.scrollView.isScrollEnabled = false
                // placeHolderImageView.isHidden = true
                
            }
        }
        
        
    }
    
    func loadPDFWebViewData(url : URL, webView : UIWebView , placeHolderImageView : UIImageView){
        
        var pdfData = Data()
        
        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            
            let request = URLRequest(url: url,
                                     cachePolicy:NSURLRequest.CachePolicy.returnCacheDataElseLoad,
                                     timeoutInterval: 10.0)
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
                if((data) != nil){
                    
                    pdfData = data!
                    
                }
            })
            task.resume()
            
            DispatchQueue.main.async {
                webView.loadRequest(request as URLRequest)
                webView.scrollView.bounces = false
                webView.scrollView.isScrollEnabled = false
                webView.load(pdfData, mimeType: "application/pdf", textEncodingName:"", baseURL: (url.deletingLastPathComponent()))
                placeHolderImageView.isHidden = true
                
                // hide placeholder image view
                //  placeHolderImageView.isHidden = true
                
            }
        }
        
    }
    
    
    
    // MARK: - Tag Actions
    func tagAction(_ sender: UIButton) {
        //  let buttonTag = sender.tag
        let tagListVC: CATagListViewController = CATagListViewController(nibName:"CATagListViewController", bundle:nil)
        tagListVC.isFromGallery = false
        tagListVC.isFromHome = true
        if (self is CATagListViewController) {
            
        }else{
            tagListVC.isFromHomeTopTags = true

        }
        tagListVC.navBarTitleString = ((primaryTagArray[sender.tag - 10000] as AnyObject) .value(forKey: kPrimaryName) as? String)!
        tagListVC.selectedTagId = ((primaryTagArray[sender.tag - 10000] as AnyObject) .value(forKey: kPrimaryTagId) as? String)!
        
        if((primaryTagArray[sender.tag - 10000] as AnyObject) .value(forKey: "Source_Type") as? String == "image gallery"){
            tagListVC.isPrimaryTagTypeGallery = true
            tagListVC.isFromGallery = true
        }else{
            tagListVC.isPrimaryTagTypeGallery = false
            tagListVC.isFromGallery = false
        }
        
        tagListVC.isPrimaryTag = true
        
        tagListVC.userDefineArray = primaryTagArray
        tagListVC.preDefineArray = secondaryTagArray
        navigationController?.pushViewController(tagListVC, animated: true)
    }
    
   
    // MARK: - See All Action
    
    func catAction(_ sender: UIButton) {
       
        let tag = sender.tag - 15000
        
        if(tag == 6){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeBottomButtonToDocument"), object: nil, userInfo: nil)
        }
        else if(tag == 7){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeBottomButtonToGallery"), object: nil, userInfo: nil)
        }
        else{
            let tagListVC: CATagListViewController = CATagListViewController(nibName:"CATagListViewController", bundle:nil)
            tagListVC.isFromGallery = false
           // tagListVC.isFromHome = true
            tagListVC.isSeeAllFromHome = true
            tagListVC.tagTypeForSearch  =  ((categoryArray.object(at: tag) as AnyObject).value(forKey: kTagType)!) as! String
            tagListVC.navBarTitleString =  (((categoryArray.object(at: tag) as AnyObject).value(forKey: kTagType)!) as! String).capitalized
            
            //       tagListVC.selectedTagId     = ((primaryTagArray[sender.tag - 10000] as AnyObject) .value(forKey: kPrimaryTagId) as? String)!
            //        if((primaryTagArray[sender.tag - 10000] as AnyObject) .value(forKey: "Source_Type") as? String == "image gallery"){
            //            tagListVC.isPrimaryTagTypeGallery = true
            //            tagListVC.isFromGallery = true
            //        }else{
            //            tagListVC.isPrimaryTagTypeGallery = false
            //            tagListVC.isFromGallery = false
            //        }
            //        tagListVC.isPrimaryTag = true
            
            tagListVC.userDefineArray = primaryTagArray
            tagListVC.preDefineArray = secondaryTagArray
            navigationController?.pushViewController(tagListVC, animated: true)

        }
   

//        let tag = sender.tag - 15000
//        let allTagListVC: CAGalleryDocumentAllListViewController = CAGalleryDocumentAllListViewController(nibName:"CAGalleryDocumentAllListViewController", bundle:nil)
//        if(tag == categoryArray.count-1){
//            // tabBarController?.selectedIndex = 2
//            allTagListVC.selectedGalleryFromHome = true;
//        }
//        allTagListVC.isFromHome = true
//        allTagListVC.tagType = (categoryArray.value(forKey: kTagType) as AnyObject).object(at: tag) as! String
//        allTagListVC.userDefineArray = primaryTagArray
//        allTagListVC.preDefineArray = secondaryTagArray
//        allTagListVC.navigationTitleString = ((categoryArray.value(forKey: kTagType) as AnyObject).object(at: tag) as! String).capitalized
//        navigationController?.pushViewController(allTagListVC, animated: true)
    }
    

    
    @IBAction func sideMenuAction(_ sender: UIButton){
        let appDelegateShared : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegateShared.menuViewController .toggle()
    }
    
    @IBAction func searchAction(_ sender: UIButton){
//        let appDelegateShared : AppDelegate = UIApplication.shared.delegate as! AppDelegate
//        let searchController: CASearchBarViewController = CASearchBarViewController(nibName:"CASearchBarViewController", bundle: nil)
//        //searchController.delegate = self
//        searchController.modalPresentationStyle = .overCurrentContext
//        searchController.modalTransitionStyle = .crossDissolve
//        appDelegateShared.navController?.present(searchController, animated: true, completion: nil)
//        
//        
        let appDelegateShared : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let searchController: CASearchBarViewController = CASearchBarViewController(nibName:"CASearchBarViewController", bundle: nil)
        searchController.incomingController = "Home"
        searchController.searchDelegate = self
        searchController.modalPresentationStyle = .overCurrentContext
        searchController.modalTransitionStyle = .crossDissolve
        appDelegateShared.navController?.present(searchController, animated: true, completion: nil)
        
        
    }
    
    @IBAction func addDocumentAction(_ sender: UIButton) {
        
        let addTagPopUpVC: CAAddTagPopUpViewController = CAAddTagPopUpViewController(nibName:"CAAddTagPopUpViewController", bundle: nil)
        addTagPopUpVC.addTagDelegate = self
        tagTypeAdded  = "gallery"
        addTagPopUpVC.isManualTag = true
        addTagPopUpVC.navigationTitleString = "Add Manual"
        addTagPopUpVC.modalPresentationStyle = .overCurrentContext
        addTagPopUpVC.modalTransitionStyle = .crossDissolve
        self.present(addTagPopUpVC, animated: true, completion: nil)
    }
    
    @IBAction func viewDocumentAction(_ sender: UIButton){
        
        //        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.text"], in: UIDocumentPickerMode.import)
        //        documentPicker.delegate = self as? UIDocumentPickerDelegate
        //        documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        //        self.present(documentPicker, animated: true, completion: nil)
        
        
        if(!Reachability.isConnectedToNetwork()){
            
            let actionSheetController: UIAlertController = UIAlertController(title: kZoddl, message: "Seems like you are not connected to internet. Please check your internet connection.", preferredStyle: .alert)
            
            let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { action -> Void in
                if(self.refreshControl != nil){
                    self.refreshControl.endRefreshing()
                }
            }
            actionSheetController.addAction(okAction)
            self.present(actionSheetController, animated: true, completion: nil)
        }
        else
        {
            let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.numbers.sffnumbers", "com.apple.iwork.keynote.key", "com.microsoft.word.doc", "public.text","com.adobe.pdf", "com.microsoft.word.doc","com.microsoft.excel.xls", kUTTypePDF as String,"public.pdf"], in: UIDocumentPickerMode.import)
            tagTypeAdded  = "Document"
            documentPicker.delegate = self
            documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            self.present(documentPicker, animated: true, completion: nil)
        }
        
    }
    
    // MARK: - UIDocumentPickerDelegate Methods
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            // This is what it should be
            do {
                let documentData = try NSData(contentsOf: url, options: NSData.ReadingOptions())
                let fileManager = FileManager.default
                
                let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(url.path)
                
                fileManager.createFile(atPath: paths, contents: documentData as Data, attributes: nil)
                fileManager.fileExists(atPath: paths)
                
                docScreenshotView = CADocScreenshotViewController(nibName:"CADocScreenshotViewController", bundle: nil)
                docScreenshotView.modalPresentationStyle = .overCurrentContext
                docScreenshotView.modalTransitionStyle = .crossDissolve
                docScreenshotView.urlString = url.absoluteString
                docScreenshotView.screenshotDelegate = self
                docScreenshotView.viewDidLoad()
                ServiceHelper.sharedInstanceHelper.showHud()
                documentExtension = url.pathExtension
                documentPath = url.path
                
            }
            catch {
                print("Unable to load data: \(error)")
                presentAlert(kZoddl, msgStr: "Unable to load data: \(error)", controller: self)
                
            }
        }
    }
    
    // MARK: - Add tag delegate
    func addDelegateWithDetailsAndIsSubmit(details: NSString, isSubmit: Bool) {
        //        if((kUserDefaults.value(forKey: "savedTag")) != nil){
        //            let tagArrayFetched = kUserDefaults.value(forKey: "savedTag") as! NSArray
        //            var tagMutable = NSMutableArray()
        //            tagMutable = tagArrayFetched.mutableCopy() as! NSMutableArray
        //            print(tagMutable)
        //            var matchedPrimaryTag = NSDictionary()
        //
        //            for (index, element) in tagMutable.enumerated() {
        //                print("Item \(index): \(element)")
        //                let dict = element as! NSDictionary
        //                print(dict)
        //                let resultPredicate = NSPredicate(format: "Prime_Name == [c]%@", (dict.value(forKey: kPrimaryName) as! String).lowercased())
        //                let arr = self.primaryTagArray.filtered(using: resultPredicate)
        //                if(arr.count > 0){
        //                    print(arr)
        //                    matchedPrimaryTag = (arr.first as! NSDictionary).mutableCopy() as! NSMutableDictionary
        //                    self.primaryTagArray.remove(matchedPrimaryTag)
        //                    let imageArray = (matchedPrimaryTag.value(forKey: kPrimaryImages) as! NSArray).mutableCopy() as! NSMutableArray
        //                    let arr = dict.value(forKey: kPrimaryImages) as! NSArray
        //                    imageArray.add(arr.firstObject as Any)
        //                    print(matchedPrimaryTag)
        //                    matchedPrimaryTag .setValue(imageArray, forKey: kPrimaryImages)
        //                    self.primaryTagArray.add(matchedPrimaryTag)
        //                }
        //                else{
        //                    let newTagAdded = NSMutableDictionary()
        //                    newTagAdded .setValue(dict .value(forKey: kPrimaryName), forKey: kPrimaryName)
        //                    newTagAdded .setValue(dict .value(forKey: kAmount), forKey: kTotal)
        //                    let imageArray = NSMutableArray()
        //                    let arr = dict.value(forKey: kPrimaryImages) as! NSArray
        //                    imageArray.add(arr.firstObject as Any)
        //                    newTagAdded .setValue(imageArray, forKey: kPrimaryImages)
        //                    tagMutable.add(newTagAdded)
        //                }
        //            }
        //        }
        //
        //        let myDelegate = UIApplication.shared.delegate as? AppDelegate
        //        myDelegate?.uploadImageToS3()
        
        if self.tagTypeAdded == "Document" {
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Document")
            
            do {
                let results = try context.fetch(fetchRequest)
                let  documentCreated = results as! [Document]
                
                for docData in documentCreated {
                    
                    var matchedPrimaryTag = NSDictionary()
                    
                    let resultPredicate = NSPredicate(format: "Prime_Name == [c]%@", (docData.primaryName!))
                    let arr = self.primaryTagArray.filtered(using: resultPredicate)
                    if(arr.count > 0){
                        //                            print("Add in local")
                        //                            matchedPrimaryTag = (arr.first as! NSDictionary).mutableCopy() as! NSMutableDictionary
                        //                            //self.primaryTagArray.remove(matchedPrimaryTag)
                        //                            let imageArray = (matchedPrimaryTag.value(forKey: kPrimaryImages) as! NSArray).mutableCopy() as! NSMutableArray
                        //
                        //                            let entryAdded = NSMutableDictionary()
                        //                            entryAdded .setValue(docData.primaryName, forKey: kPrimaryName)
                        //                            entryAdded.setValue(docData.amount, forKey: kAmount)
                        //                            entryAdded.setValue(docData.tagDate, forKey: kTagDate)
                        //                            entryAdded.setValue("0", forKey: kIsUploaded)
                        //                            entryAdded.setValue(docData.docPath, forKey: kTagImageURL)
                        //                            entryAdded.setValue(docData.tagDescription, forKey: kTagDescription)
                        //                            entryAdded.setValue(docData.tagType, forKey: kTagType)
                        //                            entryAdded.setValue((docData.tagStatus as NSNumber).stringValue, forKey: kTagStatus)
                        //
                        //                            let data = docData.secondaryTag?.data(using: String.Encoding.utf8)
                        //                            let secondaryTagArray  = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSArray
                        //
                        //                            let secondaryTagArrayWithKey = NSMutableArray()
                        //
                        //                            for (_, element) in secondaryTagArray.enumerated() {
                        //                                let dict = NSMutableDictionary()
                        //                                dict .setValue(element, forKey: "Secondary_Name")
                        //                                secondaryTagArrayWithKey.add(dict)
                        //                            }
                        //                            entryAdded.setValue(secondaryTagArrayWithKey, forKey: kSecondaryTag)
                        //                            imageArray.add(entryAdded)
                        //                            matchedPrimaryTag .setValue(imageArray, forKey: kPrimaryImages)
                        //self.primaryTagArray.insert(matchedPrimaryTag, at: 0)
                        
                    }
                    else
                    {
                        //                            let newPrimaryTagAdded = NSMutableDictionary()
                        //                            let imageArray = NSMutableArray()
                        //
                        //                            let entryAdded = NSMutableDictionary()
                        //                            entryAdded .setValue(docData.primaryName, forKey: kPrimaryName)
                        //                            entryAdded.setValue(docData.amount, forKey: kAmount)
                        //                            entryAdded.setValue(docData.tagDate, forKey: kTagDate)
                        //                            entryAdded.setValue("0", forKey: kIsUploaded)
                        //                            entryAdded.setValue(docData.tagDescription, forKey: kTagDescription)
                        //                            entryAdded.setValue(docData.docPath, forKey: kTagImageURL)
                        //
                        //                            let data = docData.secondaryTag?.data(using: String.Encoding.utf8)
                        //                            let secondaryTagArray  = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSArray
                        //                            let secondaryTagArrayWithKey = NSMutableArray()
                        //
                        //                            for (_, element) in secondaryTagArray.enumerated() {
                        //                                let dict = NSMutableDictionary()
                        //                                dict .setValue(element, forKey: "Secondary_Name")
                        //                                secondaryTagArrayWithKey.add(dict)
                        //                            }
                        //                            entryAdded.setValue(secondaryTagArrayWithKey, forKey: kSecondaryTag)
                        //                            imageArray.add(entryAdded)
                        //
                        //                            newPrimaryTagAdded.setValue(docData.primaryName, forKey: kPrimaryName)
                        //                            newPrimaryTagAdded.setValue(docData.amount, forKey: kTotal)
                        //                            newPrimaryTagAdded.setValue(imageArray, forKey: kPrimaryImages)
                        //  self.primaryTagArray.insert(newPrimaryTagAdded, at: 0)
                        
                    }
                    
                }
            }
            catch let err as NSError {
                print(err.debugDescription)
            }
            
        }
        else{
            var tagMutable = NSMutableArray()
            if((kUserDefaults.value(forKey: "savedTag")) != nil){
                let tagArrayFetched = kUserDefaults.value(forKey: "savedTag") as! NSArray
                tagMutable = tagArrayFetched.mutableCopy() as! NSMutableArray
                tagMutable = tagMutable.removeUploaded()
                
                //                    print(tagMutable)
                //                    var matchedPrimaryTag = NSDictionary()
                
                //                    for (index, element) in tagMutable.enumerated() {
                //                        print("Item \(index): \(element)")
                //                        let dict = element as! NSDictionary
                //                        let resultPredicate = NSPredicate(format: "Prime_Name == [c]%@", (dict.value(forKey: kPrimaryName) as! String))
                //                        let arr = self.primaryTagArray.filtered(using: resultPredicate)
                //                        if(arr.count > 0){
                //                            print(arr)
                //                            matchedPrimaryTag = (arr.first as! NSDictionary).mutableCopy() as! NSMutableDictionary
                //                            //self.primaryTagArray.remove(matchedPrimaryTag)
                //                            let imageArray = (matchedPrimaryTag.value(forKey: kPrimaryImages) as! NSArray).mutableCopy() as! NSMutableArray
                //                            let arr = dict.value(forKey: kPrimaryImages) as! NSArray
                //                            imageArray.add(arr.firstObject as Any)
                //                            print(matchedPrimaryTag)
                //                            matchedPrimaryTag .setValue(imageArray.noDuplicates(byKey: kTagImageURL), forKey: kPrimaryImages)
                //                           // self.primaryTagArray.insert(matchedPrimaryTag, at: 0)
                //                        }
                //                        else{
                //                            let newTagAdded = NSMutableDictionary()
                //                            newTagAdded .setValue(dict .value(forKey: kPrimaryName), forKey: kPrimaryName)
                //                            newTagAdded .setValue(dict .value(forKey: kAmount), forKey: kTotal)
                //                            let imageArray = NSMutableArray()
                //                            let arr = dict.value(forKey: kPrimaryImages) as! NSArray
                //                            imageArray.add(arr.firstObject as Any)
                //                            newTagAdded .setValue(imageArray, forKey: kPrimaryImages)
                //                            // tagMutable.add(newTagAdded)
                //                         //   self.primaryTagArray.insert(newTagAdded, at: 0)
                //                        }
                //                    }
            }
            
            if(Reachability.isConnectedToNetwork()){
                let myDelegate = UIApplication.shared.delegate as? AppDelegate
                myDelegate?.uploadImageToS3_withTags(tagMutable: tagMutable)
            }
        }
    }
    
    // MARK: - API to get data
    
    func getHomeData(){
        
        if(!Reachability.isConnectedToNetwork()){
            let actionSheetController: UIAlertController = UIAlertController(title: kZoddl, message: "Seems like you are not connected to internet. Please check your internet connection.", preferredStyle: .alert)
            
            let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { action -> Void in
                if(self.refreshControl != nil){
                    self.refreshControl.endRefreshing()
                }
            }
            actionSheetController.addAction(okAction)
            self.present(actionSheetController, animated: true, completion: nil)
        }
        else{
            fetchData = false
            let paramDict : Dictionary<String, AnyObject> = [
                kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
                ]
            
            ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: false, params: paramDict, apiName: "Customer_Api/homedata") { (result, error) in
                
                if(!(error != nil)){
                    
                    if (result![kResponseCode]! as? String == "200"){
                        self.userTagDictionary =  result![kAPIPayload]! as! NSDictionary
                        self.categoryArray = self.userTagDictionary.allValues as NSArray
                        self.categoryArray = self.categoryArray .reversed() as NSArray
                        self.setPieChart()
                        self.refreshControl.endRefreshing()
                        self.homeTableView.reloadData()
                        self.initialMethod()
                    }
                    else {
                        self.refreshControl.endRefreshing()
                        presentAlert(kZoddl, msgStr: result![kResponseMessage]! as? String, controller: self)
                    }
                    
                } else {
                    self.refreshControl.endRefreshing()
                    presentAlert("", msgStr: error?.localizedDescription, controller: self)
                }
                
            }
            
        }
    }
    
    // MARK: - API to get all tags
    
    func getAllPrimaryTags(){
        
        let paramDict : Dictionary<String, AnyObject> = [
            kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
            ]
        self.primaryTagArray.removeAllObjects()
        
        ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: true, params: paramDict, apiName: "Customer_Api/reportprimarytag") { (result, error) in
            
            if(!(error != nil)){
                if (result![kResponseCode]! as? String == "200"){
                    let resultDict:Dictionary<String, AnyObject> = result as! Dictionary
                    self.primaryTagArray = (resultDict[kPrimaryTag]! as! NSArray).mutableCopy() as! NSMutableArray
                    let tagCell = self.homeTableView.dequeueReusableCell(withIdentifier: "CAHomeTagCell") as? CAHomeTagCell
                    tagCell?.tagCollectionView.reloadData()
                    self.tagTableView.reloadData()
                    self.primaryTagArray = checkNull(inputValue:self.primaryTagArray) as! NSMutableArray
                }
                else {
                    presentAlert(kZoddl, msgStr: result![kResponseMessage]! as? String, controller: self)
                }
                
            } else {
                presentAlert("", msgStr: error?.localizedDescription, controller: self)
            }
            
        }
    }
    
    
    
    
    // MARK: - API to get secondary tags
    
    func getAllSecondaryTags(){
        
        let paramDict : Dictionary<String, AnyObject> = [
            kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
            ]
        
        ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: true, params: paramDict, apiName: "Customer_Api/reportsecondarytag") { (result, error) in
            
            if(!(error != nil)){
                if (result![kResponseCode]! as? String == "200"){
                    let resultDict:Dictionary<String, AnyObject> = result as! Dictionary
                    self.secondaryTagArray = (resultDict[kSecondaryTag]! as! NSArray).mutableCopy() as! NSMutableArray
                    self.secondaryTagArray = checkNull(inputValue:self.secondaryTagArray) as! NSMutableArray
                    
                    kUserDefaults.set(self.secondaryTagArray, forKey: kAllSecondaryTags)
                    kUserDefaults.synchronize()
                    
                }
                else {
                    presentAlert(kZoddl, msgStr: result![kResponseMessage]! as? String, controller: self)
                }
                
            } else {
                presentAlert("", msgStr: error?.localizedDescription, controller: self)
            }
            
        }
    }
    
    
    
    // MARK: - Get screenshot
    
    func sendImageName(imageName: String) {
        
        ServiceHelper.sharedInstanceHelper.hideHud()
        
        let addTagPopUpVC: CAAddTagPopUpViewController = CAAddTagPopUpViewController(nibName:"CAAddTagPopUpViewController", bundle: nil)
        addTagPopUpVC.addTagDelegate = self
        addTagPopUpVC.navigationTitleString = "Add Tag"
        addTagPopUpVC.modalPresentationStyle = .overCurrentContext
        addTagPopUpVC.modalTransitionStyle = .crossDissolve
        addTagPopUpVC.docPathLocal = documentPath
        addTagPopUpVC.imageURL = imageName
        addTagPopUpVC.docExtension = documentExtension
        addTagPopUpVC.isDocumentType = true
        addTagPopUpVC.isManualTag = false
        
        self.present(addTagPopUpVC, animated: true, completion: nil)
    }
    
    
    
    // MARK: - API to get secondary tags
    
    func getTopFiveElements(){
        
        let paramDict : Dictionary<String, AnyObject> = [
            kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
            ]
        
        ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: true, params: paramDict, apiName: "Customer_Api/toplistprimetagdata") { (result, error) in
            
            if(!(error != nil)){
                if (result![kResponseCode]! as? String == "200"){
                    let resultDict:Dictionary<String, AnyObject> = result as! Dictionary
                    let tagListArray = resultDict[kAPIPayload] as! NSArray
                 
                    self.cashPlusArray = ((tagListArray.object(at: 0) as AnyObject).value(forKey: kCashPlus) as! NSArray).mutableCopy() as! NSMutableArray
                    self.cashMinusArray = ((tagListArray.object(at: 1) as AnyObject).value(forKey: kCashMinus) as! NSArray).mutableCopy() as! NSMutableArray
                    self.bankPlusArray = ((tagListArray.object(at: 2) as AnyObject).value(forKey: kBankPlus) as! NSArray).mutableCopy() as! NSMutableArray
                    self.bankMinusArray = ((tagListArray.object(at: 3) as AnyObject).value(forKey: kBankMinus) as! NSArray).mutableCopy() as! NSMutableArray
                    self.otherArray = ((tagListArray.object(at: 4) as AnyObject).value(forKey: kOther) as! NSArray).mutableCopy() as! NSMutableArray
                    self.fetchTopFive = true
                    
                    self.unitsSold.insert(self.replaceBlankStringWithZero(string:(self.cashPlusArray.object(at: 0)as AnyObject).value(forKey: kTotalAmout) as! String), at: 0)
                    self.unitsSold.insert(self.replaceBlankStringWithZero(string:(self.cashMinusArray.object(at: 0)as AnyObject).value(forKey: kTotalAmout) as! String), at: 1)
                    self.unitsSold.insert(self.replaceBlankStringWithZero(string:(self.bankPlusArray.object(at: 0)as AnyObject).value(forKey: kTotalAmout) as! String), at: 2)
                    self.unitsSold.insert(self.replaceBlankStringWithZero(string:(self.bankMinusArray.object(at: 0)as AnyObject).value(forKey: kTotalAmout) as! String), at: 3)
                    self.unitsSold.insert(self.replaceBlankStringWithZero(string:(self.otherArray.object(at: 0)as AnyObject).value(forKey: kTotalAmout) as! String), at: 4)
                    
       
                    self.unitsBought.insert(self.replaceBlankStringWithZero(string:(self.cashPlusArray.object(at: 1)as AnyObject).value(forKey: kTotalAmout) as! String), at: 0)
                    self.unitsBought.insert(self.replaceBlankStringWithZero(string:(self.cashMinusArray.object(at: 1)as AnyObject).value(forKey: kTotalAmout) as! String), at: 1)
                    self.unitsBought.insert(self.replaceBlankStringWithZero(string:(self.bankPlusArray.object(at: 1)as AnyObject).value(forKey: kTotalAmout) as! String), at: 2)
                    self.unitsBought.insert(self.replaceBlankStringWithZero(string:(self.bankMinusArray.object(at: 1)as AnyObject).value(forKey: kTotalAmout) as! String), at: 3)
                    self.unitsBought.insert(self.replaceBlankStringWithZero(string:(self.otherArray.object(at: 1)as AnyObject).value(forKey: kTotalAmout) as! String), at: 4)
                    
                    self.uBought.insert(self.replaceBlankStringWithZero(string:(self.cashPlusArray.object(at: 2)as AnyObject).value(forKey: kTotalAmout) as! String), at: 0)
                    self.uBought.insert(self.replaceBlankStringWithZero(string:(self.cashMinusArray.object(at: 2)as AnyObject).value(forKey: kTotalAmout) as! String), at: 1)
                    self.uBought.insert(self.replaceBlankStringWithZero(string:(self.bankPlusArray.object(at: 2)as AnyObject).value(forKey: kTotalAmout) as! String), at: 2)
                    self.uBought.insert(self.replaceBlankStringWithZero(string:(self.bankMinusArray.object(at: 2)as AnyObject).value(forKey: kTotalAmout) as! String), at: 3)
                    self.uBought.insert(self.replaceBlankStringWithZero(string:(self.otherArray.object(at: 2)as AnyObject).value(forKey: kTotalAmout) as! String), at: 4)
                    
                    
                    self.u4Bought.insert(self.replaceBlankStringWithZero(string:(self.cashPlusArray.object(at: 3)as AnyObject).value(forKey: kTotalAmout) as! String), at: 0)
                    self.u4Bought.insert(self.replaceBlankStringWithZero(string:(self.cashMinusArray.object(at: 3)as AnyObject).value(forKey: kTotalAmout) as! String), at: 1)
                    self.u4Bought.insert(self.replaceBlankStringWithZero(string:(self.bankPlusArray.object(at: 3)as AnyObject).value(forKey: kTotalAmout) as! String), at: 2)
                    self.u4Bought.insert(self.replaceBlankStringWithZero(string:(self.bankMinusArray.object(at: 3)as AnyObject).value(forKey: kTotalAmout) as! String), at: 3)
                    self.u4Bought.insert(self.replaceBlankStringWithZero(string:(self.otherArray.object(at: 3)as AnyObject).value(forKey: kTotalAmout) as! String), at: 4)
                    
                    
                    self.u5Bought.insert(self.replaceBlankStringWithZero(string:(self.cashPlusArray.object(at: 4)as AnyObject).value(forKey: kTotalAmout) as! String), at: 0)
                    self.u5Bought.insert(self.replaceBlankStringWithZero(string:(self.cashMinusArray.object(at: 4)as AnyObject).value(forKey: kTotalAmout) as! String), at: 1)
                    self.u5Bought.insert(self.replaceBlankStringWithZero(string:(self.bankPlusArray.object(at: 4)as AnyObject).value(forKey: kTotalAmout) as! String), at: 2)
                    self.u5Bought.insert(self.replaceBlankStringWithZero(string:(self.bankMinusArray.object(at: 4)as AnyObject).value(forKey: kTotalAmout) as! String), at: 3)
                    self.u5Bought.insert(self.replaceBlankStringWithZero(string:(self.otherArray.object(at: 4)as AnyObject).value(forKey: kTotalAmout) as! String), at: 4)
         
                    //self.setChart()
                    self.topDetailsTableView.reloadData()
                }
                else {
                    presentAlert(kZoddl, msgStr: result![kResponseMessage]! as? String, controller: self)
                }
                
            } else {
                presentAlert("", msgStr: error?.localizedDescription, controller: self)
            }
            
        }
    }
    
    func replaceBlankStringWithZero(string : String) -> Double {
        let value : Double
        if(string == ""){
            value = 0.0
        }else{
            value = Double(string)!
        }
        return value
    }
    
    
    
    
    @objc func refreshView(notification: NSNotification){
        self.getAllPrimaryTags()
        self.getHomeData()
        DispatchQueue.main.async {
            let tagCell = self.homeTableView.dequeueReusableCell(withIdentifier: "CAHomeTagCell") as? CAHomeTagCell
            tagCell?.tagCollectionView.reloadData()
            self.tagTableView.reloadData()
        }
    }
    
    func getSearchString(searchString: String, searchType: String) {
        
        let tagListVC: CATagListViewController = CATagListViewController(nibName:"CATagListViewController", bundle:nil)
        tagListVC.isFromSearch = true
        tagListVC.searchString = searchString
        tagListVC.navBarTitleString = searchString
        if(searchType == "image gallery"){
            tagListVC.isFromGallery = true
        }else{
            tagListVC.isFromGallery = false
            tagListVC.isFromDocument = true

        }
        self.navigationController?.pushViewController(tagListVC, animated: true)
    }
    
    
}
