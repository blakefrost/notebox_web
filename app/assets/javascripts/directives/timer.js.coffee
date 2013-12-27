app = angular.module("app")

app.directive "timer", [ '$window', '$document', ( $window, $document ) ->
  {
    restrict: "E"
    replace: true
    controller: 'timerController'
    templateUrl: 'timer.html'
    scope:
      href: "@"
      startTime: "@"
      elaspedSeconds: "@"
      running: "@"
  }
]
