import Foundation
import UIKit

class ViewController : UIViewController {
    @IBOutlet weak var kenBurnsImageView: KenBurnsImageView!
    
    override func viewDidLoad() {
        
        ///
        // Images provided by University of Wisconsin-Madison
        // https://homepages.cae.wisc.edu/~ece533/images/
        ///
        
        let tests = [
        "https://homepages.cae.wisc.edu/~ece533/images/airplane.png",
        "https://homepages.cae.wisc.edu/~ece533/images/arctichare.png",
        "https://homepages.cae.wisc.edu/~ece533/images/baboon.png",
        "https://homepages.cae.wisc.edu/~ece533/images/barbara.png",
        "https://homepages.cae.wisc.edu/~ece533/images/boat.png",
        "https://homepages.cae.wisc.edu/~ece533/images/cat.png",
        "https://homepages.cae.wisc.edu/~ece533/images/fruits.png",
        "https://homepages.cae.wisc.edu/~ece533/images/frymire.png",
        "https://homepages.cae.wisc.edu/~ece533/images/girl.png",
        "https://homepages.cae.wisc.edu/~ece533/images/goldhill.png",
        "https://homepages.cae.wisc.edu/~ece533/images/lena.png"
            
        
        ]
        
        let urls = tests.map { (str) -> URL in
            return URL(string: str)!
        }
        
        kenBurnsImageView.setDuration(min: 4, max: 5)
        kenBurnsImageView.setImageQueue(withUrls: urls, placeholders: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        kenBurnsImageView.startAnimating()
    }
}
