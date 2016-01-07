//
//  QLRootViewController.m
//  CoreAnimationStudy
//
//  Created by qianlongxu on 16/1/7.
//  Copyright © 2016年 qianlongxu. All rights reserved.
//

#import "QLRootViewController.h"
#import "QLRootCell.h"

@interface QLRootViewController ()

@property (nonatomic, strong) NSArray *animations;
@property (nonatomic, strong) UIView *animationView;
@property (nonatomic, strong) UIView *animationDestView;
@end

@implementation QLRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.animations = @[@"BaseAnimationChangeBackgroundColor",
                        @"BaseAnimationChangeSize",
                        @"CAKeyframeAnimationChangeColors",
                        @"CAKeyframeAnimationMailPath",
                        @"3DAnimationGroup",
                        @"DownloadAnimationGroup"];
    
    self.tableView.backgroundView = [UIView new];
    [self.tableView registerClass:[QLRootCell class] forCellReuseIdentifier:@"QLRootCell"];
    
    UIView * animationView = [UIView new];
    animationView.backgroundColor = [UIColor grayColor];
    animationView.frame = CGRectMake(self.view.bounds.size.width-80, self.view.bounds.size.height-100, 30, 30);
    [self.view addSubview:animationView];
    self.animationView = animationView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.animations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QLRootCell" forIndexPath:indexPath];
    cell.textLabel.text = self.animations[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   QLRootCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    SEL sel = NSSelectorFromString([@"add" stringByAppendingString:cell.textLabel.text]);
    [self performSelector:sel withObject:nil];
}

/*
 CAAnimation 及其子类都是显式动画，这意味着动画结束后表示层会恢复到模型层；
 CABasicAnimation:CAPropertyAnimation:CAAnimation:NSObject
 
*/
- (void)addBaseAnimationChangeBackgroundColor
{
    CABasicAnimation *basicAnimation = [CABasicAnimation animation];
    basicAnimation.toValue = (id)[UIColor redColor].CGColor;
    basicAnimation.duration = 2;
    basicAnimation.autoreverses = YES;
    [self.animationView.layer addAnimation:basicAnimation forKey:@"backgroundColor"];
//    self.animationView.layer.backgroundColor = [[UIColor redColor]CGColor];
}

- (void)addBaseAnimationChangeSize
{
    CABasicAnimation *basicAnimation = [CABasicAnimation animation];
    basicAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(150, 150)];
    basicAnimation.autoreverses = YES;
    basicAnimation.duration = 1.5;
    [self.animationView.layer addAnimation:basicAnimation forKey:@"bounds.size"];
}

//更强大的效果；使用UIView的动画难以实现

//关键帧动画 CAKeyfrmaeAnimation:CAPropertyAnimation

//沿着一些列的值变化；
- (void)addCAKeyframeAnimationChangeColors
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.values = @[(id)self.animationView.layer.backgroundColor,
                         (id)[[UIColor yellowColor]CGColor],
                         (id)[[UIColor blueColor]CGColor],
                         (id)[[UIColor greenColor]CGColor]
                         ];
    animation.duration = 6;
    animation.autoreverses = YES;
    [self.animationView.layer addAnimation:animation forKey:@"backgroundColor"];
}

//沿着一系列的路径变化；
- (void)addCAKeyframeAnimationMailPath
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    CGMutablePathRef aPath = CGPathCreateMutable();
    CGPathMoveToPoint(aPath, nil, 20, 20);
    CGPathAddCurveToPoint(aPath, nil, 160, 30, 220, 220, 240, 380);
    animation.path = aPath;
    animation.duration = 1;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.rotationMode = @"auto";
    [self.animationView.layer addAnimation:animation forKey:@"position"];
    CFRelease(aPath);
}

//3D变换

- (void)add3DAnimationGroup
{
    //Y轴旋转；
    CABasicAnimation *flipAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    flipAnimation.toValue = @(-M_PI);
    flipAnimation.duration = 1.5;
    
    //缩放；
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.toValue = @(0.9);
    scaleAnimation.duration = 1.5;
    scaleAnimation.autoreverses = YES;
    
    //把旋转和缩放组合起来；
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[flipAnimation,scaleAnimation];
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animationGroup.duration = 3;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    
    [self.animationView.layer addAnimation:animationGroup forKey:@"flip"];
}

//添加视频动画
- (void)addDownloadAnimationGroup
{
    if (!self.animationDestView) {
        self.animationDestView = [UIView new];
        self.animationDestView.backgroundColor = [UIColor redColor];
        self.animationDestView.frame = CGRectMake(50, 240, 30, 30);
        [self.view addSubview:self.animationDestView];
    }
    
    CFTimeInterval animationTotalDuration = 1.5;
    
    //放大动画；
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(38, 38)];
    scaleAnimation.autoreverses = NO;
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.duration = 0.15;
    scaleAnimation.removedOnCompletion = NO;
    
    //弧线运动路径；
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint startPotin = self.animationView.layer.position;
    [path moveToPoint:startPotin];
    CGPoint desPotint = self.animationDestView.center;
    [path addQuadCurveToPoint:desPotint controlPoint:CGPointMake(startPotin.x, desPotint.y + 50)];
    
    //弧线运动动画
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.path = path.CGPath;
    pathAnimation.duration = animationTotalDuration;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
//    pathAnimation.rotationMode = @"auto";自动改变头的方向，这里影响rotation的角度
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.fillMode = kCAFillModeForwards;
    
    //旋转动画；
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = @(-2*M_PI);
    rotationAnimation.duration = animationTotalDuration;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;
    [rotationAnimation setValue:@"1" forKey:@"animationEndFlag"];
    
    //缩小动画；
    CABasicAnimation *scale2Animation = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
    scale2Animation.toValue = [NSValue valueWithCGSize:CGSizeMake(0, 0)];
    scale2Animation.autoreverses = NO;
    scale2Animation.fillMode = kCAFillModeForwards;
    scale2Animation.duration = 0.15;
    scale2Animation.beginTime = animationTotalDuration-scale2Animation.duration;
    scale2Animation.removedOnCompletion = NO;
    
    //动画图层；
    CALayer *animationLayer = [CALayer layer];
    animationLayer.name = @"custom layer";
//    http://www.raywenderlich.com/2502/calayers-tutorial-for-ios-introduction-to-calayers-tutorial
    animationLayer.contents = (id)[[UIImage imageNamed:@"Bg-Score-Icon"]CGImage];
    animationLayer.frame = CGRectMake(self.animationView.frame.origin.x, self.animationView.frame.origin.y, 0, 0);
    [self.view.layer addSublayer:animationLayer];

//    [animationLayer addAnimation:scaleAnimation forKey:@"bounds.size"];
//    [animationLayer addAnimation:pathAnimation forKey:@"position"];
//    [animationLayer addAnimation:rotationAnimation forKey:@"transform.rotation.z"];
    //动画组，完成之后移除
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[scaleAnimation,rotationAnimation,pathAnimation,scale2Animation];
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animationGroup.duration = animationTotalDuration;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    animationGroup.delegate = self;
    [animationGroup setValue:animationLayer forKey:animationLayer.name];
    [animationLayer addAnimation:animationGroup forKey:@"aaa"];
}

//http://stackoverflow.com/questions/6330701/how-to-remove-a-calayer-object-from-animationdidstop
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    BOOL isEnd = [anim valueForKey:@"animationEndFlag"];
    if (isEnd) {
        CALayer *layer = [anim valueForKey:@"custom layer"];
        if (layer) {
            [layer removeFromSuperlayer];
        }
    }
}

@end
