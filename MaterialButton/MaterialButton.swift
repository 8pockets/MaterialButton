//
//  MaterialButton.swift
//  MaterialButtonDemo
//
//  Created by 8pockets on 2014/09/25.
//  Copyright (c) 2014年 8pockets. All rights reserved.
//

import UIKit
//UI~のクラスをすべて読み込む
import QuartzCore
//CAAnimation,CALayer,CATransactionなどのクラスを読み込む

@IBDesignable//デザインをGUIで調整出来るようになる。@IBInspectableで指定する。
class MaterialButton: UIButton {
    
    @IBInspectable var ripplePercent: Float = 0.8 {
        didSet {
        //swiftはwillSet/didSetを仕掛ける事で、プロパティの変更前/後で何か処理を書く事ができる。
        //http://qiita.com/takabosoft/items/b3af8b30a8c5111f4fce
            setupRippleView()
        }
    }
/*
    @IBInspectable var rippleOverBounds: Bool = false {
        didSet {
            if rippleOverBounds {
                rippleBackgroundView.layer.mask = nil
            } else {
                var maskLayer = CAShapeLayer()
                //NSObject > CALayer > CAShapeLayer / 図形を描画するメソッドを持ったクラス
                //https://developer.apple.com/library/ios/documentation/GraphicsImaging/Reference/CAShapeLayer_class/index.html#//apple_ref/occ/cl/CAShapeLayer
                maskLayer.path = UIBezierPath(roundedRect: bounds,cornerRadius: layer.cornerRadius).CGPath
                //pathはCAShapeLayerの詳細指定。UIBezierPathでベジェ（Bezier）曲線の指定を渡す。
                rippleBackgroundView.layer.mask = maskLayer
                //CALayerチュートリアル
                //http://www.raywenderlich.com/ja/26222/%E9%96%8B%E7%99%BA%E5%88%9D%E5%BF%83%E8%80%85%E3%81%AE%E7%82%BA%E3%81%AEcalayer%E3%83%81%E3%83%A5%E3%83%BC%E3%83%88%E3%83%AA%E3%82%A2%E3%83%AB
            }
        }
    }
*/
    
    @IBInspectable var rippleOverBounds: Bool = false
    
    @IBInspectable var rippleColor: UIColor = UIColor(white: 0.9, alpha: 1) {
        didSet {
            rippleView.backgroundColor = rippleColor
        }
    }
    
    @IBInspectable var rippleBackgroundColor: UIColor = UIColor(white: 0.95, alpha: 1) {
        didSet {
            rippleBackgroundView.backgroundColor = rippleBackgroundColor
        }
    }
    
    @IBInspectable var buttonCornerRadius: Float = 0 {
        didSet{
            layer.cornerRadius = CGFloat(buttonCornerRadius)
                //UIView > UIControl > UIButtonなのでこのクラス自体はlayerプロパティが存在して、ここで指定している。
        }
    }
    
    @IBInspectable var shadowRippleRadius: Float = 1
    @IBInspectable var shadowRippleEnable: Bool = true
    @IBInspectable var trackTouchLocation: Bool = false
    
    //------------------------------------------初期セット------------------------------------------------------
    
    let rippleView = UIView()
    let rippleBackgroundView = UIView()
    private var tempShadowRadius: CGFloat = 0
    //CGFloatはCoreGraphicsのfloat(浮動点)みたい
    private var tempShadowOpacity: Float = 0
    //privateはswiftのアクセスコントロール。private修飾子は同じファイル内のみアクセスできる。
    //http://qiita.com/fmtonakai/items/711e41eebcc040936668
    
    private var rippleMask: CAShapeLayer? {
        get {
            if !rippleOverBounds {
                var maskLayer = CAShapeLayer()
                maskLayer.path = UIBezierPath(roundedRect: bounds,
                    cornerRadius: layer.cornerRadius).CGPath
                return maskLayer
            } else {
                return nil
            }
        }
    }
    
    //----------------------------------------ここで何してるのか不明-----------------------------------------------------------
    
    required init(coder aDecoder: NSCoder)  {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    //プロトコルで宣言したイニシャライザinitは、実装クラスでrequired修飾子を付ける必要がある。
    //親クラスで宣言したイニシャライザinitは、実装(子)クラスでoverride修飾子を付ける必要がある。
    //http://qiita.com/tajihiro/items/d4d6bd06e63d24d206e4
    
    //--------------------------------------------関数定義----------------------------------------------------------------
    //アニメーションについて詳しく書いてある。
    //http://qiita.com/inamiy/items/bdc0eb403852178c4ea7
    //http://www.raywenderlich.com/76200/basic-uiview-animation-swift-tutorial
    
    private func setup() {
        setupRippleView()
        
        rippleOverBounds = false
        
        rippleBackgroundView.backgroundColor = rippleBackgroundColor
        rippleBackgroundView.frame = bounds
        ////boundsはステータスバー領域を含む画面のサイズを返す。UIviewからこのUIButtonに継承されてる。
        
        layer.addSublayer(rippleBackgroundView.layer)
        rippleBackgroundView.layer.addSublayer(rippleView.layer)
        //レイヤーを現在のUIButtonに足す。
        
        rippleBackgroundView.alpha = 0
        
        layer.shadowRadius = 0
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowColor = UIColor(white: 0.0, alpha: 0.5).CGColor
    }
    
    private func setupRippleView() {
        var size: CGFloat = CGRectGetWidth(bounds) * CGFloat(ripplePercent)
        var x: CGFloat = (CGRectGetWidth(bounds)/2) - (size/2)
        var y: CGFloat = (CGRectGetHeight(bounds)/2) - (size/2)
        var corner: CGFloat = size/2
        //ここら辺の計算はCGGeometry(位置やサイズ、領域操作系のCGGeometry)で詳しく。
        //http://qiita.com/hachinobu/items/f8ac32870739c7d4eab8
        
        rippleView.backgroundColor = rippleColor
        rippleView.frame = CGRectMake(x, y, size, size)
        rippleView.layer.cornerRadius = corner
    }
    
    override func beginTrackingWithTouch(touch: UITouch,
        withEvent event: UIEvent) -> Bool {
            //UIViewの親クラスのUIResponderでtouchesBegan:withEvent:みたいな感じで書いている。UIResponderはUI~の中のイベント系のクラス
            //http://www.objectivec-iphone.com/event.html
            
            //swiftは->で関数の返り値の型を指定出来る。
            //http://qiita.com/dankogai/items/46fedc447dd93d1e0fbc
            
            if trackTouchLocation {
                rippleView.center = touch.locationInView(self)
                //タッチイベントから座標を取得
            }
            
            UIView.animateWithDuration(0.1, animations: {
                self.rippleBackgroundView.alpha = 1
                }, completion: nil)
            //animateWithDuration(1.0, delay:0.0, options:nil, animations:hoge, completion:nil)
            //completionはアニメーションが終了した後に実行する処理
            
            rippleView.transform = CGAffineTransformMakeScale(0.5, 0.5)
            UIView.animateWithDuration(0.7, delay: 0, options: .CurveEaseOut,
                animations: {
                    self.rippleView.transform = CGAffineTransformIdentity
                }, completion: nil)
            //UIViewの移動・拡大縮小・回転を行う、アフィン変換。UIViewで提供されいて、CGAffineTransformMakeScaleで値を与える。CGAffineTransformIdentityで解除
            
            if shadowRippleEnable {
                tempShadowRadius = layer.shadowRadius
                tempShadowOpacity = layer.shadowOpacity
                
                var shadowAnim = CABasicAnimation(keyPath:"shadowRadius")
                shadowAnim.toValue = shadowRippleRadius
                
                var opacityAnim = CABasicAnimation(keyPath:"shadowOpacity")
                opacityAnim.toValue = 1
                
                var groupAnim = CAAnimationGroup()
                groupAnim.duration = 0.7
                groupAnim.fillMode = kCAFillModeForwards
                groupAnim.removedOnCompletion = false
                groupAnim.animations = [shadowAnim, opacityAnim]
                
                layer.addAnimation(groupAnim, forKey:"shadow")
            }
            return super.beginTrackingWithTouch(touch, withEvent: event)
    }
    
    override func endTrackingWithTouch(touch: UITouch,
        withEvent event: UIEvent) {
            super.endTrackingWithTouch(touch, withEvent: event)
            
            UIView.animateWithDuration(0.1, animations: {
                self.rippleBackgroundView.alpha = 1
                }, completion: {(success: Bool) -> () in
                    UIView.animateWithDuration(0.6 , animations: {
                        self.rippleBackgroundView.alpha = 0
                        }, completion: nil)
            })
            
            UIView.animateWithDuration(0.7, delay: 0,
                options: .CurveEaseOut | .BeginFromCurrentState, animations: {
                    self.rippleView.transform = CGAffineTransformIdentity
                    
                    var shadowAnim = CABasicAnimation(keyPath:"shadowRadius")
                    shadowAnim.toValue = self.tempShadowRadius
                    
                    var opacityAnim = CABasicAnimation(keyPath:"shadowOpacity")
                    opacityAnim.toValue = self.tempShadowOpacity
                    
                    var groupAnim = CAAnimationGroup()
                    groupAnim.duration = 0.7
                    groupAnim.fillMode = kCAFillModeForwards
                    groupAnim.removedOnCompletion = false
                    groupAnim.animations = [shadowAnim, opacityAnim]
                    
                    self.layer.addAnimation(groupAnim, forKey:"shadowBack")
                }, completion: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let oldCenter = rippleView.center
        setupRippleView()
        rippleView.center = oldCenter
        
        rippleBackgroundView.layer.frame = bounds
        rippleBackgroundView.layer.mask = rippleMask
    }
    
}