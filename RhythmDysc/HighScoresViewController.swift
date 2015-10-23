//
//  HighScoresViewController.swift
//  RhythmDysc
//
//  Created by MUser on 8/1/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;
import CoreData;

class HighScoresViewController: UITableViewController {

    var songSelection: SongSelection!;
    var scores: [SongScore] = [SongScore]();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        navigationItem.title = "\(songSelection.title) High Scores";
        
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        let context: NSManagedObjectContext = appDel.managedObjectContext!;
        
        let request = NSFetchRequest(entityName: "Scores");
        request.returnsObjectsAsFaults = false;
        request.predicate = NSPredicate(format: "songTitle = %@", songSelection.title);
        
        do {
            let list = try context.executeFetchRequest(request);
            for item in list {
                scores.append(item as! SongScore);
            }
        } catch {
            print(error);
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 3;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 4;
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 86;
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("highScoreCell", forIndexPath: indexPath) as! HighScoreCell;

        switch (indexPath.row) {
        case 0:     cell.difficultyLabel.text = "Easy";
        case 1:     cell.difficultyLabel.text = "Normal";
        case 2:     cell.difficultyLabel.text = "Hard";
        case 3:     cell.difficultyLabel.text = "Expert";
        default:    cell.difficultyLabel.text = "None";
        }
        
        for score in scores {
            if (score.sectors.integerValue == Int(pow(2, Double(indexPath.section+1))) && score.difficulty.integerValue == indexPath.row) {
                cell.gradeLabel.text = score.grade;
                cell.scoreLabel.text = String(format: "%08d", score.score.integerValue);
                cell.accuracyLabel.text = String(format: "%.2f%%", score.accuracy.doubleValue);
                cell.maxComboLabel.text = "Max Combo: \(score.maxCombo.integerValue)";
                cell.difficultyLabel.textColor = UIColor.darkTextColor();
                cell.gradeLabel.textColor = UIColor.darkTextColor();
                cell.scoreLabel.textColor = UIColor.darkTextColor();
                cell.accuracyLabel.textColor = UIColor.darkTextColor();
                cell.maxComboLabel.textColor = UIColor.darkTextColor();
                return cell;
            }
        }
        cell.gradeLabel.text = "";
        cell.scoreLabel.text = "";
        cell.accuracyLabel.text = "No Score Yet";
        cell.maxComboLabel.text = "";
        
        cell.difficultyLabel.textColor = UIColor.lightGrayColor();
        cell.gradeLabel.textColor = UIColor.lightGrayColor();
        cell.scoreLabel.textColor = UIColor.lightGrayColor();
        cell.accuracyLabel.textColor = UIColor.lightGrayColor();
        cell.maxComboLabel.textColor = UIColor.lightGrayColor();
        
        return cell;
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(Int(pow(2, Double(section)+1))) Sectors";
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
