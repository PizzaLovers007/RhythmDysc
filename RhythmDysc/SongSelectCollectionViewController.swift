//
//  SongSelectCollectionViewController.swift
//  RhythmDysc
//
//  Created by MUser on 7/3/15.
//  Copyright (c) 2015 TynyLabs. All rights reserved.
//

import UIKit;
import AVFoundation;

class SongSelectCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UIScrollViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!;
    @IBOutlet weak var collectionView: UICollectionView!;
    
    var songSelections: [SongSelection] = [SongSelection]();
    var searchSelections: [SongSelection] = [SongSelection]();
    var selectedIndex: Int = Int.max;
    var musicPlayer: AVAudioPlayer!;
    var isSearchOn: Bool = false;
    var translucentOverlay: UIView!;
    var prevScrollOffset: CGFloat = 0;
    let coverImageMask = CAShapeLayer();
    
    override func viewDidLoad() {
        super.viewDidLoad();

        // Do any additional setup after loading the view.
        songSelections.append(SongSelection(title: "aLIEz", artist: "SawanoHiroyuki[nZk]:mizuki", maxBPM: 99, preview: 60871));
        songSelections.append(SongSelection(title: "aLIEz", artist: "SawanoHiroyuki[nZk]:mizuki", maxBPM: 99, preview: 60871));
        songSelections.append(SongSelection(title: "Mushikui-Saikede-Rhythm", artist: "Someone lol", maxBPM: 99, preview: 55350));
        songSelections.append(SongSelection(title: "aLIEz", artist: "SawanoHiroyuki[nZk]:mizuki", maxBPM: 99, preview: 60871));
        songSelections.append(SongSelection(title: "aLIEz", artist: "SawanoHiroyuki[nZk]:mizuki", maxBPM: 99, preview: 60871));
        songSelections.append(SongSelection(title: "Mushikui-Saikede-Rhythm", artist: "Someone lol", maxBPM: 99, preview: 55350));
        songSelections.append(SongSelection(title: "aLIEz", artist: "SawanoHiroyuki[nZk]:mizuki", maxBPM: 99, preview: 60871));
        songSelections.append(SongSelection(title: "aLIEz", artist: "SawanoHiroyuki[nZk]:mizuki", maxBPM: 99, preview: 60871));
        songSelections.append(SongSelection(title: "Mushikui-Saikede-Rhythm", artist: "Someone lol", maxBPM: 99, preview: 55350));
        songSelections.append(SongSelection(title: "aLIEz", artist: "SawanoHiroyuki[nZk]:mizuki", maxBPM: 99, preview: 60871));
        songSelections.append(SongSelection(title: "aLIEz", artist: "SawanoHiroyuki[nZk]:mizuki", maxBPM: 99, preview: 60871));
        songSelections.append(SongSelection(title: "Mushikui-Saikede-Rhythm", artist: "Someone lol", maxBPM: 99, preview: 55350));
        songSelections.append(SongSelection(title: "aLIEz", artist: "SawanoHiroyuki[nZk]:mizuki", maxBPM: 99, preview: 60871));
        songSelections.append(SongSelection(title: "aLIEz", artist: "SawanoHiroyuki[nZk]:mizuki", maxBPM: 99, preview: 60871));
        songSelections.append(SongSelection(title: "Mushikui-Saikede-Rhythm", artist: "Someone lol", maxBPM: 99, preview: 55350));
        
        let tapRecognizer = UITapGestureRecognizer();
        tapRecognizer.numberOfTapsRequired = 1;
        tapRecognizer.addTarget(self, action: "overlayTapped");
//        collectionView.addGestureRecognizer(tapRecognizer);
        
        translucentOverlay = UIView(frame: collectionView.frame);
        translucentOverlay.backgroundColor = UIColor.blackColor();
        translucentOverlay.alpha = 0.6;
        translucentOverlay.addGestureRecognizer(tapRecognizer);
        
        let swipeDownRecognizer = UISwipeGestureRecognizer();
        swipeDownRecognizer.direction = UISwipeGestureRecognizerDirection.Down;
        swipeDownRecognizer.addTarget(self, action: "showMenuBars");
        let swipeUpRecognizer = UISwipeGestureRecognizer();
        swipeUpRecognizer.direction = UISwipeGestureRecognizerDirection.Up;
        swipeUpRecognizer.addTarget(self, action: "hideMenuBars");
        
        collectionView.addGestureRecognizer(swipeDownRecognizer);
        collectionView.addGestureRecognizer(swipeUpRecognizer);
        
        loadAudioPlayer(nil);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (isSearchOn) ? searchSelections.count : songSelections.count;
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("songSelection", forIndexPath: indexPath) as! SongSelectionCollectionCell;
        
        // Configure the cell
        let currSelection: SongSelection;
        if (isSearchOn) {
            currSelection = searchSelections[indexPath.item];
        } else {
            currSelection = songSelections[indexPath.item];
        }
        cell.titleLabel?.text = currSelection.title;
        cell.artistLabel?.text = currSelection.artist;
        cell.coverImageView?.image = UIImage(named: currSelection.title);
        
        return cell;
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! SongSelectionCollectionCell;
        cell.backgroundColor = UIColor.grayColor();
        if (selectedIndex == indexPath.item) {
            NSLog("Selected song \(songSelections[selectedIndex].title)!");
        } else {
            selectedIndex = indexPath.item;
            if (isSearchOn) {
                loadAudioPlayer(searchSelections[indexPath.item]);
            } else {
                loadAudioPlayer(songSelections[indexPath.item]);
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? SongSelectionCollectionCell {
            cell.backgroundColor = UIColor.clearColor();
        }
        loadAudioPlayer(nil);
//        fadeVolumeOut();
    }

    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor();
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if (selectedIndex == indexPath.item) {
            cell.backgroundColor = UIColor.grayColor();
        }
    }
    
    // MARK: UICollectionViewDelegate

    // Uncomment this method to specify if the specified item should be highlighted during tracking
//    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return true;
//    }

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true;
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false;
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false;
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let selectionWidth = self.view.frame.size.width * 2 / 5;
        let selectionHeight = CGFloat(200);
        return CGSizeMake(selectionWidth, selectionHeight);
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let leftRightInset = self.view.frame.size.width / 15;
        return UIEdgeInsetsMake(0, leftRightInset, 0, leftRightInset);
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        isSearchOn = true;
        view.addSubview(translucentOverlay);
        collectionView.userInteractionEnabled = false;
        searchBar.setShowsCancelButton(true, animated: true);
        if (selectedIndex != Int.max) {
            loadAudioPlayer(nil);
        }
        selectedIndex = Int.max;
        filterContentForSearchText();
        collectionView.reloadData();
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        translucentOverlay.removeFromSuperview();
        collectionView.userInteractionEnabled = true;
        searchBar.setShowsCancelButton(false, animated: true);
        collectionView.reloadData();
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        isSearchOn = false;
        searchBar.resignFirstResponder();
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText();
        collectionView.reloadData();
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder();
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y > prevScrollOffset && scrollView.contentOffset.y > 0) {
            hideMenuBars();
        } else if (scrollView.contentOffset.y < prevScrollOffset) {
            showMenuBars();
        }
        prevScrollOffset = scrollView.contentOffset.y;
    }
    
    // MARK: Helper functions
    
    func overlayTapped() {
        searchBar.setShowsCancelButton(false, animated: true);
        isSearchOn = (searchBar.text == nil);
        searchBar.resignFirstResponder();
    }
    
    func showMenuBars() {
        searchBar.hidden = false;
        UIView.animateWithDuration(0.5, animations: {
            self.searchBar.alpha = 1;
        });
    }
    
    func hideMenuBars() {
        UIView.animateWithDuration(0.5, animations: {
            self.searchBar.alpha = 0;
            }, completion: { finished in
                self.searchBar.hidden = true;
        });
    }
    
    private func filterContentForSearchText() {
        searchSelections.removeAll(keepCapacity: false);
        if (searchBar.text != nil) {
            let searchString = searchBar.text.lowercaseString;
            for song in songSelections {
                let titleRange = song.title.lowercaseString.rangeOfString(searchString);
                let artistRange = song.artist.lowercaseString.rangeOfString(searchString);
                if (titleRange != nil || artistRange != nil) {
                    searchSelections.append(song);
                }
            }
        }
    }
    
    private func loadAudioPlayer(selection: SongSelection!) {
//        delay(0.3) {
//            let songURL = NSBundle.mainBundle().URLForResource(selection.title, withExtension: "mp3")!;
//            self.musicPlayer = AVAudioPlayer(contentsOfURL: songURL, error: nil);
//            self.musicPlayer.prepareToPlay();
//            self.musicPlayer.delegate = self;
//            self.musicPlayer.currentTime = Double(selection.preview)/1000;
//            self.musicPlayer.volume = 0;
//            self.fadeVolumeIn();
//            self.musicPlayer.play();
//        }
        if (selection != nil) {
            let songURL = NSBundle.mainBundle().URLForResource(selection.title, withExtension: "mp3")!;
            musicPlayer = AVAudioPlayer(contentsOfURL: songURL, error: nil);
            musicPlayer.prepareToPlay();
            musicPlayer.delegate = self;
            musicPlayer.currentTime = Double(selection.preview)/1000;
            musicPlayer.play();
        } else {
            let songURL = NSBundle.mainBundle().URLForResource("SongSelect", withExtension: "mp3")!;
            musicPlayer = AVAudioPlayer(contentsOfURL: songURL, error: nil);
            musicPlayer.prepareToPlay();
            musicPlayer.delegate = self;
            musicPlayer.play();
        }
    }
    
    private func fadeVolumeIn(){
        if (musicPlayer.volume < 1) {
            musicPlayer.volume += 0.1;
            
            delay(0.01) {
                self.fadeVolumeIn();
            }
        } else {
            musicPlayer.volume = 1;
        }
    }
    
    private func fadeVolumeOut() {
        if (musicPlayer.volume > 0.1) {
            musicPlayer.volume -= 0.1;
            
            delay(0.01) {
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

extension SongSelectCollectionViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        player.pause();
        if (selectedIndex != Int.max) {
            player.currentTime = Double(songSelections[selectedIndex].preview)/1000;
        } else {
            player.currentTime = 0;
        }
//        player.volume = 0;
//        fadeVolumeIn();
        player.play();
    }
    
    func audioPlayerBeginInterruption(player: AVAudioPlayer!) {
        player.pause();
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer!) {
        player.play();
    }
}
