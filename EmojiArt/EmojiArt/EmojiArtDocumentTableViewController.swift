//
//  EmojiArtDocumentTableViewController.swift
//  EmojiArt
//
//  Created by HansolJang on 19. 11. 27..
//  Copyright © 2019 HansolJang. All rights reserved.
//

import UIKit

class EmojiArtDocumentTableViewController: UITableViewController {
    
    var emojiArtDocuments = ["One", "Two", "Three"]

    // MARK: - Table view data source

    // 섹션이 몇갠지 리턴
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // 해당하는 섹션에 로우가 몇갠지 리턴
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emojiArtDocuments.count
    }

    // 위치에 맞는 아이템뷰를 리턴
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath)

        cell.textLabel?.text = emojiArtDocuments[indexPath.row]

        return cell
    }

    @IBAction func newEmojiArt(_ sender: UIBarButtonItem) {
        emojiArtDocuments += ["Untitled".madeUnique(withRespectTo: emojiArtDocuments)]
        tableView.reloadData()
    }
    
    
    /*
    // 행을 수정(삭제)하면 안될 때 사용하는 함수 (디폴트는 삭제 가능 true)
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // MARK: 모델과 뷰의 싱크를 꼭 맞춰야함! 안맞을 경우 런타임에러
            // 모델 삭제
            emojiArtDocuments.remove(at: indexPath.row)
            // 뷰 삭제
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }


    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
