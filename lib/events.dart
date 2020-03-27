enum Events {
  SettingClicked
}

typedef void EventCallback(arg);

class EventBus {
  EventBus._internal();

  static EventBus _singleton = new EventBus._internal();

  factory EventBus()=> _singleton;

  var _eventMap = new Map<Object, List<EventCallback>>();

  void on(eventName, EventCallback f) {
    if (eventName == null || f == null) return;
    _eventMap[eventName] ??= new List<EventCallback>();
    _eventMap[eventName].add(f);
  }

  void off(eventName, [EventCallback f]) {
    var list = _eventMap[eventName];
    if (eventName == null || list == null) return;
    if (f == null) {
      _eventMap[eventName] = null;
    } else {
      list.remove(f);
    }
  }

  void emit(eventName, [arg]) {
    var list = _eventMap[eventName];
    if (list == null) return;
    int len = list.length - 1;
    for (var i = len; i > -1; --i) {
      list[i](arg);
    }
  }
}

var eventBus = new EventBus();