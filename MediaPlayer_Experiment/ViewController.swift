//
//  ViewController.swift
//  MediaPlayer_Experiment
//
//  Created by Gregory Keeley on 1/20/21.
//

import UIKit
import AVFoundation

enum albumTracks: String, CaseIterable {
    case track1 = "Settling_MASTER"
    case track2 = "Windfall_MASTER"
    case track3 = "Letters From the Past_MASTER"
    case track4 = "Sleazy_MASTER"
    case track5 = "Burden of the Crown_MASTER"
    case track6 = "Therefore I Am_MASTER"
    case track7 = "Beat City_MASTER"
    case track8 = "Panic_MASTER"
    case track9 = "So Close to Nothing_MASTER"
    case track10 = "What's to Come_MASTER"
    case track11 = "Zero_MASTER"
    case track12 = "The Key_MASTER"
}

class ViewController: UIViewController {

    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var maxTimeLabel: UILabel!
    
    var allTracks = [String]()
    var currentTrackIndex = 0
    var mp3Player: AVAudioPlayer?
    var currentlyPaused = false
    var pauseTime: TimeInterval?
    
    var currentTrackTime: TimeInterval? {
        didSet {
            updateProgressBarTimeLabels()
        }
    }
    var maxTrackTime: TimeInterval? {
        didSet {
            updateProgressBarTimeLabels()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTracks()
        checkTrackIndex()
        setTrackInfo()
        
    }
    func setTrackInfo() {
        // Cleaning and setting the title
        let suffix = "_MASTER"
        let title = allTracks[currentTrackIndex]
        let cleanTitle = title.replacingOccurrences(of: suffix, with: "")
        songTitleLabel.text = cleanTitle
        
        currentTrackTime = TimeInterval()
        maxTrackTime = TimeInterval()
        // Loading the max duration of the track, and setting the label
        if let duration = mp3Player?.duration, let currentTime = mp3Player?.currentTime {
            maxTrackTime = duration
            currentTrackTime = currentTime
            print("Current Time: \(currentTime)")
            print("Max Time: \(duration)")
        }
        updateProgressBarTimeLabels()
    }
    func loadTracks() {
        for track in albumTracks.allCases {
            allTracks.append(track.rawValue)
        }
        mp3Player?.prepareToPlay()
    }
    
    func updateProgressBarTimeLabels() {
        guard let maxTime = maxTrackTime, let currentTime = currentTrackTime else { return }
        
        let currentTimePercent = ((currentTime / maxTime) * 100)
        print(currentTimePercent.rounded())
        
        progressBar.progress = Float(currentTimePercent).rounded()
        
        currentTimeLabel.text = convertTimeIntervalToText(ti: currentTime)
        maxTimeLabel.text = convertTimeIntervalToText(ti: maxTime)
    }
    func convertTimeIntervalToText(ti: TimeInterval) -> String {
        let seconds = Int(ti) % 60
        let minutes = (Int(ti) / 60) % 60
        return String("\(minutes):\(seconds)")
    }
    func checkTrackIndex() {
        if currentTrackIndex == 0 {
            backwardButton.isEnabled = false
        } else {
            backwardButton.isEnabled = true
        }
        if currentTrackIndex == allTracks.count - 1 {
            forwardButton.isEnabled = false
        } else {
            forwardButton.isEnabled = true
        }
    }
    func changeTrack(_ sender: UIButton) {
        // Guard against going out of bounds for the total track count
        guard currentTrackIndex >= 0 && currentTrackIndex <= allTracks.count else {
            // Check the index to enable/disable buttons
            checkTrackIndex()
            return }
        
        // Check which button was pressed
        if sender == backwardButton {
        currentTrackIndex -= 1
        } else if sender == forwardButton {
            currentTrackIndex += 1
        }
        // Change title for track, and enable/disable buttons depending on the position in the album
        setTrackInfo()
        checkTrackIndex()
    }
    func playTrack() {
        if currentTrackIndex >= 0 && currentTrackIndex <= allTracks.count {
            playPauseButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)
            let currentTrack = ("\(allTracks[currentTrackIndex])")
            let path = Bundle.main.path(forResource: currentTrack, ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            do {
                mp3Player = try AVAudioPlayer(contentsOf: url)
                mp3Player?.play()
            } catch {
                print("mp3 player failed")
            }
        }
    }
    @IBAction func changeTrackButtonPressed(_ sender: UIButton) {
        changeTrack(sender)
        currentlyPaused = false
        if mp3Player?.isPlaying ?? true {
            mp3Player?.stop()
            playTrack()
        }
    }
    
    // Checks if the mp3Player is playing
    /// - Not playing: Pause
    /// TODO:
    /// - Playing: Plays
    @IBAction func playTrackButtonPressed() {
        if !(mp3Player?.isPlaying ?? false) {
            if currentlyPaused {
                currentlyPaused = false
                mp3Player?.play()
            } else {
                playTrack()
            }
            playPauseButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)
        } else if mp3Player?.isPlaying ?? true {
            playPauseButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
            currentlyPaused = true
            pauseTime = mp3Player?.currentTime
            mp3Player?.pause()
        }
    }
}

