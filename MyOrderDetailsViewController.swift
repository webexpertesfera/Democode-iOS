//
//  MyOrderDetailsViewController.swift
//  Ecommerce Billing
//
//  Created by ip-d on 13/05/21.
//

import UIKit
import IBAnimatable

// Mark : - Create Enum for Order Cases
enum OrderStatus: String {
    case placed
    case confirmed
    case shipped
    case outOfDelievery
    case processed = "processing"
    case delievered
    case pending
    case onHold = "on-hold"
    case completed = "completed"
    case cancelled = "cancelled"
    case refunded
    case failed
}

class MyOrderDetailsViewController: UIViewController {

    // Mark : - Outlet Declartions
    @IBOutlet weak var trackOrderHeadingLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var statuslabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var orderIDLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productImageView: AnimatableImageView!
    @IBOutlet weak var btnStack_View: UIStackView!
    
    //Order Placed
    @IBOutlet weak var orderPlacedHeadingLabel: UILabel!
    @IBOutlet weak var orderPlacedDescriptionLabel: UILabel!
    @IBOutlet weak var orderPlacedImageView: AnimatableImageView!
    
    //Order Confirmed
    @IBOutlet weak var orderConfirmedHeadinglabel: UILabel!
    @IBOutlet weak var orderConfirmedDescriptionLabel: UILabel!
    @IBOutlet weak var orderConfirmedImageView: AnimatableImageView!
    
    //Order Processed
    @IBOutlet weak var orderProcessedHeadingLabel: UILabel!
    @IBOutlet weak var orderProcessedDescriptionLabel: UILabel!
    @IBOutlet weak var orderProcessedImageView: AnimatableImageView!
    
    //Ready To Ship
    @IBOutlet weak var readyToShipLabel: UILabel!
    @IBOutlet weak var readyToShipDescriptionLabel: UILabel!
    @IBOutlet weak var readyToShipImageView: AnimatableImageView!
    
    //Out for delievery
    @IBOutlet weak var outForDelieveryHeadingLabel: UILabel!
    @IBOutlet weak var outForDescriptionLabel: UILabel!
    @IBOutlet weak var statusCollectorbackView: UIView!
    @IBOutlet weak var outForDelieveryImageView: AnimatableImageView!
    
    @IBOutlet weak var canceledView: UIView!
    
    @IBOutlet weak var refundAndReturnButton: UIButton!
    @IBOutlet weak var reedemButton: UIButton!
    
    @IBOutlet var nodeHeadViews: [UIView]!
    @IBOutlet var dottedLineViews: [AnimatableView]!
    var descriptionLabels: [UILabel] = []
    var headingLabels: [UILabel] = []
    var headingImages: [AnimatableImageView] = []
    
    // Mark : - ViewModel Object Declartions
    var viewModel: MyOrdersViewModel = MyOrdersViewModel()
    
    // Mark : - variable Declartions
    var productID = String()
    var productAmount = String()
    var orderID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Mark : - initialization label object with current info
        headingImages = [
            orderPlacedImageView,
            orderConfirmedImageView,
            orderProcessedImageView,
            readyToShipImageView,
            outForDelieveryImageView
        ]
        
        descriptionLabels = [
            orderPlacedDescriptionLabel,
            orderConfirmedDescriptionLabel,
            orderProcessedDescriptionLabel,
            readyToShipDescriptionLabel,
            outForDescriptionLabel
        ]
        
        headingLabels = [
            orderPlacedHeadingLabel,
            orderConfirmedHeadinglabel,
            orderProcessedHeadingLabel,
            readyToShipLabel,
            outForDelieveryHeadingLabel
        ]
        
        descriptionLabels.forEach { $0.text = "" }
        
        // Mark : - called required functions
        bindButton()
        setViews()
        getOrderDetails()
        setData()
    }
    
    func setViews() {
        // Mark : - initial all outlet & data source objects
        reedemButton.isHidden = true
        refundAndReturnButton.isHidden = true
        refundAndReturnButton.addTarget(self, action: #selector(tappedOnRefundButton), for: .touchUpInside)
        reedemButton.addTarget(self, action: #selector(tappedOnRedeemdButton), for: .touchUpInside)
        // Mark : - cerate Dotted button
        nodeHeadViews.forEach({$0.layer.cornerRadius = ($0.frame.height / 2)})
        nodeHeadViews.forEach({$0.backgroundColor = .TOGOBlueColor})
        dottedLineViews.forEach({$0.backgroundColor = .clear})
//        dottedLineViews.forEach({$0.makeViewDotted(withColor: (.TOGOBlueColor ?? .blue))})
        dottedLineViews.forEach { $0.borderWidth = 1; $0.borderColor = (.TOGOBlueColor ?? .blue)}
        dottedLineViews.forEach { $0.borderType = .dash(dashLength: 4, spaceLength: 4)}
        
        // Mark : - initial button Text
        refundAndReturnButton.setTitle("RETURN", for: .normal)
        refundAndReturnButton.setTitleColor(.white, for: .normal)
        refundAndReturnButton.titleLabel?.textColor = .white
        refundAndReturnButton.backgroundColor = UIColor(named: "BlueTextColor")
        
        reedemButton.setTitle("REDEEM", for: .normal)
        reedemButton.setTitleColor(.white, for: .normal)
        reedemButton.titleLabel?.textColor = .white
        reedemButton.backgroundColor = UIColor(named: "BlueTextColor")
    }
    
    func bindButton() {
        backButton.on(.touchUpInside) { (sender, event) in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // Mark : - get order infowith the use of objece of viewmodel
    func getOrderDetails() {
        Indicator.shared.show(uiView: self.view)
        viewModel.getMyOrderDetails { (isSUccess, message) in
            Indicator.shared.hide(uiView: self.view)
            if isSUccess {
                self.setData()
            } else {
                self.showDefaultAlert(Message: message)
            }
        }
    }
    
    // Mark : - Set all data in respective Object of View
    func setData() {
        statuslabel.text = (viewModel.orderDetails?.status ?? "").capitalized
        dateLabel.text = viewModel.orderDetails?.date ?? ""
        orderIDLabel.text = String(viewModel.orderDetails?.orderID ?? 0)
        productNameLabel.text = (viewModel.orderDetails?.serviceTitle ?? "").htmlToString
        productImageView.sd_setImage(with: URL(string: viewModel.orderDetails?.image ?? ""), completed: nil)
      //  self.orderID = viewModel.orderDetails?.orderID
      //  self.productID = viewModel.orderDetails?.status
       // print("Order data gurmeet",viewModel.orderDetails)
        
        // Mark : - Handle all cases with order info & update UI according Data recieve in API Response
        switch viewModel.orderDetails?.getOrderStatus ?? .pending {
        case .processed:
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 3) {
                
                self.dottedLineViews.first?.borderType = .solid
                self.dottedLineViews.first?.borderColor = .blue

                self.dottedLineViews[1].borderType = .solid
                self.dottedLineViews[1].borderColor = .blue
                
                self.headingImages.first?.backgroundColor = .green
                
                self.headingImages[1].backgroundColor = .green
                self.headingImages[2].backgroundColor = .green
            }

        case .completed:
            dottedLineViews.forEach { $0.borderType = .solid }
            dottedLineViews.forEach { $0.borderColor = .blue }
            headingImages.forEach { $0.backgroundColor = .green }
            
            headingImages.forEach { $0.superview?.isHidden = true }
            dottedLineViews.forEach { $0.isHidden = true }
            nodeHeadViews.forEach { $0.isHidden = true }
            
            orderPlacedHeadingLabel.superview?.superview?.isHidden = true
            trackOrderHeadingLabel.text = ""
            refundAndReturnButton.isHidden = false
            reedemButton.isHidden = false
            statusCollectorbackView.isHidden = true
            
            let getredeemstatus = self.viewModel.orderDetails?.isredeem?.getDescription
            print("Get redeem info getorderredeemstatus",getredeemstatus)
            
            if getredeemstatus == "true" {
                self.btnStack_View.isHidden = false
            } else {
                self.btnStack_View.isHidden = true
            }
            
            
        case .pending:
            orderPlacedImageView.backgroundColor = .green

        default:
            headingImages.forEach { $0.superview?.isHidden = true }
            dottedLineViews.forEach { $0.isHidden = true }
            nodeHeadViews.forEach { $0.isHidden = true }
            
            self.canceledView.isHidden = false
            let ll = UILabel()
            ll.translatesAutoresizingMaskIntoConstraints = false
            canceledView.addSubview(ll)
            
            NSLayoutConstraint.activate([
                ll.leadingAnchor.constraint(equalTo: canceledView.leadingAnchor),
                ll.trailingAnchor.constraint(equalTo: canceledView.trailingAnchor),
                ll.topAnchor.constraint(equalTo: canceledView.topAnchor),
                ll.bottomAnchor.constraint(equalTo: canceledView.bottomAnchor)
            ])
            
            ll.textAlignment = .center
            ll.text = self.viewModel.orderDetails?.getMessages ?? ""
        }
    }
    
    // Mark : - Custome event
    @objc
    func tappedOnRefundButton() {
        self.showAlertWithActionOkandCancel(Message: "Are you sure you want to refund for this product.", OkButtonTitle: "Agree", CancelButtonTitle: "Cancel") {
            self.getOrderRefundRedeemAPI(type: "return")
        }
    }
    
    // Mark : - Custome event
    @objc
    func tappedOnRedeemdButton() {
        self.showAlertWithActionOkandCancel(Message: "Are you sure you want to redeem your points for this product.", OkButtonTitle: "Redeem", CancelButtonTitle: "Cancel") {
            self.getOrderRedeemAPI()
        }
        
        
    }
    
    // Mark : - API called for get redeen Info of current order
    func getOrderRedeemAPI() {
        Indicator.shared.show(uiView: self.view)
        viewModel.getMyRewardOnShopping { (isSUccess, message) in
            Indicator.shared.hide(uiView: self.view)
            if isSUccess {
                print("Order Redeem Success Gurmeet")
                self.getOrderRefundRedeemAPI(type: "redeem")
            } else {
                print("Order Redeem Error Gurmeet")
            }
        }
    }
    
    // Mark : - API called for get refund Info
    func getOrderRefundRedeemAPI(type:String) {
        Indicator.shared.show(uiView: self.view)
        viewModel.getMyRefundRedeem(Redeem_type: type) { (isSUccess, message) in
            Indicator.shared.hide(uiView: self.view)
            if isSUccess {
                self.getOrderDetails()
                print("Order Redeem Final Successs")
            } else {
                self.getOrderCancelRefundAPI()
                print("Order Redeem Final Error")
            }
        }
    }
    
    // Mark : - API called for get cancelled refund
    func getOrderCancelRefundAPI() {
        Indicator.shared.show(uiView: self.view)
        viewModel.getMyRewardCanelled { (isSUccess, message) in
            Indicator.shared.hide(uiView: self.view)
            if isSUccess {
                self.getOrderDetails()
                print("Order Redeem Cancel Successs")
            } else {
                print("Order Redeem Cancel Error")
            }
        }
    }
    
}
