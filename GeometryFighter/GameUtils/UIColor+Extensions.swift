import UIKit
import SceneKit

let UIColorList:[UIColor] = [
  UIColor.black,
  UIColor.white,
  UIColor.red,
  UIColor.lime,
  UIColor.blue,
  UIColor.yellow,
  UIColor.cyan,
  UIColor.silver,
  UIColor.gray,
  UIColor.maroon,
  UIColor.olive,
  UIColor.brown,
  UIColor.green,
  UIColor.lightGray,
  UIColor.magenta,
  UIColor.orange,
  UIColor.purple,
  UIColor.teal
]

extension UIColor {
  
  public static func random() -> UIColor {
    let maxValue = UIColorList.count
    let rand = Int(arc4random_uniform(UInt32(maxValue)))
    return UIColorList[rand]
  }
  
  public static var lime: UIColor {
    return UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
  }
  
  public static var silver: UIColor {
    return UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1.0)
  }
  
  public static var maroon: UIColor {
    return UIColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0)
  }
  
  public static var olive: UIColor {
    return UIColor(red: 0.5, green: 0.5, blue: 0.0, alpha: 1.0)
  }
  
  public static var teal: UIColor {
    return UIColor(red: 0.0, green: 0.5, blue: 0.5, alpha: 1.0)
  }
  
  public static var navy: UIColor {
    return UIColor(red: 0.0, green: 0.0, blue: 128, alpha: 1.0)
  }
}
