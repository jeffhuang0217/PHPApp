import UIKit

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,NSXMLParserDelegate
{
    @IBOutlet weak var myTableView: UITableView!
    //記錄xml的標籤名稱
    var tagName = ""
    //記錄xml的標籤內容
    var tagContent = ""
    //記錄從xml解析出來的單一資料行
    var dicRow = [String:String]()
    //記錄從xml解析出來的完整資料表
    var arrTable = [[String:String]]()
    //下一頁的畫面
    var detailVC:DetailViewController!
//    //目前選定的儲存格
    var selectedRow = -1
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        myTableView.delegate = self
        myTableView.dataSource = self
        //取得網站上的xml，並且進行解析
        let url = NSURL(string: "http://www.studio-pj.com/class_exercise/select_data.php")
        let request = NSURLRequest(URL: url!)
        //非同步連接
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, xmlData, error) -> Void in
            //啟動xml解析
            let xmlParser = NSXMLParser(data: xmlData)
            xmlParser.delegate = self
            xmlParser.parse()
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        //重載tableView的資料
        myTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //即將轉到下一頁
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        println("prepareForSegue")
        //取得下一頁畫面
        detailVC = segue.destinationViewController as! DetailViewController
    }
    
    //MARK: UITableViewDataSource
    //資料筆數
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrTable.count
    }
    //準備每一個儲存格
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! MyTableViewCell
        cell.lblNo.text = arrTable[indexPath.row]["no"]
        cell.lblName.text = arrTable[indexPath.row]["name"]
        if arrTable[indexPath.row]["gender"] == "1"
        {
            cell.lblGender.text = "男"
        }
        else
        {
            cell.lblGender.text = "女"
        }
        //以非同步方式取得欄位圖片
        //方法一
//        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
//        dispatch_async(queue, { () -> Void in
//            let url = NSURL(string: "http://www.studio-pj.com/class_exercise/" + self.arrTable[indexPath.row]["picture"]!)
//            if var imageData = NSData(contentsOfURL:url!)
//            
//            {
//                cell.imgPicture.image = UIImage(data: imageData)
//                //Todo: 將下載的圖片存到暫存區或本機端資料庫(Sqlite)
//                
//            }
//        })
        
        //方法二
        let url = NSURL(string: "http://www.studio-pj.com/class_exercise/" + self.arrTable[indexPath.row]["picture"]!)
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, imageData, error) -> Void in
            cell.imgPicture.image = UIImage(data: imageData)
        }
        
        //下一頁指示符號
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
//    //表格有幾個區段
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int
//    {
//        return 1
//    }
    
    //MARK: UITableViewDelegate
    //儲存格被點選時
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        println("點選第\(indexPath.row)格")
        selectedRow = indexPath.row
        //傳參數到下一頁
        detailVC.passData(sourceViewController: self)
    }
    
    //MARK: NSXMLParserDelegate
    //抓到開始xml標籤
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject])
    {
        //println("\(elementName)")
        tagName = elementName
    }
    
    //讀取xml標籤內容
    func parser(parser: NSXMLParser, foundCharacters string: String?)
    {
        //println("\(string!)")
        tagContent = string!
    }
    //抓到結束xml標籤
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
//        println("結束標籤：\(elementName),標籤內容：\(tagContent)")
        //當elementName為資料行時，將字典存入陣列
        if elementName == "student"
        {
            arrTable.append(dicRow)
//            dicRow = [String:String]()
        }
        else if elementName == "xmlTable"
        {
            //不做事
        }
            //當elementName為欄位時，將欄位存入字典
        else
        {
            dicRow[elementName] = tagContent
            //            dicRow[tagName] = tagContent
        }
    }
    //xml解析器已完成資料解析
    func parserDidEndDocument(parser: NSXMLParser)
    {
//        println("\(arrTable.count)")
//        println("\(arrTable)")
        //重新載入TableView資料
        myTableView.reloadData()
    }

}

