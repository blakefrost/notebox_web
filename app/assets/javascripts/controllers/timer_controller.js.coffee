app = angular.module("app")

app.controller "timerController", ['$scope', '$element', '$attrs', ($scope, $element, $attrs) ->
  $scope.elasped = {}
  $scope.elasped.seconds = 0
  $scope.elasped.minutes = 0
  $scope.elasped.hours = 0

  tick = ->
    $scope.$apply ->
      $scope.elasped.seconds += 1

  setInterval(tick, 1000, this)

  $scope.pad = (n, width, z) ->
    z = z or "0"
    n = n + ""
    (if n.length >= width then n else new Array(width - n.length + 1).join(z) + n)
]
