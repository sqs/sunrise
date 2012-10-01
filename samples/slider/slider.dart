#library("slider");

#import("../../lib/sunrise.dart", prefix: 'sunrise');

class SliderCtrl extends sunrise.Controller {
  void init() {
    scope['currentDate'] = (new Date.now()).toString();
  }
}

main() {
  sunrise.main();
}
