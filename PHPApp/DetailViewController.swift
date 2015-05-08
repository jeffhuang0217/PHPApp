import UIKit
import MobileCoreServices  //供imagePicker的mediaType使用

class DetailViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var lblNo: UILabel!
    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var pkvGender: UIPickerView!
    @IBOutlet weak var pkvClass: UIPickerView!
    @IBOutlet weak var btnChangePhoto: UIButton!
    
    //PickerView的資料來源
    let arrGender = ["女","男"]
    let arrClass = ["手機程式開發","網頁程式設計"]
    //記錄來源VC
    var theSourceVC:ViewController!
    //圖片挑選器
    var imgPicker:UIImagePickerController!
    //記錄目前輸入元件的Y軸底部位置
    var currentObjectBottomYPosition:CGFloat = 0.0
    //判斷檔案是否上傳
    var isFileUploaded = true
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        pkvGender.delegate = self
        pkvGender.dataSource = self
        pkvClass.delegate = self
        pkvClass.dataSource = self
        //加上點按手勢收起鍵盤
        let tapGesture = UITapGestureRecognizer(target: self, action: "CloseKeyBoard")
        self.view.addGestureRecognizer(tapGesture)
        //語系本地化
        //NSLocalizedString("btnChangePhoto", tableName: "InfoPlist", bundle: NSBundle.mainBundle(), value: "", comment: "")
        btnChangePhoto.setTitle(NSLocalizedString("btnChangePhoto", tableName: "InfoPlist", bundle: NSBundle.mainBundle(), value: "", comment: ""), forState: UIControlState.Normal)
        //取得目前這一筆資料的字典
        let dicRow = theSourceVC.arrTable[theSourceVC.selectedRow]
        //將資料顯示於介面上
        lblNo.text = dicRow["no"]
        txtName.text = dicRow["name"]
        txtAddress.text = dicRow["address"]
        txtPhone.text = dicRow["phone"]
        txtEmail.text = dicRow["email"]
        //選定對應的性別
        pkvGender.selectRow((dicRow["gender"]! as NSString).integerValue, inComponent: 0, animated: false)
        //選定對應的班別
        for (arrIndex,item) in enumerate(arrClass)
        {
            if item == dicRow["class"]
            {
                pkvClass.selectRow(arrIndex, inComponent: 0, animated: false)
            }
            //println("(\(arrIndex),\(item))")
        }
        //顯示圖片
        let url = NSURL(string: "http://www.studio-pj.com/class_exercise/" + dicRow["picture"]!)
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, imageData, error) -> Void in
            self.imgPicture.image = UIImage(data: imageData)
        }
        //監聽鍵盤顯示
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        //監聽鍵盤收合
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: Target-Action
    //更換照片
    @IBAction func btnSelectPicture(sender: UIButton)
    {
        //初始化imgPicker
        imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        //指定使用相簿
        imgPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
//        imgPicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        //允許裁切照片
        imgPicker.allowsEditing = true
        //開啟相簿
        self.presentViewController(imgPicker, animated: true, completion: nil)
        //標示檔案未上傳
        isFileUploaded = false
    }
    //上傳照片
    @IBAction func btnFileUpload(sender: UIButton)
    {
        //制定上傳檔名
        let serverFileName = NSString(format: "%@.jpg", lblNo.text!) as! String
        //呼叫檔案上傳封裝方法
        FileUpload(imgPicture.image!, withURLString: "http://www.studio-pj.com/class_exercise/photo_upload.php", byFormInputID: "userfile", andNewFileName: serverFileName)
    }
    //拍照
    @IBAction func btnOpenCamera(sender: UIButton)
    {
        //初始化imgPicker
        imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        //檢查裝置是否支援相機
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        {
            let alert = UIAlertController(title: "找不到設備", message: "無法使用相機", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        //指定使用相機
        imgPicker.sourceType = UIImagePickerControllerSourceType.Camera
        //指定相機的功能
        imgPicker.mediaTypes = [kUTTypeImage]
        //允許裁切照片
        imgPicker.allowsEditing = true
        //開啟相機
        self.presentViewController(imgPicker, animated: true, completion: nil)
        //標示檔案未上傳
        isFileUploaded = false
    }
    //帶我去
    @IBAction func btnMapNavigation(sender: UIButton)
    {
    }
    //更新資料
    @IBAction func btnSaveData(sender: UIButton)
    {
        arrClass[pkvClass.selectedRowInComponent(0)]
        
        //原始的網址(注意：性別需代入%d)
        let strOriginURL = NSString(format: "http://www.studio-pj.com/class_exercise/update_data.php?name=%@&gender=%d&phone=%@&address=%@&email=%@&class=%@&no=%@",txtName.text,pkvGender.selectedRowInComponent(0),txtPhone.text,txtAddress.text,txtEmail.text,arrClass[pkvClass.selectedRowInComponent(0)],lblNo.text!)
        //網址編碼（避免中文亂碼）
        let strURL = strOriginURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        //傳送網址
        let url = NSURL(string: strURL)
        let request = NSURLRequest(URL: url!)
        //非同步連接
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, echoData, error) -> Void in
            //如果伺服器為付費主機，不會傳出額外訊息時
//            let strEchoMessage = String(NSString(data: echoData, encoding: NSUTF8StringEncoding)!)
            //如果伺服器更新成功時，還多傳出其他訊息時，必須做字串擷取
            let strEchoMessage = String(NSString(data: echoData, encoding: NSUTF8StringEncoding)!.substringWithRange(NSMakeRange(0, 1)))
            if strEchoMessage == "1"
            {
                let alert = UIAlertController(title: "伺服器回應", message: "資料修改成功", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                //同步異動上一頁arrTable內對應的資料（返回時viewWillAppear需做tableView資料重載）
                self.theSourceVC.arrTable[self.theSourceVC.selectedRow]["name"] = self.txtName.text
                self.theSourceVC.arrTable[self.theSourceVC.selectedRow]["phone"] = self.txtPhone.text
                self.theSourceVC.arrTable[self.theSourceVC.selectedRow]["address"] = self.txtAddress.text
                self.theSourceVC.arrTable[self.theSourceVC.selectedRow]["email"] = self.txtEmail.text
                self.theSourceVC.arrTable[self.theSourceVC.selectedRow]["gender"] = String(self.pkvGender.selectedRowInComponent(0))
                self.theSourceVC.arrTable[self.theSourceVC.selectedRow]["class"] = self.arrClass[self.pkvClass.selectedRowInComponent(0)]
                //Todo: 確認是否要上傳檔案
                
            }
            else
            {
                let alert = UIAlertController(title: "伺服器回應", message: "資料修改失敗", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    //按下return鍵收起鍵盤
    @IBAction func didEndOnExit(sender: UITextField)
    {
        sender.resignFirstResponder()
    }
    
    //點選輸入欄位時
    @IBAction func FieldTouched(sender: UITextField)
    {
        //計算目前元件的y軸底端位置
        currentObjectBottomYPosition = sender.frame.origin.y + sender.frame.size.height
        println("元件的y軸底端位置:\(currentObjectBottomYPosition)")
    }
    
    //MARK: 自訂方法
    //接收上一頁傳來的參數
    func passData(sourceViewController sourceVC:ViewController)
    {
        println("下一頁的：\(sourceVC.arrTable)")
        //將來源VC記錄到全域變數
        theSourceVC = sourceVC
        //這裏不能動UI
    }
    
    //收回鍵盤（配合view上的點按手勢）
    func CloseKeyBoard()
    {
        //請所有會喚起鍵盤的物件都要交出第一回應權
//        txtName.resignFirstResponder()
//        txtAddress.resignFirstResponder()
//        txtEmail.resignFirstResponder()
//        txtPhone.resignFirstResponder()
        for subView in self.view.subviews
        {
            if subView is UITextField
            {
                subView.resignFirstResponder()
            }
        }
    }
    
    //檔案上傳封裝方法(第一個參數：已選定的圖片，第二個參數：處理上傳檔案的photo_upload.php，第三個參數：提交檔案的input file id，第四個參數：存放到伺服器端的檔名)
    func FileUpload(image:UIImage,withURLString urlString:String,byFormInputID idName:String,andNewFileName newFileName:String)
    {
        //轉換圖檔成為NSData(壓縮jpg)
        let imageData:NSData = UIImageJPEGRepresentation(image, 10)
        //準備URLRequest
        let request = NSMutableURLRequest()     //注意不能寫成：var request = NSURLRequest()
        request.URL = NSURL(string: urlString)  //從參數取得上傳檔案的網址
        request.HTTPMethod = "POST"
        
        //產生boundary識別碼來界定要傳送的資料
        let boundary = NSProcessInfo.processInfo().globallyUniqueString
        // set Content-Type in HTTP header
        var contentType = "multipart/form-data; boundary=" + boundary
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        //準備Post Body
        var body = NSMutableData()
        
        //以boundary識別碼來製作分隔界線（開始）
        let boundaryStart = NSString(format: "\r\n--%@\r\n", boundary)
        //Post Body加入分隔界線（開始）
        body.appendData(boundaryStart.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        //加入Form
        let formData = NSString(format: "Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", idName, newFileName)    //此行的userfile需對應到接收上傳的php內變數名稱，newFileName為上傳後存檔的名稱
        //Post Body加入Form
        body.appendData(formData.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        //檔案型態
        let fileType = NSString(format: "Content-Type: application/octet-stream\r\n\r\n")
        body.appendData(fileType.dataUsingEncoding(NSUTF8StringEncoding)!)
        //加入圖檔
        body.appendData(imageData)
        
        //以boundary識別碼來製作分隔界線（結束）
        var boundaryEnd = NSString(format: "\r\n--%@--\r\n", boundary)
        //Post Body加入分隔界線（結束）
        body.appendData(boundaryEnd.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        //把Post Body交給URL Reqeust
        request.HTTPBody = body
        
        //<方法一>使用同步傳輸
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        //連接網路，送出request
        var returnData:NSData = NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: nil)!
        //取得上傳網頁的回傳值
        let returnString = NSString(data: returnData, encoding: NSUTF8StringEncoding)
        println("\(returnString)")
        //如果檔案上傳成功，記錄檔案上傳狀態為已上傳
        if returnString == "success"
        {
            isFileUploaded = true
        }
    }
    
    //MARK: 監聽鍵盤事件
    //鍵盤顯示時被呼叫的事件
    func keyboardWillShow(sender:NSNotification)
    {
        println("鍵盤顯示")
        //取得通知中心的資料
        if let userInfo = sender.userInfo
        {
            //從通知中心的資料去取得鍵盤高度
            if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size.height
            {
                println("鍵盤彈出後的可視高度：\(self.view.frame.height - keyboardHeight)")
                //如果『元件所在位置的底緣高度』比『鍵盤彈出後的可視高度』還高
                if currentObjectBottomYPosition > self.view.frame.height - keyboardHeight
                {
                    //計算兩者間的差值，並移動view的高度位置
                    //currentObjectBottomYPosition - (self.view.frame.height - keyboardHeight)
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        self.view.frame = CGRectMake(0, -(self.currentObjectBottomYPosition - (self.view.frame.height - keyboardHeight)+20), self.view.frame.width, self.view.frame.height)
                    })
                }
            }
        }
    }
    //鍵盤收合時被呼叫的事件
    func keyboardWillHide(sender:NSNotification)
    {
        println("鍵盤收合")
        //view回復到原來位置
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        })
        //將元件的底緣位置歸零
        currentObjectBottomYPosition = 0
    }
    
    //MARK: UIPickerViewDataSource
    //滾輪數量
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    //可滾動的資料行數
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        if pickerView.tag == 0
        {
            return arrGender.count
        }
//        else if pickerView.tag == 1
//        {
//            return arrClass.count
//        }
        else
        {
            return arrClass.count
        }
    }
    
    //單一滾輪上顯示的資料
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
    {
        if pickerView.tag == 0
        {
            return arrGender[row]
        }
        else
        {
            return arrClass[row]
        }
    }
    
    //MARK: UIPickerViewDelegate
    
    
    
    //MARK: UIImagePickerControllerDelegate
    //選定圖片之後
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!)
    {
        //顯示圖片
        imgPicture.image = image
        //退掉圖片挑選畫面
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            //Todo: 記錄檔案的上傳狀態
            
            //清除imgPicker
            self.imgPicker = nil
        })
    }
    
}
