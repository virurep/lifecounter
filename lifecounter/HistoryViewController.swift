import UIKit

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var recordedEvents: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "History"
        displayEvents()
    }
    
    func displayEvents() {
        var currentY: CGFloat = 20
        
        for event in recordedEvents {
            let label = UILabel()
            label.text = event
            label.numberOfLines = 0
            label.textAlignment = .left
            label.frame = CGRect(x: 20, y: currentY, width: view.frame.width - 40, height: 0)
            label.sizeToFit()
            
            scrollView.addSubview(label)
            
            currentY += label.frame.height + 10
        }
        
        scrollView.contentSize = CGSize(width: view.frame.width, height: currentY)
    }
}
