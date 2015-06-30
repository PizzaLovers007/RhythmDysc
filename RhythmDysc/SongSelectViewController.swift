//
//  SongSelectViewController.swift
//  RhythmDysc
//
//  Created by MUser on 6/29/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;
import AVFoundation;

struct SongSelection {
    let title: String;
    let artist: String;
    let maxBPM: Double;
    let preview: Int;
}

class SongSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!;
    
    var musicPlayer: AVAudioPlayer! = AVAudioPlayer();
    var songSelections: [SongSelection] = [SongSelection]();
    var selectedIndex: Int = Int.max;
    
    override func viewDidLoad() {
        super.viewDidLoad();

        tableView.delegate = self;
        tableView.dataSource = self;
        
        let songDetailNib = UINib(nibName: "SongDetailCell", bundle: nil);
        tableView.registerNib(songDetailNib, forCellReuseIdentifier: "songDetailCell");
        let songSelectionNib = UINib(nibName: "SongSelectionCell", bundle: nil);
        tableView.registerNib(songSelectionNib, forCellReuseIdentifier: "songSelectionCell");
        
        songSelections.append(SongSelection(title: "aLIEz", artist: "SawanoHiroyuki[nZk]:mizuki", maxBPM: 99, preview: 60871));
        songSelections.append(SongSelection(title: "aLIEz", artist: "SawanoHiroyuki[nZk]:mizuki", maxBPM: 99, preview: 60871));
        songSelections.append(SongSelection(title: "aLIEz", artist: "SawanoHiroyuki[nZk]:mizuki", maxBPM: 99, preview: 60871));
        songSelections.append(SongSelection(title: "Mushikui-Saikede-Rhythm", artist: "Someone lol", maxBPM: 99, preview: 55310));
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songSelections.count;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (selectedIndex == indexPath.row) {
            return 384;
        } else {
            return 100;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (selectedIndex != Int.max && selectedIndex == indexPath.row) {
            let cell = tableView.dequeueReusableCellWithIdentifier("songDetailCell") as! SongDetailCell;
            cell.titleLabel.text = songSelections[selectedIndex].title;
            cell.artistLabel.text = songSelections[selectedIndex].artist;
            cell.maxBPMLabel.text = "Max BPM: \(Int(round(songSelections[selectedIndex].maxBPM)))";
            cell.coverImageView.image = UIImage(named: songSelections[selectedIndex].title);
            cell.clipsToBounds = true;
            return cell;
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("songSelectionCell") as! SongSelectionCell;
            cell.titleLabel.text = songSelections[indexPath.row].title;
            cell.artistLabel.text = songSelections[indexPath.row].artist;
            cell.coverImageView.image = UIImage(named: songSelections[indexPath.row].title);
            cell.clipsToBounds = true;
            return cell;
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (selectedIndex == Int.max) {
            selectedIndex = indexPath.row;
            loadAudioPlayer();
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Middle);
        } else if (selectedIndex == indexPath.row) {
            selectedIndex = Int.max;
            musicPlayer.pause();
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Middle);
        } else {
            let prevPath = NSIndexPath(forRow: selectedIndex, inSection: 0);
            selectedIndex = indexPath.row;
            loadAudioPlayer();
            tableView.reloadRowsAtIndexPaths([prevPath], withRowAnimation: UITableViewRowAnimation.Middle);
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Middle);
        }
    }
    
    private func loadAudioPlayer() {
        let songURL = NSBundle.mainBundle().URLForResource(songSelections[selectedIndex].title, withExtension: "mp3")!;
        musicPlayer = AVAudioPlayer(contentsOfURL: songURL, error: nil);
        musicPlayer.prepareToPlay();
        musicPlayer.delegate = self;
        musicPlayer.currentTime = Double(songSelections[selectedIndex].preview)/1000;
        musicPlayer.volume = 0;
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.fadeVolumeIn();
            self.musicPlayer.play();
        })
    }
    
    private func fadeVolumeIn(){
        if (musicPlayer.volume < 1) {
            musicPlayer.volume += 0.1;
            
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.05 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self.fadeVolumeIn();
            })
        } else {
            musicPlayer.volume = 1;
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SongSelectViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        player.pause();
        player.currentTime = Double(songSelections[selectedIndex].preview)/1000;
        player.volume = 0;
        fadeVolumeIn();
        player.play();
    }
}
