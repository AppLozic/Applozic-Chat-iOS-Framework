//
//  SoundRecordingView.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation

@objc public protocol ALSoundRecorderProtocol {
    func finishRecordingAudio(fileUrl: NSString)
    func startRecordingAudio()
    func cancelRecordingAudio()
    func permissionNotGrant()
}

@objc public class ALSoundRecorderButton: UIButton {

    private var isTimerStart:Bool = false
    private var timer = Timer()
    private var counter = 0
    public var delegate:ALSoundRecorderProtocol!

    //aduio session
    private var recordingSession: AVAudioSession!
    private var audioRecorder: AVAudioRecorder!
    fileprivate var audioFilename:URL!
    private var audioPlayer: AVAudioPlayer?

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    public init(frame: CGRect,recorderDelegate:ALSoundRecorderProtocol) {
        super.init(frame: frame)
        delegate = recorderDelegate
    }

    @objc public func show() {
        if recordingSession == nil {
            setupRecordingSession()
            self.isHidden = false
        } else {
            self.isHidden = false
        }
    }

    @objc public func hide() {
        if recordingSession == nil {
            setupRecordingSession()
            self.isHidden = true
        } else {
            self.isHidden = true
        }
    }


    @objc public func setSoundRecDelegate(recorderDelegate:ALSoundRecorderProtocol) {
        delegate = recorderDelegate
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Create UI
    private func createUI()
    {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTapAudioRecord))
        tapGesture.numberOfTapsRequired = 1
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(startAudioRecordGesture(sender:)))

        addGestureRecognizer(tapGesture)
        addGestureRecognizer(longGesture)

        layer.cornerRadius = 12
        displayDefaultText()
    }

    private func displayDefaultText() {
        isTimerStart = false
        backgroundColor = UIColor.gray
        let holdToTalkMessage = NSLocalizedString("holdToTalkMessage", value: "Hold to Talk / Tap to Type", comment: "")
        setTitle(holdToTalkMessage, for: .normal)
        setTitle(holdToTalkMessage, for: .highlighted)
    }

    private func displayDefaultRecordingText() {
        backgroundColor = UIColor.red
        let swipeUpToCancelMessage = NSLocalizedString("swipeUpToCancel", value: "Swipe up to cancel",comment: "")
        let recordingMessage = NSLocalizedString("initialRecordingMessage", value: "00:00:00)", comment: "")
        setTitle("\(recordingMessage)   \(swipeUpToCancelMessage)", for: .normal)
        setTitle("\(recordingMessage)   \(swipeUpToCancelMessage)", for: .highlighted)
    }

    private func setupRecordingSession()
    {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.overrideOutputAudioPort(.speaker)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() {[weak self] allowed in
                DispatchQueue.main.async {
                    guard let weakSelf = self else {return}
                    if allowed {
                        weakSelf.createUI()
                    } else {
                        weakSelf.removeFromSuperview()
                    }
                }
            }
        } catch {
            self.removeFromSuperview()
        }
    }

    //MARK: - Function
    private func checkMicrophonePermission() -> Bool {

        let soundSession = AVAudioSession.sharedInstance()
        let permissionStatus = soundSession.recordPermission()
        var isAllow = false

        switch (permissionStatus) {
        case AVAudioSessionRecordPermission.undetermined:
            soundSession.requestRecordPermission({ (isGrant) in
                if (isGrant) {
                    isAllow = true
                }
                else {
                    isAllow = false
                }
            })
            break
        case AVAudioSessionRecordPermission.denied:
            // direct to settings...
            isAllow = false
            break;
        case AVAudioSessionRecordPermission.granted:
            // mic access ok...
            isAllow = true
            break;
        default:
            break;
        }

        return isAllow
    }

    @objc func startAudioRecordGesture(sender : UIGestureRecognizer){
        let point = sender.location(in: self)
        let width = self.frame.size.width
        let height = self.frame.size.height

        if sender.state == .ended {
            stopAudioRecord()
        }
        else if sender.state == .changed {

            if point.x < 0 || point.x > width || point.y < 0 || point.y > height {
                cancelAudioRecord()
            }
        }
        else if sender.state == .began {

            if delegate != nil {
                delegate.startRecordingAudio()
            }

            if checkMicrophonePermission() == false {
                if delegate != nil {
                    delegate.permissionNotGrant()
                }
            } else {

                if point.x > 0 || point.x < width || point.y > 0 || point.y < height {
                    startAudioRecord()
                }
            }

        }
    }

    @objc fileprivate func startAudioRecord()
    {
        isTimerStart = true
        counter = 0
        displayDefaultRecordingText()

        timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(ALSoundRecorderButton.updateCounter), userInfo: nil, repeats: true)

//        audioFilename = URL(fileURLWithPath: NSTemporaryDirectory().appending("tempRecording.m4a"))
        let fileName = String(format: "AUD-%f.m4a", Date().timeIntervalSince1970*1000)
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        audioFilename = documentsURL.appendingPathComponent(fileName)

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.overrideOutputAudioPort(.speaker)
            try recordingSession.setActive(true)
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()

        } catch {
            stopAudioRecord()
        }
    }

    @objc fileprivate func singleTapAudioRecord() {
        cancelAudioRecord()
        if delegate != nil {
            delegate.cancelRecordingAudio()
        }

    }

    @objc func cancelAudioRecord() {
        if isTimerStart == true
        {
            isTimerStart = false
            timer.invalidate()

            audioRecorder.stop()
            audioRecorder = nil

            displayDefaultText()
        }
    }

    @objc fileprivate func stopAudioRecord()
    {
        if isTimerStart == true
        {
            isTimerStart = false
            timer.invalidate()
            displayDefaultText()

            audioRecorder.stop()
            audioRecorder = nil

            //play back?

            if audioFilename.isFileURL
            {
                // Cancel audio if fileName is not present or, if the duration is zero secs
                guard audioFilename != nil, counter != 0, counter % 60 > 0  else {
                    delegate.cancelRecordingAudio()
                    return
                }
                delegate.finishRecordingAudio(fileUrl: audioFilename.path as NSString)
            }
        }
    }

    private func playSound(url:URL) {

        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayback)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            guard let player = audioPlayer else { return }

            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } catch let error {
            NSLog("Error playing audio: \(error.localizedDescription)")
        }
    }

    @objc fileprivate func updateCounter() {
        counter += 1

        //min
        let min = (counter / 60) % 60
        let sec = (counter % 60)
        var minStr = String(min)
        var secStr = String(sec)
        if sec < 10 {secStr = "0\(secStr)"}
        if min < 10 {minStr = "0\(minStr)"}
        let recordingMessage = NSLocalizedString("recordingMessage", value: "00:", comment: "")
        let swipeUpToCancelMessage = NSLocalizedString("swipeUpToCancel", value: "Swipe up to cancel",comment: "")
        setTitle("\(recordingMessage)\(minStr):\(secStr)   \(swipeUpToCancelMessage)", for: .normal)
        setTitle("\(recordingMessage)\(minStr):\(secStr)   \(swipeUpToCancelMessage)", for: .highlighted)
    }
}

extension ALSoundRecorderButton: AVAudioRecorderDelegate
{
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            stopAudioRecord()
        }
    }
}

