import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';

class AnimatedLoginScreen extends StatefulWidget {
  const AnimatedLoginScreen({Key? key}) : super(key: key);

  @override
  State<AnimatedLoginScreen> createState() => _AnimatedLoginScreenState();
}

class _AnimatedLoginScreenState extends State<AnimatedLoginScreen>
    /*
    We need a Flutter widget that updates with every frame
    and that's when tickers come in handy
    A ticker houses the logic that lives under the hood and gives the whole animation life.
    Tickers can be used by any object that wants to be notified every time a frame change triggers.
    Any time the screen changes in Flutter there’s actually a series of tiny, subsecond re-renders that make the change look natural.
    To create a ticker, we need to add a TickerProviderStateMixin to our class.
    this mixin provides Ticker objects that are configured to only tick while the current tree is enabled.
    To create an AnimationController in a class that uses this mixin,
    pass {vsync: this} to the animation controller constructor whenever you create a new animation controller.
    If you only have a single Ticker (for example only a single AnimationController like our case here) for the lifetime of your State,
    then using a SingleTickerProviderStateMixin is more efficient.
    */
    with
        TickerProviderStateMixin {
  // boolean value to let us know on which screen we currently are
  bool onLogin = true;
  // defining the animation controller
  late AnimationController _controller;
  //animation object of type double to animate the position of the transparent container
  late Animation<double> _positionAnimation;
  //animation object of type double to animate the border radius of the transparent container
  late Animation<double> _borderAnimation;
  // flip controller to flip the white container
  late FlipCardController _flipController;
  /*
  until now all of our animations will follow a linear speed from start to end, they don't start slow and magically speed up halfway,
  or they don't start fast and slow down towards the end, they start and end at the same speed.
  In Flutter, we can change this, and we can control the speed, acceleration and deceleration by using curves.
  Curves determine the speed of an animation at different points in time during the animation
  (video of the curve)the x directions represent the animation value from beginning to the end.
  In this case from 0 to 1 and a T direction going across that represents the time or the duration of the animation.
  So imagine that the bottom right here is the starting point of the animation on the top is the end now a linear progression without using a curve which is go straight up at a constant speed,
  but curves speed up and slow down points of the progression.
  */
  late Animation<double> _curve;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      /*
       * to sync this controller with a ticker, the ticker we sync it with will be our stateful widget itself,
       * so that only when this widget tree is active on the screen the ticker will tick.
       */
      vsync: this,
      /*
       * set the duration of the animation to 600 milliseconds
       * We don’t need the animation to happen too fast so that the user wouldn’t be able to see it and we don’t need it to happen too slow, it will be boring
       * We need it to occur just in the right time so that the user can enjoy it and repeat it again and again.
       */
      duration: const Duration(milliseconds: 600),
    );
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    /*
     * the job of the tween is to map steps between start and end value
     * and we will animate that tween using the animate method and control it with our _curve
     */
    _borderAnimation = Tween<double>(begin: 0, end: 46).animate(_curve);
    _positionAnimation = Tween<double>(begin: 0, end: 250).animate(_curve);
    Future.delayed(Duration.zero, () {
      _positionAnimation = Tween<double>(
              begin: 0, end: MediaQuery.of(context).size.height * 0.29)
          .animate(_curve);
    });
    _flipController = FlipCardController();
    /*
     * add listener to our controller to listen for whatever value it spits out by the controller
     * so we can know when the animation is completed or dismissed and change the {onLogin} value based on that.
     */
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          onLogin = false;
        });
      }
      if (status == AnimationStatus.dismissed) {
        setState(() {
          onLogin = true;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    // don't forget to dispose your controller
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      // set {resizeToAvoidBottomInset: true} to avoid getting overflow from the keyboard.
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: SizedBox(
          width: width,
          height: height,
          // we need a stack to layout our widgets on top of each others,
          // the transparent container will be under the white one and all of them on top of the background image.
          child: Stack(
            children: [
              // here we set the background image and give it some darkness on top of it using color filters
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.4),
                        BlendMode.srcOver,
                      ),
                      image: const AssetImage('assets/background.jpg'),
                      fit: BoxFit.cover),
                ),
              ),
              // Putting the logo at the top center of our page.
              Positioned(
                top: -10,
                right: width / 4,
                left: height / 4,
                child: SvgPicture.asset(
                  'assets/fashion.svg',
                  height: 230,
                  color: Colors.white,
                ),
              ),
              // to make the transparent container slide under the white container we need an animation builder
              // so that every time the controller value changes the animation builder is gonna rebuild the widget tree inside it.
              AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, _) {
                  return Positioned(
                    /*
                     * we will pass the _positionAnimation value to the bottom of our positioned widget
                     * and that value is gonna map between 0 and 280.
                     * so the position of the transparent container will be 0 pixels from the bottom of the login screen and it will be visible on screen , 280 pixels from the bottom of the signup screen and it will be hidden under the white container.
                     */
                    bottom: _positionAnimation.value,
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        width: width,
                        height: height * 0.345,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            //as we did in the position we will repeat the same process and pass the _borderAnimation value to the border of the transparent container
                            Radius.circular(_borderAnimation.value),
                          ),
                          color: Colors.white.withOpacity(0.7),
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Don\'t have an account?',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Montserrat',
                                    color: Colors.black.withOpacity(0.6),
                                    fontWeight: FontWeight.w600),
                              ),
                              TextButton(
                                onPressed: () {
                                  // that is how we trigger the animation and tell our controller to start the movement of the transparent container
                                  _controller.forward();
                                  // here we are just adding a delay between the animated position and the flip, i don't want the animation and the flipping to happen at the same time, so that they don't overlap.
                                  // the timing is completely up to you, you can play with it however you want and see the results
                                  Future.delayed(
                                      const Duration(milliseconds: 400), () {
                                    // to trigger the flip animation
                                    _flipController.toggleCard();
                                  });
                                },
                                style: ButtonStyle(
                                  overlayColor: MaterialStateProperty.all(
                                    Colors.deepOrange.withOpacity(0.1),
                                  ),
                                ),
                                child: const Text(
                                  'Signup',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        )),
                  );
                },
              ),
              /*
               * here we are just setting a white background for our flip card,
               * this background is  used to hide the transparent container while flipping
               * without this cover, the transparent container will be exposed during the flip.
               */
              Positioned(
                bottom: height * 0.279,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(46)),
                  ),
                  constraints: BoxConstraints.expand(
                    width: width,
                    height: height * 0.446,
                  ),
                ),
              ),
              //Putting the flip card on top of the white background to be more Obvious when it flips
              Positioned(
                bottom: height * 0.279,
                child: FlipCard(
                  // pass the flip controller to trigger the flip motion with buttons
                  controller: _flipController,
                  // Fill the back side of the card to make in the same size as the front.
                  fill: Fill.fillBack,
                  // the speed of the flip
                  speed: 450,
                  // we don't want it to flip when we touch the card
                  flipOnTouch: false,
                  // the direction of the flip
                  direction: FlipDirection.VERTICAL,
                  // the front side gonna be the login card
                  front: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 30),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(46)),
                    ),
                    constraints: BoxConstraints.expand(
                      width: width,
                      height: height * 0.446,
                    ),
                    child: const Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        'SIGN IN',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w800,
                          color: Colors.deepOrange,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  // and the back side is signup card
                  back: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 30),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(46)),
                    ),
                    constraints: BoxConstraints.expand(
                      width: width,
                      height: height * 0.446,
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              // when pressing the back button flip the card again
                              _flipController.toggleCard();
                              Future.delayed(const Duration(milliseconds: 250),
                                  () {
                                // and revers the animation
                                _controller.reverse();
                              });
                            },
                            icon: const Icon(Icons.arrow_back_ios),
                            color: Colors.black,
                            iconSize: 16,
                          ),
                          const Text(
                            'SIGN UP',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w800,
                              color: Colors.deepOrange,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(
                            width: 40,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
