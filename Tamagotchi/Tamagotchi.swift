//
//  Tamagotchi.swift
//  Tamagotchi
//
//  Created by user on 2017. 7. 21..
//  Copyright © 2017년 user. All rights reserved.
//

import UIKit

class Tamagotchi {
    // 처음 정해지는 것
    private var name: String        // 이름 (1글자 이상)
    private var gender: String      // 성별 [♀ or ♂]
    private var button: UIButton
    
    // 보여지는 상태
    public var age: Int             // 나이 (0살 시작, 알에서 태어나면 1살로 설정하자)
    public var hunger: Int          // 배고픔 (0~100) 최대치에 가까울수록 배고픔
    public var cleanliness: Int     // 청결도 (0~100) 최대치에 가까울수록 청결함
    public var closeness: Int       // 친밀도 (0부터 시작) 무한정 높아짐
    
    
    // 보여지지 않는 상태
    public var health: Int          // 건강 (0~100) 최대치에 가까울수록 건강함
    public var sleepiness: Int      // 졸린 정도 (0~100) 최대치에 가까울수록 졸림!!
    
    // 캐릭터 종류
    public var species: String      // 캐릭터 종류(사진 정보를 위해서) ["baby"]   계속 추가해야함
    
    init?(name: String, gender: String, button: UIButton, age: Int = 0, hunger: Int = 0, cleanliness: Int = 0, closeness: Int = 0, health: Int = 0, sleepiness: Int = 0, species: String = "baby") {
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
    }
    
    public func animationStart(action: String) {
        var imageListArray: [UIImage] = []
        
        for i in 0..<2 {
            let image = UIImage(named: self.species + action + String(i))
            imageListArray.append(image!)
        }
        
        self.button.imageView?.animationImages = imageListArray
        self.button.imageView?.animationDuration = 1.0
        self.button.imageView?.animationRepeatCount = 3
        self.button.imageView?.startAnimating()
    }
    
    
}