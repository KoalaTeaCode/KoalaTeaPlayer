//
//  YTSlider.swift
//  KoalaTeaPlayer
//
//  Created by Craig Holliday on 12/4/17.
//

import Foundation

protocol AssetPlayerSliderViewDelegate {
    func playbackSliderValueChanged(value: Float)
}

protocol AssetPlayerSliderViewProtocol {
    var delegate: AssetPlayerSliderViewDelegate? { get }
    var bufferSlider: UISlider { get }
    var bufferBackgroundSlider: UISlider { get }
    var playbackSlider: UISlider { get }
    var bufferSliderColor: UIColor { get }
    var bufferBackgroundColor: UIColor { get }
    var playbackSliderColor: UIColor { get }
    var sliderCircleColor: UIColor { get }
    var currentTimeLabel: UILabel { get }
    var timeLeftLabel: UILabel { get }
    var previousSliderValue: Float { get }
    var isFirstLoad: Bool { get }
    var smallCircle: UIImage? { get }
    var bigCircle: UIImage? { get }
    var trackHeight: CGFloat { get }
    
    func addPlaybackSlider()
    func addBufferSlider()
    func addLabels()
    func playbackSliderValueChanged(_ slider: UISlider)
    func updateSlider(maxValue: Float)
    func updateSlider(currentValue: Float)
    func updateTimeLabels(currentTimeText: String, timeLeftText: String)
    func showLabels()
    func hideLabels()
    func showSliders()
    func hideSliders()
    func showSliderThumbImage()
    func hideSliderThumbImage()
    func setDefaultConstraints()
    func setRotatedConstraints()
}

class AssetPlayerSliderView: PassThroughView, AssetPlayerSliderViewProtocol {
    var delegate: AssetPlayerSliderViewDelegate?
    
    var bufferSlider: UISlider = UISlider(frame: .zero)

    var bufferBackgroundSlider: UISlider = UISlider(frame: .zero)
    
    var playbackSlider: UISlider = UISlider(frame: .zero)
    
    var bufferSliderColor: UIColor = UIColor(hex: 0xb6b8b9)!
    
    var bufferBackgroundColor: UIColor = UIColor(hex: 0xb6b8b9)!
    
    var playbackSliderColor: UIColor = .red
    
    var sliderCircleColor: UIColor = .white
    
    var currentTimeLabel: UILabel = UILabel(frame: .zero)
    
    var timeLeftLabel: UILabel = UILabel(frame: .zero)
    
    var previousSliderValue: Float = 0.0
    
    var isFirstLoad: Bool = false
    
    var smallCircle: UIImage? {
        get {
            guard let image = UIImage(named: "SmallCircle", in: nil, compatibleWith: nil) else { return nil }
            return image.filled(withColor: self.sliderCircleColor)
        }
    }
    var bigCircle: UIImage? {
        get {
            guard let image = UIImage(named: "BigCircle", in: nil, compatibleWith: nil) else { return nil }
            return image.filled(withColor: self.sliderCircleColor)
        }
    }
    
    var trackHeight: CGFloat = UIView.getValueScaledByScreenHeightFor(baseValue: 2)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addPlaybackSlider()
        addBufferSlider()
        addLabels()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addBufferSlider() {
        // Background Buffer Slider
        bufferBackgroundSlider.minimumValue = 0
        bufferBackgroundSlider.isContinuous = true
        bufferBackgroundSlider.tintColor = self.bufferBackgroundColor
        bufferBackgroundSlider.layer.cornerRadius = 0
        bufferBackgroundSlider.alpha = 0.5
        bufferBackgroundSlider.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
        bufferBackgroundSlider.isUserInteractionEnabled = false
        
        self.addSubview(bufferBackgroundSlider)
        
        bufferBackgroundSlider.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(playbackSlider)
        }
        
        bufferBackgroundSlider.setThumbImage(UIImage(), for: .normal)
        
        bufferSlider.minimumValue = 0
        bufferSlider.isContinuous = true
        bufferSlider.minimumTrackTintColor = self.bufferSliderColor
        bufferSlider.maximumTrackTintColor = .clear
        bufferSlider.layer.cornerRadius = 0
        bufferSlider.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
        bufferSlider.isUserInteractionEnabled = false
        
        self.addSubview(bufferSlider)
        
        bufferSlider.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(playbackSlider)
        }
        
        bufferSlider.setThumbImage(UIImage(), for: .normal)
        
        self.sendSubview(toBack: bufferSlider)
        self.sendSubview(toBack: bufferBackgroundSlider)
    }

    func addPlaybackSlider() {
        playbackSlider.minimumValue = 0
        playbackSlider.isContinuous = true
        playbackSlider.minimumTrackTintColor = .white
        playbackSlider.maximumTrackTintColor = .clear
        playbackSlider.layer.cornerRadius = 0
        playbackSlider.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
        playbackSlider.isUserInteractionEnabled = false
        
        self.addSubview(playbackSlider)
        self.bringSubview(toFront: playbackSlider)
        
        playbackSlider.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().inset(-10)
            make.height.equalTo(UIView.getValueScaledByScreenHeightFor(baseValue: 20))
            make.left.right.equalToSuperview()
        }
        
        playbackSlider.setThumbImage(smallCircle, for: .normal)
        playbackSlider.setThumbImage(bigCircle, for: .highlighted)
    }
    
    func addLabels() {
        let labelFontSize = UIView.getValueScaledByScreenWidthFor(baseValue: 12)
        currentTimeLabel.text = "00:00"
        currentTimeLabel.textAlignment = .left
        currentTimeLabel.font = UIFont.systemFont(ofSize: labelFontSize)
        currentTimeLabel.textColor = .white
        
        timeLeftLabel.text = "00:00"
        timeLeftLabel.textAlignment = .right
        timeLeftLabel.adjustsFontSizeToFitWidth = true
        timeLeftLabel.font = UIFont.systemFont(ofSize: labelFontSize)
        timeLeftLabel.textColor = .white
        
        self.addSubview(currentTimeLabel)
        self.addSubview(timeLeftLabel)
        
        currentTimeLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(playbackSlider).inset(UIView.getValueScaledByScreenWidthFor(baseValue: 5))
            make.top.equalTo(playbackSlider.snp.bottom).inset(UIView.getValueScaledByScreenHeightFor(baseValue: 5))
            make.height.equalTo(UIView.getValueScaledByScreenHeightFor(baseValue: 20))
            make.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 55))
        }
        
        timeLeftLabel.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(playbackSlider).inset(UIView.getValueScaledByScreenWidthFor(baseValue: 5))
            make.top.equalTo(playbackSlider.snp.bottom).inset(UIView.getValueScaledByScreenHeightFor(baseValue: 5))
            make.height.equalTo(UIView.getValueScaledByScreenHeightFor(baseValue: 20))
            make.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 55))
        }
    }
    
    @objc func playbackSliderValueChanged(_ slider: UISlider) {
        let timeInSeconds = slider.value
        
        if (playbackSlider.isTracking) && (timeInSeconds != previousSliderValue) {
            // Update Labels
            // Do this without using functions because this views controller use the functions and they have a !isTracking guard
            //@TODO: Figure out how to fix not being able to use functions
            //            self.updateSlider(currentValue: timeInSeconds)
            playbackSlider.value = timeInSeconds
            let duration = playbackSlider.maximumValue
            let timeLeft = Float(duration - timeInSeconds)
            
            let currentTimeString = Helpers.createTimeString(time: timeInSeconds)
            let timeLeftString = Helpers.createTimeString(time: timeLeft)
            //            self.updateTimeLabels(currentTimeText: currentTimeString, timeLeftText: timeLeftString)
            self.currentTimeLabel.text = currentTimeString
            self.timeLeftLabel.text = timeLeftString
        } else {
            self.delegate?.playbackSliderValueChanged(value: timeInSeconds)
            let duration = playbackSlider.maximumValue
            let timeLeft = Float(duration - timeInSeconds)
            let currentTimeString = Helpers.createTimeString(time: timeInSeconds)
            let timeLeftString = Helpers.createTimeString(time: timeLeft)
            self.currentTimeLabel.text = currentTimeString
            self.timeLeftLabel.text = timeLeftString
        }
        previousSliderValue = timeInSeconds
    }
    
    func updateSlider(maxValue: Float) {
        // Update max only once
        guard playbackSlider.maximumValue <= 1.0 else { return }
        
        if playbackSlider.isUserInteractionEnabled == false {
            playbackSlider.isUserInteractionEnabled = true
        }
        
        playbackSlider.maximumValue = maxValue
        bufferSlider.maximumValue = maxValue
    }
    
    func updateSlider(currentValue: Float) {
        // Have to check is first load because current value may be far from 0.0
        //@TODO: Fix this logic to fix jumping of playbackslider
        guard !playbackSlider.isTracking else { return }
        //        if isFirstLoad {
        //            playbackSlider.value = currentValue
        //            isFirstLoad = false
        //            return
        //        }
        //
        //        let min = playbackSlider.value - 60.0
        //        let max = playbackSlider.value + 60.0
        
        // Check if current value is within a close enough range to slider value
        // This fixes sliders skipping around
        //        if min...max ~= currentValue && !playbackSlider.isTracking {
        playbackSlider.value = currentValue
        //        }
    }
    
    func updateBufferSlider(bufferValue: Float) {
        bufferSlider.value = bufferValue
    }
    
    func updateTimeLabels(currentTimeText: String, timeLeftText: String) {
        guard !playbackSlider.isTracking else { return }
        self.currentTimeLabel.text = currentTimeText
        self.timeLeftLabel.text = timeLeftText
    }
    
    func showLabels() {
        currentTimeLabel.alpha = 1
        timeLeftLabel.alpha = 1
    }
    
    func hideLabels() {
        currentTimeLabel.alpha = 0
        timeLeftLabel.alpha = 0
    }
    
    func showSliders() {
        self.playbackSlider.alpha = 1
        self.bufferSlider.alpha = 1
        self.bufferBackgroundSlider.alpha = 1
    }
    
    func hideSliders() {
        self.playbackSlider.alpha = 0
        self.bufferSlider.alpha = 0
        self.bufferBackgroundSlider.alpha = 0
    }
    
    func showSliderThumbImage() {
        //@TODO: How do we animate this
        self.playbackSlider.setThumbImage(self.smallCircle, for: .normal)
    }
    
    func hideSliderThumbImage() {
        self.playbackSlider.setThumbImage(UIImage(), for: .normal)
    }
    
    func setDefaultConstraints() {
        playbackSlider.snp.remakeConstraints { (make) -> Void in
            make.bottom.equalToSuperview().inset(UIView.getValueScaledByScreenHeightFor(baseValue: -10) + trackHeight)
            make.height.equalTo(UIView.getValueScaledByScreenHeightFor(baseValue: 20))
            make.left.right.equalToSuperview()
        }
        
        currentTimeLabel.snp.remakeConstraints { (make) -> Void in
            make.left.equalTo(playbackSlider).inset(UIView.getValueScaledByScreenWidthFor(baseValue: 5))
            make.bottom.equalTo(playbackSlider.snp.top)
            make.height.equalTo(UIView.getValueScaledByScreenHeightFor(baseValue: 20))
            make.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 55))
        }
        
        timeLeftLabel.snp.remakeConstraints { (make) -> Void in
            make.right.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 40))
            make.bottom.equalTo(playbackSlider.snp.top)
            make.height.equalTo(UIView.getValueScaledByScreenHeightFor(baseValue: 20))
            make.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 55))
        }
        
        currentTimeLabel.textAlignment = .left
        currentTimeLabel.font = UIFont.systemFont(ofSize: UIView.getValueScaledByScreenWidthFor(baseValue: 12))
        timeLeftLabel.textAlignment = .right
        timeLeftLabel.font = UIFont.systemFont(ofSize: UIView.getValueScaledByScreenWidthFor(baseValue: 12))
    }
    
    func setRotatedConstraints() {
        playbackSlider.snp.remakeConstraints { (make) -> Void in
            make.bottom.equalToSuperview().inset(UIView.getValueScaledByScreenHeightFor(baseValue: 10) + trackHeight)
            make.height.equalTo(UIView.getValueScaledByScreenHeightFor(baseValue: 20))
            make.left.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 56))
            make.right.equalToSuperview().inset(UIView.getValueScaledByScreenWidthFor(baseValue: 152))
        }
        
        currentTimeLabel.snp.remakeConstraints { (make) -> Void in
            make.right.equalTo(playbackSlider.snp.left).inset(UIView.getValueScaledByScreenWidthFor(baseValue: -5))
            make.centerY.equalTo(playbackSlider)
            make.height.equalTo(UIView.getValueScaledByScreenHeightFor(baseValue: 20))
            make.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 55))
        }
        
        timeLeftLabel.snp.remakeConstraints { (make) -> Void in
            make.left.equalTo(playbackSlider.snp.right).inset(UIView.getValueScaledByScreenWidthFor(baseValue: -5))
            make.centerY.equalTo(playbackSlider)
            make.height.equalTo(UIView.getValueScaledByScreenHeightFor(baseValue: 20))
            make.width.equalTo(UIView.getValueScaledByScreenWidthFor(baseValue: 55))
        }
        
        currentTimeLabel.textAlignment = .right
        timeLeftLabel.textAlignment = .left
    }
}
