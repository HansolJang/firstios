//
//  ConcentrationThemeChoosetViewController.swift
//  CardGame
//
//  Created by HansolJang on 19. 10. 27..
//  Copyright © 2019 HansolJang. All rights reserved.
//

import UIKit

class ConcentrationThemeChooserViewController: UIViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func awakeFromNib() {
        splitViewController?.delegate = self
    }
    
    // 첫 화면으로 Detail 이 아닌, Master 가 나오도록 설정하는 딜리게이트
    // secondary : detail, primary: master
    // true : 현재화면을 detail로 바꾸지마 (프로그래머가 알아서 할꺼야)
    // false : 현재화면 가려도 돼
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        if let cvc = secondaryViewController as? ConcentationViewController {
            if cvc.theme == nil {
                return true
            }
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Choose Theme" {
            if let themeName = (sender as? UIButton)?.currentTitle,
                let theme = Theme.all.first(where: { (t: Theme) -> Bool in t.rawValue == themeName }) {
                if let cvc = segue.destination as? ConcentationViewController {
                    cvc.theme = theme
                    lastSeguedToConcentationViewController = cvc
                }
            }
        }
    }
    
    private var splitViewDetailConcentrationViewController: ConcentationViewController? {
        return splitViewController?.viewControllers.last as? ConcentationViewController
    }
    
    // 마지막으로 참조한 뷰컨트롤러를 참조
    private var lastSeguedToConcentationViewController: ConcentationViewController?
    
    @IBAction func changeTheme(_ sender: Any) {
        // ipad or + device
        // splitView 의 Detail 뷰로 ConcentationViewController 를 가지고 있으면 테마만 바꾸고 그대로 사용
        if let cvc = splitViewDetailConcentrationViewController {
            if let themeName = (sender as? UIButton)?.currentTitle,
                let theme = Theme.all.first(where: { (t: Theme) -> Bool in t.rawValue == themeName }) {
                cvc.theme = theme
            }
        }
        // iphone
        // 직전에 ConcentrationViewConroller 를 참조한 적이 있으면 테마만 바꾸고 그대로 사용
        else if let cvc = lastSeguedToConcentationViewController {
            if let themeName = (sender as? UIButton)?.currentTitle,
                let theme = Theme.all.first(where: { (t: Theme) -> Bool in t.rawValue == themeName }) {
                cvc.theme = theme
            }
            navigationController?.pushViewController(cvc, animated: true)
        }
        // 둘 다 해당하지 않을 경우 새 테마와 새 게임 시작
        else {
            performSegue(withIdentifier: "Choose Theme", sender: sender)
        }
    }
}
