//
//  SongSelectViewController.swift
//  RhythmDysc
//
//  Created by MUser on 6/29/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;
import SpriteKit;
import AVFoundation;

struct SongSelection {
    let title: String;
    let artist: String;
    let maxBPM: Double;
    let preview: Int;
}

class SongSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!;
    
    var songSelections: [SongSelection] = [SongSelection]();
    var selectedIndex: Int = Int.max;
    var musicPlayer: AVAudioPlayer!;
    
    override func viewDidLoad() {
        super.viewDidLoad();

        NSLog("Entered Song Select View");
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        songSelections.append(SongSelection(title: "aLIEz", artist: "SawanoHiroyuki[nZk]:mizuki", maxBPM: 99, preview: 60871));
        songSelections.append(SongSelection(title: "Mushikui-Saikede-Rhythm", artist: "Someone lol", maxBPM: 210, preview: 55554));
        songSelections.append(SongSelection(title: "Midnight Sky", artist: "Katie Park", maxBPM: 120, preview: 39970));
        songSelections.append(SongSelection(title: "Test", artist: "testststests", maxBPM: 100, preview: 1753));
        
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
            return 444;
        } else {
            return 87;
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
            loadAudioPlayer(songSelections[selectedIndex]);
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Middle);
        } else if (selectedIndex == indexPath.row) {
            selectedIndex = Int.max;
            fadeVolumeOut();
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Middle);
        } else {
            let prevPath = NSIndexPath(forRow: selectedIndex, inSection: 0);
            selectedIndex = indexPath.row;
            fadeVolumeOut();
            loadAudioPlayer(songSelections[selectedIndex]);
            tableView.reloadRowsAtIndexPaths([prevPath], withRowAnimation: UITableViewRowAnimation.Middle);
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Middle);
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let navigationController = segue.destinationViewController as? UINavigationController, let destinationVC = navigationController.viewControllers[0] as? HighScoresViewController {
            destinationVC.songSelection = songSelections[selectedIndex];
        } else {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: selectedIndex, inSection: 0)) as! SongDetailCell;
            let difficulty = cell.difficultySelection.titleForSegmentAtIndex(cell.difficultySelection.selectedSegmentIndex)!.lowercaseString;
            let sector = Int(pow(2, Double(cell.sectorSelection.selectedSegmentIndex+1)));
            let mapName = "\(cell.titleLabel.text!)-\(difficulty)-\(sector)";
            if let mapURL = NSBundle.mainBundle().URLForResource(mapName, withExtension: "dmp") {
                let mapData = MapReader.readFile(mapURL);
                let destViewController = segue.destinationViewController as? GameViewController;
                destViewController?.mapData = mapData;
                
                NSLog("Loading map \(mapName).dmp");
            } else {
                NSLog("Unable to find map \(mapName).dmp!");
            }
        }
        fadeVolumeOut();
    }
    
    @IBAction func backToSongSelect(segue: UIStoryboardSegue) {
        if (selectedIndex != Int.max) {
            loadAudioPlayer(songSelections[selectedIndex]);
        }
    }
    
    private func loadAudioPlayer(selection: SongSelection) {
        delay(0.3) {
            let songURL = NSBundle.mainBundle().URLForResource(selection.title, withExtension: "mp3")!;
            self.musicPlayer = AVAudioPlayer(contentsOfURL: songURL, error: nil);
            self.musicPlayer.prepareToPlay();
            self.musicPlayer.delegate = self;
            self.musicPlayer.currentTime = Double(selection.preview)/1000;
            self.musicPlayer.volume = 0;
            self.fadeVolumeIn();
            self.musicPlayer.play();
        }
    }
    
    private func fadeVolumeIn(){
        if (musicPlayer.volume < 1) {
            musicPlayer.volume += 0.1;
            
            delay(0.05) {
                self.fadeVolumeIn();
            }
        } else {
            musicPlayer.volume = 1;
        }
    }
    
    private func fadeVolumeOut() {
        if (musicPlayer.volume > 0.1) {
            musicPlayer.volume -= 0.1;
            
            delay(0.02) {
                self.fadeVolumeOut();
            }
        } else {
            musicPlayer.volume = 0;
            musicPlayer.pause();
        }
    }


    private func delay(delay: Double, closure:() -> ()) {
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), closure);
    }
}

extension SongSelectViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        player.pause();
        player.currentTime = Double(songSelections[selectedIndex].preview)/1000;
        player.volume = 0;
        fadeVolumeIn();
        player.play();
    }
    
    func audioPlayerBeginInterruption(player: AVAudioPlayer!) {
        player.pause();
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer!) {
        player.play();
    }
}
