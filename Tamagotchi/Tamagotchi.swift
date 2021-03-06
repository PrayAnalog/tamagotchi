//
//  Tamagotchi.swift
//  Tamagotchi
//
//  Created by user on 2017. 7. 21..
//  Copyright © 2017년 user. All rights reserved.
//

import UIKit

class Tamagotchi {
    private let MAXVALUE = 100
    private let MINVALUE = 0
    
    private let sleepHealingValue = -40   // 자면 5초당 증가할 피로도
    private let moveInterval = 2.0
    private let isDoingInterval = 10.0
    
    // 처음 정해지는 것
    public var name: String        // 이름 (1글자 이상)
    public var gender: String      // 성별 [♀ or ♂]
    private var button: UIButton
    
    // 보여지는 상태
    public var age: Int             // 나이 (0살 시작, 알에서 태어나면 1살로 설정하자)
    public var hunger: Int          // 배고픔 (0~100) 최대치에 가까울수록 배고픔
    public var cleanliness: Int     // 청결도 (0~100) 최대치에 가까울수록 청결함
    public var closeness: Int       // 친밀도 (0부터 시작) 무한정 높아짐
    
    // 보여지지 않는 상태
    public var health: Int          // 건강 (0~100) 최대치에 가까울수록 건강함
    public var sleepiness: Int      // 졸린 정도 (0~100) 최대치에 가까울수록 졸림!!
    public var isDoing: Bool        // 무언가 하고있는지 (true/flase) 하고 있을 경우 다른 작업 못함
    public var isSelected: Bool     // 현재 선택되었는지
    
    // 캐릭터 종류
    public var species: String      // 캐릭터 종류(사진 정보를 위해서) ["baby"]   계속 추가해야함
    
    // 움직임 상태 타이머
    public var moveTimer: Timer?
    public var isDoingTimer: Timer?
    
    // 자는 상태 타이머
    public var sleepTimer: Timer?
    
    // 함수 버튼 view
    public var buttonView1: UIView?
    public var buttonView2: UIView?
    
    init?(name: String, gender: String, button: UIButton, age: Int = 0, hunger: Int = 0, cleanliness: Int = 0, closeness: Int = 0, health: Int = 0, sleepiness: Int = 0, species: String = "baby", isDoing: Bool = false, isSelected: Bool = false) {
        if (name == "") { // 한 글자 이상
            return nil
        }
        self.name = name
        self.gender = gender
        self.button = button
        self.age = age
        self.hunger = hunger
        self.cleanliness = cleanliness
        self.closeness = closeness
        self.health = health
        self.sleepiness = sleepiness
        self.species = species
        self.button.setImage(UIImage(named: self.species + "default0"), for: UIControlState.normal)
        self.isDoing = isDoing
        self.isSelected = isSelected
    }
    
    public func getInfo() -> [String] {
        return [self.name + self.gender, String(self.age), String(self.hunger), String(self.cleanliness), String(self.closeness)]
    }
    
    public func setBackground() {
        if self.isSelected == true {
            self.button.setBackgroundImage(UIImage(named: "select"), for: UIControlState.normal)
        }else {
            self.button.setBackgroundImage(UIImage(), for: UIControlState.normal)
        }
    }

    public func getData() -> [String:Any] {
        return ["name": self.name, "gender": self.gender, "age": self.age, "hunger": self.hunger, "cleanliness": self.cleanliness, "closeness": self.closeness, "health": self.health, "sleepiness": self.sleepiness, "species": self.species]
    }
        
    public func animationStart(action: String, view1: UIView, view2: UIView) {
        self.isDoing = true
        self.buttonView1 = view1
        self.buttonView2 = view2
        view1.alpha = 0.6
        view2.alpha = 0.6
        
        var imageListArray: [UIImage] = []
        
        for i in 0..<2 {
            let image = UIImage(named: self.species + action + String(i))
            imageListArray.append(image!)
        }
        self.button.imageView?.animationImages = imageListArray
        self.button.imageView?.animationDuration = 1.0
        
        if (action != "sleep") {
            self.button.imageView?.animationRepeatCount = 3
        } else {
            self.button.imageView?.animationRepeatCount = self.sleepiness
        }
        
        self.button.imageView?.startAnimating()
        
        if (action != "sleep") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8, execute: {
                self.isDoing = false
                if (self.isSelected == true){
                    view1.alpha = 1
                    view2.alpha = 1
                }
            })
        } else { // sleep state
            self.sleepTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(sleepingState), userInfo: nil, repeats: true)
        }
    }
    
    @objc func sleepingState() { // 자면 5초당 피로도 delta만큼 씩 증가
        self.updateSleepiness(delta: self.sleepHealingValue)
        if (self.sleepiness < 2) {
            self.sleepTimer!.invalidate()
            self.sleepTimer = nil
            self.isDoing = false
            self.button.imageView?.stopAnimating()
            if (self.isSelected == true){
                self.buttonView1!.alpha = 1
                self.buttonView2!.alpha = 1
            }
        }
        print(self.sleepiness)
    }

    @objc func tamagotchiMoveRandomly() {
        // moving distance
        let movement:CGFloat = 10.0
        
        // moving direction
        let movementArray : [CGFloat] = [movement, 0, movement * -1]
        
        
        // not born, just an egg state. do not move 꿈틀대기만 하자
        if (self.species == "egg") {
            var imageListArray: [UIImage] = []
            
            imageListArray.append(UIImage(named: self.species + "default0")!)
            imageListArray.append(UIImage(named: self.species + "default1")!)
            
            self.button.imageView?.animationImages = imageListArray
            self.button.imageView?.animationDuration = self.moveInterval
            self.button.imageView?.animationRepeatCount = 1
            self.button.imageView?.startAnimating()
            return
        }
        
        // if doing nothing
        if !(self.isDoing) {
            // set moving animation
//            UIView.animate(withDuration: 0, animations: { () -> Void in
                let xOriginMove = movementArray[Int(arc4random_uniform(UInt32(movementArray.count)))]
                let yOriginMove = movementArray[Int(arc4random_uniform(UInt32(movementArray.count)))]
                
                // move in the view, not escape from the view
                if (self.button.frame.origin.x + xOriginMove < 320) && (self.button.frame.origin.x + xOriginMove > 0) {
                    self.button.frame.origin.x += xOriginMove
                    
                    // change picture look like moving animation
                    var imageListArray: [UIImage] = []
                    var action: String = ""
                    if (xOriginMove > 0) {
                        action = "moveright"
                    } else if (xOriginMove < 0) {
                        action = "moveleft"
                    } else {
                        action = "default"
                    }
                    
                    imageListArray.append(UIImage(named: self.species + action + "0")!)
                    imageListArray.append(UIImage(named: self.species + "default" + String(Int(arc4random_uniform(UInt32(2)))))!)
                
                    
                    self.button.imageView?.animationImages = imageListArray
                    self.button.imageView?.animationDuration = self.moveInterval
                    self.button.imageView?.animationRepeatCount = 1
                    self.button.imageView?.startAnimating()
                    
                }
                if (self.button.frame.origin.y + yOriginMove < 240) && (self.button.frame.origin.y + yOriginMove > 0) {
                    self.button.frame.origin.y += yOriginMove
                }
//            })
            
        }
    }
    
    @objc func makeItMove() {
        if (self.moveTimer == nil) && (!(self.isDoing) || (self.species == "egg")) {
            self.moveTimer = Timer.scheduledTimer(timeInterval: moveInterval, target: self, selector: #selector(tamagotchiMoveRandomly), userInfo: nil, repeats: true)
        }
    }
    
    func startMove() {
        if (self.moveTimer != nil) {
            self.moveTimer!.invalidate()
            self.moveTimer = nil
        }
        if (self.isDoingTimer != nil) {
            self.isDoingTimer!.invalidate()
            self.isDoingTimer = nil
        }
        self.moveTimer = Timer.scheduledTimer(timeInterval: moveInterval, target: self, selector: #selector(tamagotchiMoveRandomly), userInfo: nil, repeats: true)
        self.isDoingTimer = Timer.scheduledTimer(timeInterval: isDoingInterval, target: self, selector: #selector(makeItMove), userInfo: nil, repeats: true)
    }
    
    func pauseMove() {
        self.moveTimer?.invalidate()
        self.moveTimer = nil
    }
    
    func stopMove() {
        self.moveTimer?.invalidate()
        self.moveTimer = nil
        
        self.isDoingTimer?.invalidate()
        self.isDoingTimer = nil
    }
    
  
    public func multipleTouchInteraction(touchCount: Int) -> Int {
        if (self.isDoing) {
            print(touchCount)
            if (self.sleepTimer != nil) && (touchCount > 12) { // it is sleeping now.... 격렬하게 터치해야 깨워짐
                print("don't wake me up --")
                self.sleepTimer!.invalidate()
                self.sleepTimer = nil
                self.isDoing = false
                self.button.imageView?.stopAnimating()
                if (self.isSelected == true){
                    self.buttonView1!.alpha = 1
                    self.buttonView2!.alpha = 1
                }
                return 0
            }
            return touchCount
        }
        
        var imageListArray: [UIImage] = []
        
        for i in 0..<2 {
            let image = UIImage(named: self.species + "smile" + String(i))
            imageListArray.append(image!)
        }
        
        self.button.imageView?.animationImages = imageListArray
        self.button.imageView?.animationDuration = 1.0
        self.button.imageView?.animationRepeatCount = 2
        self.button.imageView?.startAnimating()
        
        self.moveTimer?.invalidate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5 , execute: {
            self.moveTimer?.fire()
        })
        return 0
    }

    public func updateAge(delta: Int) {
        self.age = self.age + delta
        if (self.age == 1) { // 0살에서 1살로. 즉 알에서 태어남.
            updateHealth(delta: 80)
            updateHunger(delta: 100) // 많이 배고픔
            updateCloseness(delta: 0)
            updateCleanliness(delta: 50)
            updateSleepiness(delta: 30)
            self.species = "baby"
            self.button.setImage(UIImage(named: self.species + "default0"), for: UIControlState.normal)
            self.isDoing = false
            self.gender = ["♀", "♂"][Int(arc4random_uniform(UInt32(2)))] // 둘 중 하나로 랜덤
            self.name = "?"
            
        }
    }
    
    public func updateHunger(delta: Int) {
        self.hunger = self.hunger + delta
        if self.hunger > MAXVALUE {
            self.hunger = MAXVALUE
        } else if self.hunger < MINVALUE {
            self.hunger = MINVALUE
        }
        if Float(self.hunger) > Float(MAXVALUE) * 0.7 {
            self.health = self.health - 1
        }
    }
    
    public func updateCleanliness(delta: Int) {
        self.cleanliness = self.cleanliness + delta
        if self.cleanliness > MAXVALUE {
            self.cleanliness = MAXVALUE
        } else if self.cleanliness < MINVALUE {
            self.cleanliness = MINVALUE
        }
        if Float(self.cleanliness) < Float(MAXVALUE) * 0.3 {
            self.health = self.health - 1
        }
    }
    
    public func updateCloseness(delta: Int) {
        self.closeness = self.closeness + delta
        if self.closeness < MINVALUE {
            self.closeness = MINVALUE
        }
    }
    
    public func updateHealth(delta: Int) {
        self.health = self.health + delta
        if self.health > MAXVALUE {
            self.health = MAXVALUE
        } else if self.health < MINVALUE {
            self.health = MINVALUE
        }
    }
    
    public func updateSleepiness(delta: Int) {
        self.sleepiness = self.sleepiness + delta
        if self.sleepiness > MAXVALUE {
            self.sleepiness = MAXVALUE
        } else if self.sleepiness < MINVALUE {
            self.sleepiness = MINVALUE
        }
    }

    
    // 디버깅용 print 함수
    public func printAllState() {
        print("===========================")
        print("|" + self.name + " " + self.gender + " |나이:" + String(self.age) + " |종족: " + self.species)
        print("---------------------------")
        print("|배고픔: " + String(self.hunger) + " |청결도: " + String(self.cleanliness) + " |친밀도: " + String(self.closeness))
        print("|건강함: " + String(self.health) + " |졸리냐: " + String(self.sleepiness) + " |")
        print("|바쁘냐: " + (self.isDoing ? "Y" : "N") + " |")
        print("===========================")
    }
    
}
